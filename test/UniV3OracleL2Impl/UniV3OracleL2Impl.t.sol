// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/Base.t.sol";

import
/* Initialized_PausableImplBase, */
{
    Initialized_PausableImplTest,
    /*     Uninitialized_PausableImplBase, */
    Uninitialized_PausableImplTest
} from "splits-tests/PausableImpl/PausableImpl.t.sol";
import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3PoolDerivedState} from "v3-core/interfaces/pool/IUniswapV3PoolDerivedState.sol";
import {QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {
    Initialized_UniV3OracleL2ImplBase,
    Paused_Initialized_UniV3OracleL2ImplBase,
    Uninitialized_UniV3OracleL2ImplBase,
    Unpaused_Initialized_UniV3OracleL2ImplBase
} from "./UniV3OracleL2ImplBase.t.sol";

import {UniV3OracleL2Factory} from "../../src/UniV3OracleL2Factory.sol";
import {IOracle} from "../../src/interfaces/IOracle.sol";
import {OracleParams} from "../../src/peripherals/OracleParams.sol";
import {UniV3OracleL2Impl} from "../../src/UniV3OracleL2Impl.sol";

contract Unintialized_UniV3OracleL2ImplTest is Uninitialized_PausableImplTest, Uninitialized_UniV3OracleL2ImplBase {
    function setUp() public virtual override(Uninitialized_PausableImplTest, Uninitialized_UniV3OracleL2ImplBase) {
        Uninitialized_UniV3OracleL2ImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Uninitialized_PausableImplTest, Uninitialized_UniV3OracleL2ImplBase)
    {
        Uninitialized_UniV3OracleL2ImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// initializer
    /// -----------------------------------------------------------------------

    function _testFork_revertWhen_callerNotFactory_initializer() internal {
        vm.expectRevert(Unauthorized.selector);
        $oracle.initializer(_initParams());
    }

    function testFork_revertWhen_callerNotFactory_initializer() public callerNotFactory($notFactory) {
        _testFork_revertWhen_callerNotFactory_initializer();
    }

    function testForkFuzz_revertWhen_callerNotFactory_initializer(
        address caller_,
        UniV3OracleL2Impl.InitParams calldata params_
    ) public callerNotFactory(caller_) {
        _setUpUniV3OracleParams(params_);

        _testFork_revertWhen_callerNotFactory_initializer();
    }

    function _testFork_initializer_setsDefaultPeriod() internal {
        $oracle.initializer(_initParams());
        assertEq($oracle.defaultPeriod(), $defaultPeriod);
    }

    function testFork_initializer_setsDefaultPeriod() public callerFactory {
        _testFork_initializer_setsDefaultPeriod();
    }

    function testForkFuzz_initializer_setsDefaultPeriod(UniV3OracleL2Impl.InitParams calldata params_)
        public
        callerFactory
    {
        _setUpUniV3OracleParams(params_);

        _testFork_initializer_setsDefaultPeriod();
    }

    function _testFork_initializer_setsPairDetails() internal {
        UniV3OracleL2Impl.InitParams memory initParams = _initParams();
        $oracle.initializer(initParams);

        uint256 length = initParams.pairDetails.length;
        QuotePair[] memory initQuotePairs = new QuotePair[](length);
        UniV3OracleL2Impl.PairDetail[] memory initPairDetails = new UniV3OracleL2Impl.PairDetail[](length);
        for (uint256 i; i < length; i++) {
            initQuotePairs[i] = initParams.pairDetails[i].quotePair;
            initPairDetails[i] = initParams.pairDetails[i].pairDetail;
        }
        assertEq($oracle.getPairDetails(initQuotePairs), initPairDetails);
    }

    function testFork_initializer_setsPairDetails() public callerFactory {
        _testFork_initializer_setsPairDetails();
    }

    // remove converted, sorted duplicate pairs in params_
    /* function testForkFuzz_initializer_setsPairDetails(UniV3OracleL2Impl.InitParams calldata params_) */
    /*     public */
    /*     callerFactory */
    /* { */
    /*     _setUpUniV3OracleParams(params_); */

    /*     _testFork_initializer_setsPairDetails(); */
    /* } */
}

contract Initialized_UniV3OracleL2ImplTest is Initialized_PausableImplTest, Initialized_UniV3OracleL2ImplBase {
    function setUp() public virtual override(Initialized_PausableImplTest, Initialized_UniV3OracleL2ImplBase) {
        Initialized_UniV3OracleL2ImplBase.setUp();
    }

    function _initialize() internal virtual override(Initialized_PausableImplTest, Initialized_UniV3OracleL2ImplBase) {
        Initialized_UniV3OracleL2ImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// setDefaultPeriod
    /// -----------------------------------------------------------------------

    function testFork_revertWhen_callerNotOwner_setDefaultPeriod() public callerNotOwner($notOwner) {
        vm.expectRevert(Unauthorized.selector);
        $oracle.setDefaultPeriod($nextDefaultPeriod);
    }

    function testForkFuzz_revertWhen_callerNotOwner_setDefaultPeriod(address notOwner_, uint32 nextDefaultPeriod_)
        public
        callerNotOwner(notOwner_)
    {
        vm.expectRevert(Unauthorized.selector);
        $oracle.setDefaultPeriod(nextDefaultPeriod_);
    }

    function testFork_setDefaultPeriod_setsDefaultPeriod() public callerOwner {
        $oracle.setDefaultPeriod($nextDefaultPeriod);
        assertEq($oracle.defaultPeriod(), $nextDefaultPeriod);
    }

    function testForkFuzz_setDefaultPeriod_setsDefaultPeriod(uint32 nextDefaultPeriod_) public callerOwner {
        $oracle.setDefaultPeriod(nextDefaultPeriod_);
        assertEq($oracle.defaultPeriod(), nextDefaultPeriod_);
    }

    function testFork_setDefaultPeriod_emitsSetDefaultPeriod() public callerOwner {
        vm.expectEmit();
        emit SetDefaultPeriod($nextDefaultPeriod);
        $oracle.setDefaultPeriod($nextDefaultPeriod);
    }

    function testForkFuzz_setDefaultPeriod_emitsSetDefaultPeriod(uint32 nextDefaultPeriod_) public callerOwner {
        vm.expectEmit();
        emit SetDefaultPeriod(nextDefaultPeriod_);
        $oracle.setDefaultPeriod(nextDefaultPeriod_);
    }

    /// -----------------------------------------------------------------------
    /// setPairDetails
    /// -----------------------------------------------------------------------

    function testFork_revertWhen_callerNotOwner_setPairDetails() public callerNotOwner($notOwner) {
        vm.expectRevert(Unauthorized.selector);
        $oracle.setPairDetails($nextPairDetails);
    }

    function testForkFuzz_revertWhen_callerNotOwner_setPairDetails(
        address notOwner_,
        UniV3OracleL2Impl.SetPairDetailParams[] memory nextSetPairDetails_
    ) public callerNotOwner(notOwner_) {
        vm.expectRevert(Unauthorized.selector);
        $oracle.setPairDetails(nextSetPairDetails_);
    }

    function testFork_setPairDetails_setsPairDetails() public callerOwner {
        $oracle.setPairDetails($nextPairDetails);

        uint256 length = $nextPairDetails.length;
        QuotePair[] memory quotePairs = new QuotePair[](length);
        UniV3OracleL2Impl.PairDetail[] memory nextPairDetails = new UniV3OracleL2Impl.PairDetail[](length);
        for (uint256 i; i < length; i++) {
            quotePairs[i] = $nextPairDetails[i].quotePair;
            nextPairDetails[i] = $nextPairDetails[i].pairDetail;
        }
        assertEq($oracle.getPairDetails(quotePairs), nextPairDetails);
    }

    function testForkFuzz_setPairDetails_setsPairDetails(
        UniV3OracleL2Impl.SetPairDetailParams memory nextSetPairDetails_
    ) public callerOwner {
        uint256 length = 1;
        UniV3OracleL2Impl.SetPairDetailParams[] memory nextSetPairDetails =
            new UniV3OracleL2Impl.SetPairDetailParams[](length);
        nextSetPairDetails[0] = nextSetPairDetails_;

        $oracle.setPairDetails(nextSetPairDetails);

        QuotePair[] memory quotePairs = new QuotePair[](length);
        UniV3OracleL2Impl.PairDetail[] memory newPairDetails = new UniV3OracleL2Impl.PairDetail[](length);
        for (uint256 i; i < length; i++) {
            quotePairs[i] = nextSetPairDetails[i].quotePair;
            newPairDetails[i] = nextSetPairDetails[i].pairDetail;
        }
        assertEq($oracle.getPairDetails(quotePairs), newPairDetails);
    }

    function testFork_setPairDetails_emitsSetPairDetails() public callerOwner {
        vm.expectEmit();
        emit SetPairDetails($nextPairDetails);
        $oracle.setPairDetails($nextPairDetails);
    }

    function testForkFuzz_setPairDetails_emitsSetPairDetails(
        UniV3OracleL2Impl.SetPairDetailParams[] memory nextSetPairDetails_
    ) public callerOwner {
        vm.expectEmit();
        emit SetPairDetails(nextSetPairDetails_);
        $oracle.setPairDetails(nextSetPairDetails_);
    }
}

contract Paused_Initialized_UniV3OracleL2ImplTest is
    Initialized_UniV3OracleL2ImplTest,
    Paused_Initialized_UniV3OracleL2ImplBase
{
    function setUp()
        public
        virtual
        override(Paused_Initialized_UniV3OracleL2ImplBase, Initialized_UniV3OracleL2ImplTest)
    {
        Paused_Initialized_UniV3OracleL2ImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Initialized_UniV3OracleL2ImplBase, Initialized_UniV3OracleL2ImplTest)
    {
        Initialized_UniV3OracleL2ImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// getQuoteAmounts
    /// -----------------------------------------------------------------------

    function testFork_revertWhen_paused_getQuoteAmounts() public paused {
        vm.expectRevert(Paused.selector);
        $oracle.getQuoteAmounts($usdcQuoteParams);
    }

    function testForkFuzz_revertWhen_paused_getQuoteAmounts(address caller_, QuoteParams[] calldata quoteParams_)
        public
        paused
    {
        vm.startPrank(caller_);
        vm.expectRevert(Paused.selector);
        $oracle.getQuoteAmounts(quoteParams_);
    }
}

contract Unpaused_Initialized_UniV3OracleL2ImplTest is
    Initialized_UniV3OracleL2ImplTest,
    Unpaused_Initialized_UniV3OracleL2ImplBase
{
    using TokenUtils for address;

    function setUp() public virtual override(Initialized_UniV3OracleL2ImplBase, Initialized_UniV3OracleL2ImplTest) {
        Initialized_UniV3OracleL2ImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Initialized_UniV3OracleL2ImplBase, Initialized_UniV3OracleL2ImplTest)
    {
        Initialized_UniV3OracleL2ImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// getQuoteAmounts
    /// -----------------------------------------------------------------------

    function testFail_getQuoteAmounts_ifConvertedPairEqual_doesntCallUniGetPool() public unpaused {
        vm.expectCall({callee: UNISWAP_V3_FACTORY, data: ""});
        $oracle.getQuoteAmounts($wethQuoteParams);
    }

    function testFork_getQuoteAmounts_ifConvertedPairEqual_returnsBaseAmount() public unpaused {
        uint256[] memory quoteAmounts = $oracle.getQuoteAmounts($wethQuoteParams);
        assertEq(quoteAmounts[0], $wethQuoteParams[0].baseAmount);
    }

    function testFork_revertsWhen_PoolNotSet_getQuoteAmounts() public unpaused {
        vm.expectRevert(InvalidPair_PoolNotSet.selector);
        $oracle.getQuoteAmounts($mockERC20QuoteParams);
    }

    function testFork_getQuoteAmounts_callsPoolObserveWithDefaultPeriod() public unpaused {
        address pool = IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(USDC_ARB, WETH9_ARB, 5_00);
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = $defaultPeriod;
        secondsAgos[1] = 0;

        vm.expectCall({callee: pool, data: abi.encodeCall(IUniswapV3PoolDerivedState.observe, (secondsAgos))});
        $oracle.getQuoteAmounts($usdcQuoteParams);
    }

    function testFork_getQuoteAmounts_callsPoolObserveWithDetailsPeriod() public unpaused {
        address pool = IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(DAI_ARB, WETH9_ARB, 30_00);
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = 60 minutes;
        secondsAgos[1] = 0;

        vm.expectCall({callee: pool, data: abi.encodeCall(IUniswapV3PoolDerivedState.observe, (secondsAgos))});
        $oracle.getQuoteAmounts($daiQuoteParams);
    }

    function testFork_getQuoteAmounts_returnsApproximateAmount() public unpaused {
        uint256[] memory amounts = $oracle.getQuoteAmounts($usdcQuoteParams);
        assertTrue(amounts[0] > 0.489 ether);
        assertTrue(amounts[0] < 0.491 ether);
    }

    function testForkFuzz_revertWhen_sequencerDown(QuoteParams[] calldata quoteParams_) public unpaused {
        vm.mockCall(
            SEQUENCER_FEED,
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(0, 1, 0, 0, 0)
        );

        vm.expectRevert(abi.encodeWithSelector(UniV3OracleL2Impl.SequencerDown.selector));
        $oracle.getQuoteAmounts(quoteParams_);
    }

    function testForkFuzz_revertWhen_gracePeriodNotOver(QuoteParams[] calldata quoteParams_) public unpaused {
        vm.mockCall(
            SEQUENCER_FEED,
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(0, 0, block.timestamp - 100, 0, 0)
        );

        vm.expectRevert(abi.encodeWithSelector(UniV3OracleL2Impl.GracePeriodNotOver.selector));
        $oracle.getQuoteAmounts(quoteParams_);
    }
}
