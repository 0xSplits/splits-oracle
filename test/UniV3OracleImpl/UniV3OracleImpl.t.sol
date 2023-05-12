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

import {
    Initialized_UniV3OracleImplBase,
    Paused_Initialized_UniV3OracleImplBase,
    Uninitialized_UniV3OracleImplBase,
    Unpaused_Initialized_UniV3OracleImplBase
} from "./UniV3OracleImplBase.t.sol";

import {UniV3OracleFactory} from "../../src/UniV3OracleFactory.sol";
import {IOracle} from "../../src/interfaces/IOracle.sol";
import {OracleParams} from "../../src/peripherals/OracleParams.sol";
import {UniV3OracleImpl} from "../../src/UniV3OracleImpl.sol";

contract Unintialized_UniV3OracleImplTest is Uninitialized_PausableImplTest, Uninitialized_UniV3OracleImplBase {
    function setUp() public virtual override(Uninitialized_PausableImplTest, Uninitialized_UniV3OracleImplBase) {
        Uninitialized_UniV3OracleImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Uninitialized_PausableImplTest, Uninitialized_UniV3OracleImplBase)
    {
        Uninitialized_UniV3OracleImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// initializer
    /// -----------------------------------------------------------------------

    function testFork_revertWhen_callerNotFactory_initializer() public callerNotFactory($notFactory) {
        vm.expectRevert(Unauthorized.selector);
        $oracle.initializer(_initParams());
    }

    function testForkFuzz_revertWhen_callerNotFactory_initializer(
        address caller_,
        UniV3OracleImpl.InitParams calldata params_
    ) public callerNotFactory(caller_) {
        _setUpUniV3OracleParams(params_);

        testFork_revertWhen_callerNotFactory_initializer();
    }

    function testFork_initializer_setsDefaultPeriod() public callerFactory {
        $oracle.initializer(_initParams());
        assertEq($oracle.defaultPeriod(), $defaultPeriod);
    }

    function testForkFuzz_initializer_setsDefaultPeriod(UniV3OracleImpl.InitParams calldata params_)
        public
        callerFactory
    {
        _setUpUniV3OracleParams(params_);
        testFork_initializer_setsDefaultPeriod();
    }

    function testFork_initializer_setsPairDetails() public callerFactory {
        UniV3OracleImpl.InitParams memory initParams = _initParams();
        $oracle.initializer(initParams);

        uint256 length = initParams.pairDetails.length;
        QuotePair[] memory initQuotePairs = new QuotePair[](length);
        UniV3OracleImpl.PairDetail[] memory initPairDetails = new UniV3OracleImpl.PairDetail[](length);
        for (uint256 i; i < length; i++) {
            initQuotePairs[i] = initParams.pairDetails[i].quotePair;
            initPairDetails[i] = initParams.pairDetails[i].pairDetail;
        }
        assertEq($oracle.getPairDetails(initQuotePairs), initPairDetails);
    }

    function testForkFuzz_initializer_setsPairDetails(UniV3OracleImpl.InitParams calldata params_)
        public
        callerFactory
    {
        _setUpUniV3OracleParams(params_);
        testFork_initializer_setsPairDetails();
    }
}

contract Initialized_UniV3OracleImplTest is Initialized_PausableImplTest, Initialized_UniV3OracleImplBase {
    function setUp() public virtual override(Initialized_PausableImplTest, Initialized_UniV3OracleImplBase) {
        Initialized_UniV3OracleImplBase.setUp();
    }

    function _initialize() internal virtual override(Initialized_PausableImplTest, Initialized_UniV3OracleImplBase) {
        Initialized_UniV3OracleImplBase._initialize();
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
        UniV3OracleImpl.SetPairDetailParams[] memory nextSetPairDetails_
    ) public callerNotOwner(notOwner_) {
        vm.expectRevert(Unauthorized.selector);
        $oracle.setPairDetails(nextSetPairDetails_);
    }

    function testFork_setPairDetails_setsPairDetails() public callerOwner {
        $oracle.setPairDetails($nextPairDetails);

        uint256 length = $nextPairDetails.length;
        QuotePair[] memory quotePairs = new QuotePair[](length);
        UniV3OracleImpl.PairDetail[] memory nextPairDetails = new UniV3OracleImpl.PairDetail[](length);
        for (uint256 i; i < length; i++) {
            quotePairs[i] = $nextPairDetails[i].quotePair;
            nextPairDetails[i] = $nextPairDetails[i].pairDetail;
        }
        assertEq($oracle.getPairDetails(quotePairs), nextPairDetails);
    }

    function testForkFuzz_setPairDetails_setsPairDetails(UniV3OracleImpl.SetPairDetailParams memory nextSetPairDetails_)
        public
        callerOwner
    {
        uint256 length = 1;
        UniV3OracleImpl.SetPairDetailParams[] memory nextSetPairDetails =
            new UniV3OracleImpl.SetPairDetailParams[](length);
        nextSetPairDetails[0] = nextSetPairDetails_;

        $oracle.setPairDetails(nextSetPairDetails);

        QuotePair[] memory quotePairs = new QuotePair[](length);
        UniV3OracleImpl.PairDetail[] memory newPairDetails = new UniV3OracleImpl.PairDetail[](length);
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
        UniV3OracleImpl.SetPairDetailParams[] memory nextSetPairDetails_
    ) public callerOwner {
        vm.expectEmit();
        emit SetPairDetails(nextSetPairDetails_);
        $oracle.setPairDetails(nextSetPairDetails_);
    }
}

contract Paused_Initialized_UniV3OracleImplTest is
    Initialized_UniV3OracleImplTest,
    Paused_Initialized_UniV3OracleImplBase
{
    function setUp() public virtual override(Paused_Initialized_UniV3OracleImplBase, Initialized_UniV3OracleImplTest) {
        Paused_Initialized_UniV3OracleImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Initialized_UniV3OracleImplBase, Initialized_UniV3OracleImplTest)
    {
        Initialized_UniV3OracleImplBase._initialize();
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
        changePrank(caller_);
        vm.expectRevert(Paused.selector);
        $oracle.getQuoteAmounts(quoteParams_);
    }
}

contract Unpaused_Initialized_UniV3OracleImplTest is
    Initialized_UniV3OracleImplTest,
    Unpaused_Initialized_UniV3OracleImplBase
{
    using TokenUtils for address;

    function setUp() public virtual override(Initialized_UniV3OracleImplBase, Initialized_UniV3OracleImplTest) {
        Initialized_UniV3OracleImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Initialized_UniV3OracleImplBase, Initialized_UniV3OracleImplTest)
    {
        Initialized_UniV3OracleImplBase._initialize();
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
        address pool = IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(USDC, WETH9, 5_00);
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = $defaultPeriod;
        secondsAgos[1] = 0;

        vm.expectCall({callee: pool, data: abi.encodeCall(IUniswapV3PoolDerivedState.observe, (secondsAgos))});
        $oracle.getQuoteAmounts($usdcQuoteParams);
    }

    function testFork_getQuoteAmounts_callsPoolObserveWithDetailsPeriod() public unpaused {
        address pool = IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(DAI, WETH9, 5_00);
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = 60 minutes;
        secondsAgos[1] = 0;

        vm.expectCall({callee: pool, data: abi.encodeCall(IUniswapV3PoolDerivedState.observe, (secondsAgos))});
        $oracle.getQuoteAmounts($daiQuoteParams);
    }

    function testFork_getQuoteAmounts_returnsApproximateAmount() public unpaused {
        // etherscan eth price on block
        // $1,909.49 / ETH
        // 1000 usdc -> ~0.52 eth
        uint256[] memory amounts = $oracle.getQuoteAmounts($usdcQuoteParams);
        assertTrue(amounts[0] > 0.515 ether);
        assertTrue(amounts[0] < 0.525 ether);
    }
}
