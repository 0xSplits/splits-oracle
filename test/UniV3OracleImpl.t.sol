// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/Base.t.sol";

import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3PoolDerivedState} from "v3-core/interfaces/pool/IUniswapV3PoolDerivedState.sol";

import {UniV3OracleFactory} from "../src/UniV3OracleFactory.sol";
import {IOracle} from "../src/interfaces/IOracle.sol";
import {OracleParams} from "../src/peripherals/OracleParams.sol";
import {QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";
import {UniV3OracleImpl} from "../src/UniV3OracleImpl.sol";

// TODO: separate out fork tests
// TODO: add fuzzing

contract UniV3OracleImplTest is BaseTest {
    using TokenUtils for address;

    error Unauthorized();
    error Paused();

    error InvalidPair_PoolNotSet();

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    event SetDefaultPeriod(uint32 defaultPeriod);
    event SetPairDetails(UniV3OracleImpl.SetPairDetailParams[] params);

    UniV3OracleFactory oracleFactory;
    UniV3OracleImpl oracleImpl;
    UniV3OracleImpl oracle;

    QuotePair wethETH;
    QuotePair usdcETH;

    UniV3OracleImpl.SetPairDetailParams[] pairDetails;

    QuoteParams[] quoteParams;

    function setUp() public virtual override {
        super.setUp();

        // TODO: can vm.rpcUrl be used in Base ?
        /* forkId = vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER); */
        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        vm.createSelectFork(MAINNET_RPC_URL, BLOCK_NUMBER);
        // TODO: check out makePersistent cheatcode ?

        // set up oracle
        oracleFactory = new UniV3OracleFactory({
            weth9_: WETH9
        });
        oracleImpl = oracleFactory.uniV3OracleImpl();

        wethETH = QuotePair({base: WETH9, quote: ETH_ADDRESS});
        usdcETH = QuotePair({base: USDC, quote: ETH_ADDRESS});

        pairDetails.push(
            UniV3OracleImpl.SetPairDetailParams({
                quotePair: wethETH,
                pairDetail: UniV3OracleImpl.PairDetail({
                    pool: address(0), // no override
                    period: 0 // no override
                })
            })
        );
        pairDetails.push(
            UniV3OracleImpl.SetPairDetailParams({
                quotePair: usdcETH,
                pairDetail: UniV3OracleImpl.PairDetail({
                    pool: IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(USDC, WETH9, 5_00),
                    period: 0 // no override
                })
            })
        );

        oracle = oracleFactory.createUniV3Oracle(_initParams());

        quoteParams.push(QuoteParams({quotePair: wethETH, baseAmount: 1 ether, data: ""}));
        quoteParams.push(
            QuoteParams({
                quotePair: usdcETH,
                baseAmount: 10 ** 9, // $1,000 usc ~= 0.5 eth
                data: ""
            })
        );
    }

    function _initParams() internal view returns (UniV3OracleImpl.InitParams memory) {
        return UniV3OracleImpl.InitParams({
            owner: users.alice,
            paused: false,
            defaultPeriod: 30 minutes,
            pairDetails: pairDetails
        });
    }

    /// -----------------------------------------------------------------------
    /// modifiers
    /// -----------------------------------------------------------------------

    modifier callerFactory() {
        _;
    }

    modifier callerOwner() {
        _;
    }

    modifier unpaused() {
        _;
    }

    /// -----------------------------------------------------------------------
    /// tests - basic
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - basic - initializer
    /// -----------------------------------------------------------------------

    function testFork_revertWhen_callerNotFactory_initializer() public {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.expectRevert(Unauthorized.selector);
        oracleImpl.initializer(initParams);

        vm.expectRevert(Unauthorized.selector);
        oracle.initializer(initParams);
    }

    function testFork_initializer_setsOwner() public callerFactory {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(address(oracleFactory));
        oracle.initializer(initParams);
        assertEq(oracle.owner(), initParams.owner);
    }

    function testFork_initializer_setsPaused() public callerFactory {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(address(oracleFactory));
        oracle.initializer(initParams);
        assertEq(oracle.paused(), initParams.paused);
    }

    function testFork_initializer_setsDefaultPeriod() public callerFactory {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(address(oracleFactory));
        oracle.initializer(initParams);
        assertEq(oracle.defaultPeriod(), initParams.defaultPeriod);
    }

    function testFork_initializer_setsPairDetails() public callerFactory {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(address(oracleFactory));
        oracle.initializer(initParams);

        uint256 length = initParams.pairDetails.length;
        QuotePair[] memory initQuotePairs = new QuotePair[](length);
        UniV3OracleImpl.PairDetail[] memory initPairDetails = new UniV3OracleImpl.PairDetail[](length);
        for (uint256 i; i < length; i++) {
            initQuotePairs[i] = initParams.pairDetails[i].quotePair;
            initPairDetails[i] = initParams.pairDetails[i].pairDetail;
        }
        assertEq(oracle.getPairDetails(initQuotePairs), initPairDetails);
    }

    function testFork_initializer_emitsOwnershipTransferred() public callerFactory {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(address(oracleFactory));
        _expectEmit();
        emit OwnershipTransferred(address(0), initParams.owner);
        oracle.initializer(initParams);
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - setDefaultPeriod
    /// -----------------------------------------------------------------------

    function testFork_revertWhen_callerNotOwner_setDefaultPeriod() public {
        uint32 newDefaultPeriod = 15 minutes;
        vm.expectRevert(Unauthorized.selector);
        oracle.setDefaultPeriod(newDefaultPeriod);
    }

    function testFork_setDefaultPeriod_setsDefaultPeriod() public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();
        uint32 newDefaultPeriod = 15 minutes;

        vm.prank(initParams.owner);
        oracle.setDefaultPeriod(newDefaultPeriod);
        assertEq(oracle.defaultPeriod(), newDefaultPeriod);
    }

    function testFork_setDefaultPeriod_emitsSetDefaultPeriod() public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();
        uint32 newDefaultPeriod = 15 minutes;

        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetDefaultPeriod(newDefaultPeriod);
        oracle.setDefaultPeriod(newDefaultPeriod);
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - setPairDetails
    /// -----------------------------------------------------------------------

    function testFork_revertWhen_callerNotOwner_setPairDetails() public {
        vm.expectRevert(Unauthorized.selector);
        oracle.setPairDetails(pairDetails);
    }

    function testFork_setPairDetails_setsPairDetails() public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        pairDetails[0] = UniV3OracleImpl.SetPairDetailParams({
            quotePair: QuotePair({base: WETH9, quote: ETH_ADDRESS}),
            pairDetail: UniV3OracleImpl.PairDetail({pool: address(0), period: 0})
        });
        pairDetails[1] = UniV3OracleImpl.SetPairDetailParams({
            quotePair: QuotePair({base: USDC, quote: ETH_ADDRESS}),
            pairDetail: UniV3OracleImpl.PairDetail({
                pool: IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(USDC, WETH9, 30_00),
                period: 10 minutes
            })
        });
        uint256 length = pairDetails.length;

        vm.prank(initParams.owner);
        oracle.setPairDetails(pairDetails);

        QuotePair[] memory quotePairs = new QuotePair[](length);
        UniV3OracleImpl.PairDetail[] memory newPairDetails = new UniV3OracleImpl.PairDetail[](length);
        for (uint256 i; i < length; i++) {
            quotePairs[i] = pairDetails[i].quotePair;
            newPairDetails[i] = pairDetails[i].pairDetail;
        }
        assertEq(oracle.getPairDetails(quotePairs), newPairDetails);
    }

    function testFork_setPairDetails_emitsSetPairDetails() public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        // TODO: use setup?

        pairDetails[0] = UniV3OracleImpl.SetPairDetailParams({
            quotePair: wethETH,
            pairDetail: UniV3OracleImpl.PairDetail({pool: address(0), period: 0})
        });
        pairDetails[1] = UniV3OracleImpl.SetPairDetailParams({
            quotePair: usdcETH,
            pairDetail: UniV3OracleImpl.PairDetail({
                pool: IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(USDC, WETH9, 30_00),
                period: 10 minutes
            })
        });

        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetPairDetails(pairDetails);
        oracle.setPairDetails(pairDetails);
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - getQuoteAmounts
    /// -----------------------------------------------------------------------

    function testFork_revertWhen_paused_getQuoteAmounts() public {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(initParams.owner);
        oracle.setPaused(true);

        vm.expectRevert(Paused.selector);
        oracle.getQuoteAmounts(quoteParams);
    }

    function testFail_getQuoteAmounts_ifConvertedPairEqual_doesntCallUniGetPool() public unpaused {
        delete quoteParams[1]; // delete usdcETH

        vm.expectCall({callee: UNISWAP_V3_FACTORY, data: ""});
        oracle.getQuoteAmounts(quoteParams);
    }

    function testFork_getQuoteAmounts_ifConvertedPairEqual_returnsBaseAmount() public unpaused {
        delete quoteParams[1]; // delete usdcETH

        uint256[] memory quoteAmounts = oracle.getQuoteAmounts(quoteParams);
        assertEq(quoteAmounts[0], quoteParams[0].baseAmount);
    }

    function testFork_revertsWhen_PoolNotSet_getQuoteAmounts() public unpaused {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(initParams.owner);

        delete pairDetails;
        pairDetails.push(
            UniV3OracleImpl.SetPairDetailParams({
                quotePair: usdcETH,
                pairDetail: UniV3OracleImpl.PairDetail({
                    pool: address(0),
                    period: 0 // no override
                })
            })
        );
        oracle.setPairDetails(pairDetails);

        vm.expectRevert(InvalidPair_PoolNotSet.selector);
        oracle.getQuoteAmounts(quoteParams);
    }

    function testFork_getQuoteAmounts_callsPoolObserveWithPeriod() public unpaused {
        address pool = IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(USDC, WETH9, 5_00);
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = 30 minutes;
        secondsAgos[1] = 0;

        vm.expectCall({callee: pool, data: abi.encodeCall(IUniswapV3PoolDerivedState.observe, (secondsAgos))});
        oracle.getQuoteAmounts(quoteParams);
    }

    function testFork_getQuoteAmounts_returnsApproximateAmount() public unpaused {
        // delete wethETH
        quoteParams[0] = quoteParams[1];
        delete quoteParams[1];

        // etherscan eth price on block
        // $1,909.49 / ETH
        // 1000 usdc -> ~0.52 eth
        uint256[] memory amounts = oracle.getQuoteAmounts(quoteParams);
        assertTrue(amounts[0] > 0.515 ether);
        assertTrue(amounts[0] < 0.525 ether);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - fuzz - setDefaultPeriod
    /// -----------------------------------------------------------------------

    function testForkFuzz_revertWhen_callerNotOwner_setDefaultPeriod(address notOwner_, uint32 newDefaultPeriod_)
        public
    {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.assume(notOwner_ != initParams.owner);
        vm.prank(notOwner_);
        vm.expectRevert(Unauthorized.selector);
        oracle.setDefaultPeriod(newDefaultPeriod_);
    }

    function testForkFuzz_setDefaultPeriod_setsDefaultPeriod(uint32 newDefaultPeriod_) public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(initParams.owner);
        oracle.setDefaultPeriod(newDefaultPeriod_);
        assertEq(oracle.defaultPeriod(), newDefaultPeriod_);
    }

    function testForkFuzz_setDefaultPeriod_emitsSetDefaultPeriod(uint32 newDefaultPeriod_) public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetDefaultPeriod(newDefaultPeriod_);
        oracle.setDefaultPeriod(newDefaultPeriod_);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz - setPairDetails
    /// -----------------------------------------------------------------------

    function testForkFuzz_revertWhen_callerNotOwner_setPairDetails(
        address notOwner_,
        UniV3OracleImpl.SetPairDetailParams[] memory newSetPairDetails_
    ) public {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.assume(notOwner_ != initParams.owner);
        vm.prank(notOwner_);
        vm.expectRevert(Unauthorized.selector);
        oracle.setPairDetails(newSetPairDetails_);
    }

    // TODO: upgrade to test array; need to prune converted duplicates
    function testForkFuzz_setPairDetails_setsPairDetails(UniV3OracleImpl.SetPairDetailParams memory newSetPairDetails_)
        public
        callerOwner
    {
        uint256 length = 1;
        UniV3OracleImpl.InitParams memory initParams = _initParams();
        UniV3OracleImpl.SetPairDetailParams[] memory newSetPairDetails = new UniV3OracleImpl.SetPairDetailParams[](1);
        newSetPairDetails[0] = newSetPairDetails_;

        vm.prank(initParams.owner);
        oracle.setPairDetails(newSetPairDetails);

        QuotePair[] memory quotePairs = new QuotePair[](length);
        UniV3OracleImpl.PairDetail[] memory newPairDetails = new UniV3OracleImpl.PairDetail[](length);
        for (uint256 i; i < length; i++) {
            quotePairs[i] = newSetPairDetails[i].quotePair;
            newPairDetails[i] = newSetPairDetails[i].pairDetail;
        }
        assertEq(oracle.getPairDetails(quotePairs), newPairDetails);
    }

    function testForkFuzz_setPairDetails_emitsSetPairDetails(
        UniV3OracleImpl.SetPairDetailParams[] memory newSetPairDetails_
    ) public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetPairDetails(newSetPairDetails_);
        oracle.setPairDetails(newSetPairDetails_);
    }

    /// -----------------------------------------------------------------------
    /// internal
    /// -----------------------------------------------------------------------

    function assertEq(UniV3OracleImpl.PairDetail[] memory a, UniV3OracleImpl.PairDetail[] memory b) internal {
        assertEq(a.length, b.length);
        for (uint256 i; i < a.length; i++) {
            assertEq(a[i], b[i]);
        }
    }

    function assertEq(UniV3OracleImpl.PairDetail memory a, UniV3OracleImpl.PairDetail memory b) internal {
        assertEq(a.pool, b.pool);
        assertEq(a.period, b.period);
    }
}
