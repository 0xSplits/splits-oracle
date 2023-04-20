// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/Base.t.sol";

import {IUniswapV3PoolDerivedState} from "v3-core/interfaces/pool/IUniswapV3PoolDerivedState.sol";

import {IUniswapV3Factory, UniV3OracleFactory} from "../src/UniV3OracleFactory.sol";
import {OracleImpl, QuotePair} from "../src/OracleImpl.sol";
import {OracleParams} from "../src/peripherals/OracleParams.sol";
import {UniV3OracleImpl} from "../src/UniV3OracleImpl.sol";

// TODO: separate out fork tests
// TODO: add fuzzing

contract UniV3OracleImplTest is BaseTest {
    using TokenUtils for address;

    error Unauthorized();
    error Paused();

    error Pool_DoesNotExist();

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    event SetDefaultFee(uint24 defaultFee);
    event SetDefaultPeriod(uint32 defaultPeriod);
    event SetDefaultScaledOfferFactor(uint32 defaultScaledOfferFactor);
    event SetPairOverrides(UniV3OracleImpl.SetPairOverrideParams[] params);

    UniV3OracleFactory oracleFactory;
    UniV3OracleImpl oracleImpl;
    UniV3OracleImpl oracle;

    QuotePair wethETH;
    QuotePair usdcETH;

    UniV3OracleImpl.SetPairOverrideParams[] pairOverrides;

    OracleImpl.QuoteParams[] quoteParams;

    function setUp() public virtual override {
        super.setUp();

        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        vm.createSelectFork(MAINNET_RPC_URL, BLOCK_NUMBER);

        // set up oracle
        oracleFactory = new UniV3OracleFactory({
            uniswapV3Factory_: IUniswapV3Factory(UNISWAP_V3_FACTORY),
            weth9_: WETH9
        });
        oracleImpl = oracleFactory.uniV3OracleImpl();

        wethETH = QuotePair({base: WETH9, quote: ETH_ADDRESS});
        usdcETH = QuotePair({base: USDC, quote: ETH_ADDRESS});

        pairOverrides.push(
            UniV3OracleImpl.SetPairOverrideParams({
                quotePair: wethETH,
                pairOverride: UniV3OracleImpl.PairOverride({
                    fee: 0, // no override
                    period: 0, // no override
                    scaledOfferFactor: 99_90_00
                })
            })
        );
        pairOverrides.push(
            UniV3OracleImpl.SetPairOverrideParams({
                quotePair: usdcETH,
                pairOverride: UniV3OracleImpl.PairOverride({
                    fee: 5_00,
                    period: 0, // no override
                    scaledOfferFactor: 0 // no override
                })
            })
        );

        oracle = oracleFactory.createUniV3Oracle(_initParams());

        quoteParams.push(OracleImpl.QuoteParams({quotePair: wethETH, baseAmount: 1 ether, data: ""}));
        quoteParams.push(
            OracleImpl.QuoteParams({
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
            defaultFee: 30_00,
            defaultPeriod: 30 minutes,
            defaultScaledOfferFactor: 99_00_00,
            pairOverrides: pairOverrides
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

    function testFork_initializer_setsDefaultFee() public callerFactory {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(address(oracleFactory));
        oracle.initializer(initParams);
        assertEq(oracle.defaultFee(), initParams.defaultFee);
    }

    function testFork_initializer_setsDefaultPeriod() public callerFactory {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(address(oracleFactory));
        oracle.initializer(initParams);
        assertEq(oracle.defaultPeriod(), initParams.defaultPeriod);
    }

    function testFork_initializer_setsDefaultScaledOfferFactor() public callerFactory {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(address(oracleFactory));
        oracle.initializer(initParams);
        assertEq(oracle.defaultScaledOfferFactor(), initParams.defaultScaledOfferFactor);
    }

    function testFork_initializer_setsPairOverrides() public callerFactory {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(address(oracleFactory));
        oracle.initializer(initParams);

        uint256 length = initParams.pairOverrides.length;
        QuotePair[] memory initQuotePairs = new QuotePair[](length);
        UniV3OracleImpl.PairOverride[] memory initPairOverrides = new UniV3OracleImpl.PairOverride[](length);
        for (uint256 i; i < length; i++) {
            initQuotePairs[i] = initParams.pairOverrides[i].quotePair;
            initPairOverrides[i] = initParams.pairOverrides[i].pairOverride;
        }
        assertEq(oracle.getPairOverrides(initQuotePairs), initPairOverrides);
    }

    function testFork_initializer_emitsOwnershipTransferred() public callerFactory {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(address(oracleFactory));
        _expectEmit();
        emit OwnershipTransferred(address(0), initParams.owner);
        oracle.initializer(initParams);
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - setDefaultFee
    /// -----------------------------------------------------------------------

    function testFork_revertWhen_callerNotOwner_setDefaultFee() public {
        uint24 newDefaultFee = 5_00;
        vm.expectRevert(Unauthorized.selector);
        oracle.setDefaultFee(newDefaultFee);
    }

    function testFork_setDefaultFee_setsDefaultFee() public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();
        uint24 newDefaultFee = 5_00;

        vm.prank(initParams.owner);
        oracle.setDefaultFee(newDefaultFee);
        assertEq(oracle.defaultFee(), newDefaultFee);
    }

    function testFork_setDefaultFee_emitsSetDefaultFee() public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();
        uint24 newDefaultFee = 5_00;

        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetDefaultFee(newDefaultFee);
        oracle.setDefaultFee(newDefaultFee);
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
    /// tests - basic - setDefaultScaledOfferFactor
    /// -----------------------------------------------------------------------

    function testFork_revertWhen_callerNotOwner_setDefaultScaledOfferFactor() public {
        uint32 newDefaultScaledOfferFactor = 98_00_00;
        vm.expectRevert(Unauthorized.selector);
        oracle.setDefaultScaledOfferFactor(newDefaultScaledOfferFactor);
    }

    function testFork_setDefaultScaledOfferFactor_setsDefaultScaledOfferFactor() public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();
        uint32 newDefaultScaledOfferFactor = 98_00_00;

        vm.prank(initParams.owner);
        oracle.setDefaultScaledOfferFactor(newDefaultScaledOfferFactor);
        assertEq(oracle.defaultScaledOfferFactor(), newDefaultScaledOfferFactor);
    }

    function testFork_setDefaultScaledOfferFactor_emitsSetDefaultScaledOfferFactor() public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();
        uint32 newDefaultScaledOfferFactor = 98_00_00;

        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetDefaultScaledOfferFactor(newDefaultScaledOfferFactor);
        oracle.setDefaultScaledOfferFactor(newDefaultScaledOfferFactor);
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - setPairOverrides
    /// -----------------------------------------------------------------------

    function testFork_revertWhen_callerNotOwner_setPairOverrides() public {
        vm.expectRevert(Unauthorized.selector);
        oracle.setPairOverrides(pairOverrides);
    }

    function testFork_setPairOverrides_setsPairOverrides() public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        pairOverrides[0] = UniV3OracleImpl.SetPairOverrideParams({
            quotePair: QuotePair({base: WETH9, quote: ETH_ADDRESS}),
            pairOverride: UniV3OracleImpl.PairOverride({fee: 0, period: 0, scaledOfferFactor: 100_00_00})
        });
        pairOverrides[1] = UniV3OracleImpl.SetPairOverrideParams({
            quotePair: QuotePair({base: USDC, quote: ETH_ADDRESS}),
            pairOverride: UniV3OracleImpl.PairOverride({fee: 30_00, period: 10 minutes, scaledOfferFactor: 0})
        });
        uint256 length = pairOverrides.length;

        vm.prank(initParams.owner);
        oracle.setPairOverrides(pairOverrides);

        QuotePair[] memory quotePairs = new QuotePair[](length);
        UniV3OracleImpl.PairOverride[] memory newPairOverrides = new UniV3OracleImpl.PairOverride[](length);
        for (uint256 i; i < length; i++) {
            quotePairs[i] = pairOverrides[i].quotePair;
            newPairOverrides[i] = pairOverrides[i].pairOverride;
        }
        assertEq(oracle.getPairOverrides(quotePairs), newPairOverrides);
    }

    function testFork_setPairOverrides_emitsSetPairOverrides() public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        // TODO: use setup?

        pairOverrides[0] = UniV3OracleImpl.SetPairOverrideParams({
            quotePair: wethETH,
            pairOverride: UniV3OracleImpl.PairOverride({fee: 0, period: 0, scaledOfferFactor: 100_00_00})
        });
        pairOverrides[1] = UniV3OracleImpl.SetPairOverrideParams({
            quotePair: usdcETH,
            pairOverride: UniV3OracleImpl.PairOverride({fee: 30_00, period: 10 minutes, scaledOfferFactor: 0})
        });

        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetPairOverrides(pairOverrides);
        oracle.setPairOverrides(pairOverrides);
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

    function testFork_getQuoteAmounts_ifConvertedPairEqual_returnsScaledOffer() public unpaused {
        delete quoteParams[1]; // delete usdcETH

        uint256[] memory quoteAmounts = oracle.getQuoteAmounts(quoteParams);
        assertEq(quoteAmounts[0], 999 * (10 ** 15));
    }

    function testFork_revertsWhen_UniPoolDoesNotExist_getQuoteAmounts() public unpaused {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(initParams.owner);

        delete pairOverrides;
        pairOverrides.push(
            UniV3OracleImpl.SetPairOverrideParams({
                quotePair: usdcETH,
                pairOverride: UniV3OracleImpl.PairOverride({
                    fee: 10,
                    period: 0, // no override
                    scaledOfferFactor: 0 // no override
                })
            })
        );
        oracle.setPairOverrides(pairOverrides);

        vm.expectRevert(Pool_DoesNotExist.selector);
        oracle.getQuoteAmounts(quoteParams);
    }

    function testFork_getQuoteAmounts_callsUniGetPool() public unpaused {
        vm.expectCall({callee: UNISWAP_V3_FACTORY, data: abi.encodeCall(IUniswapV3Factory.getPool, (USDC, WETH9, 5_00))});
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
        // w 1% discount -> ~0.5185
        uint256[] memory amounts = oracle.getQuoteAmounts(quoteParams);
        assertTrue(amounts[0] > 0.515 ether);
        assertTrue(amounts[0] < 0.525 ether);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - fuzz - setDefaultFee
    /// -----------------------------------------------------------------------

    function testForkFuzz_revertWhen_callerNotOwner_setDefaultFee(address notOwner_, uint24 newDefaultFee_) public {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.assume(notOwner_ != initParams.owner);
        vm.prank(notOwner_);
        vm.expectRevert(Unauthorized.selector);
        oracle.setDefaultFee(newDefaultFee_);
    }

    function testForkFuzz_setDefaultFee_setsDefaultFee(uint24 newDefaultFee_) public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(initParams.owner);
        oracle.setDefaultFee(newDefaultFee_);
        assertEq(oracle.defaultFee(), newDefaultFee_);
    }

    function testForkFuzz_setDefaultFee_emitsSetDefaultFee(uint24 newDefaultFee_) public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetDefaultFee(newDefaultFee_);
        oracle.setDefaultFee(newDefaultFee_);
    }

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
    /// tests - fuzz - setDefaultScaledOfferFactor
    /// -----------------------------------------------------------------------

    function testForkFuzz_revertWhen_callerNotOwner_setDefaultScaledOfferFactor(
        address notOwner_,
        uint32 newDefaultScaledOfferFactor_
    ) public {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.assume(notOwner_ != initParams.owner);
        vm.prank(notOwner_);
        vm.expectRevert(Unauthorized.selector);
        oracle.setDefaultScaledOfferFactor(newDefaultScaledOfferFactor_);
    }

    function testForkFuzz_setDefaultScaledOfferFactor_setsDefaultScaledOfferFactor(uint32 newDefaultScaledOfferFactor_)
        public
        callerOwner
    {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(initParams.owner);
        oracle.setDefaultScaledOfferFactor(newDefaultScaledOfferFactor_);
        assertEq(oracle.defaultScaledOfferFactor(), newDefaultScaledOfferFactor_);
    }

    function testForkFuzz_setDefaultScaledOfferFactor_emitsSetDefaultScaledOfferFactor(
        uint32 newDefaultScaledOfferFactor_
    ) public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetDefaultScaledOfferFactor(newDefaultScaledOfferFactor_);
        oracle.setDefaultScaledOfferFactor(newDefaultScaledOfferFactor_);
    }

    /// -----------------------------------------------------------------------
    /// tests - fuzz - setPairOverrides
    /// -----------------------------------------------------------------------

    function testForkFuzz_revertWhen_callerNotOwner_setPairOverrides(
        address notOwner_,
        UniV3OracleImpl.SetPairOverrideParams[] memory newSetPairOverrides_
    ) public {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.assume(notOwner_ != initParams.owner);
        vm.prank(notOwner_);
        vm.expectRevert(Unauthorized.selector);
        oracle.setPairOverrides(newSetPairOverrides_);
    }

    // TODO: upgrade to test array; need to prune converted duplicates
    function testForkFuzz_setPairOverrides_setsPairOverrides(
        UniV3OracleImpl.SetPairOverrideParams memory newSetPairOverrides_
    ) public callerOwner {
        uint256 length = 1;
        UniV3OracleImpl.InitParams memory initParams = _initParams();
        UniV3OracleImpl.SetPairOverrideParams[] memory newSetPairOverrides =
            new UniV3OracleImpl.SetPairOverrideParams[](1);
        newSetPairOverrides[0] = newSetPairOverrides_;

        vm.prank(initParams.owner);
        oracle.setPairOverrides(newSetPairOverrides);

        QuotePair[] memory quotePairs = new QuotePair[](length);
        UniV3OracleImpl.PairOverride[] memory newPairOverrides = new UniV3OracleImpl.PairOverride[](length);
        for (uint256 i; i < length; i++) {
            quotePairs[i] = newSetPairOverrides[i].quotePair;
            newPairOverrides[i] = newSetPairOverrides[i].pairOverride;
        }
        assertEq(oracle.getPairOverrides(quotePairs), newPairOverrides);
    }

    function testForkFuzz_setPairOverrides_emitsSetPairOverrides(
        UniV3OracleImpl.SetPairOverrideParams[] memory newSetPairOverrides_
    ) public callerOwner {
        UniV3OracleImpl.InitParams memory initParams = _initParams();

        vm.prank(initParams.owner);
        vm.expectEmit();
        emit SetPairOverrides(newSetPairOverrides_);
        oracle.setPairOverrides(newSetPairOverrides_);
    }

    /// -----------------------------------------------------------------------
    /// internal
    /// -----------------------------------------------------------------------

    function assertEq(UniV3OracleImpl.PairOverride[] memory a, UniV3OracleImpl.PairOverride[] memory b) internal {
        assertEq(a.length, b.length);
        for (uint256 i; i < a.length; i++) {
            assertEq(a[i], b[i]);
        }
    }

    function assertEq(UniV3OracleImpl.PairOverride memory a, UniV3OracleImpl.PairOverride memory b) internal {
        assertEq(a.fee, b.fee);
        assertEq(a.period, b.period);
        assertEq(a.scaledOfferFactor, b.scaledOfferFactor);
    }
}
