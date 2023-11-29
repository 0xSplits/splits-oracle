// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/Base.t.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {
    Initialized_PausableImplTest, Uninitialized_PausableImplTest
} from "splits-tests/PausableImpl/PausableImpl.t.sol";
import {QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {
    Initialized_ChainlinkOracleImplBase,
    Paused_Initialized_ChainlinkOracleImplBase,
    Uninitialized_ChainlinkOracleImplBase,
    Unpaused_Initialized_ChainlinkOracleImplBase
} from "./ChainlinkOracleImplBase.t.sol";
import {ChainlinkOracleFactory} from "src/chainlink/factory/ChainlinkOracleFactory.sol";
import {IOracle} from "../../src/interfaces/IOracle.sol";
import {OracleParams} from "../../src/peripherals/OracleParams.sol";
import {ChainlinkOracleImpl} from "src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPairDetails} from "../../src/libraries/ChainlinkPairDetails.sol";
import {ChainlinkPath} from "../../src/libraries/ChainlinkPath.sol";

contract Unintialized_ChainlinkOracleImplTest is
    Uninitialized_PausableImplTest,
    Uninitialized_ChainlinkOracleImplBase
{
    function setUp() public virtual override(Uninitialized_PausableImplTest, Uninitialized_ChainlinkOracleImplBase) {
        Uninitialized_ChainlinkOracleImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Uninitialized_PausableImplTest, Uninitialized_ChainlinkOracleImplBase)
    {
        Uninitialized_ChainlinkOracleImplBase._initialize();
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
        ChainlinkOracleImpl.InitParams calldata params_
    ) public callerNotFactory(caller_) {
        _setUpChainlinkOracleParams(params_);

        _testFork_revertWhen_callerNotFactory_initializer();
    }

    function testForkFuzz_initializer(ChainlinkOracleImpl.InitParams calldata params_) public callerFactory {
        _setUpChainlinkOracleParams(params_);
    }

    function _testFork_initializer_setsPairDetails() internal {
        ChainlinkOracleImpl.InitParams memory initParams = _initParams();
        $oracle.initializer(initParams);

        uint256 length = initParams.pairDetails.length;
        QuotePair[] memory initQuotePairs = new QuotePair[](length);
        ChainlinkOracleImpl.PairDetail[] memory initPairDetails = new ChainlinkOracleImpl.PairDetail[](length);
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
    /* function testForkFuzz_initializer_setsPairDetails(ChainlinkOracleImpl.InitParams calldata params_) */
    /*     public */
    /*     callerFactory */
    /* { */
    /*     _setUpUniV3OracleParams(params_); */

    /*     _testFork_initializer_setsPairDetails(); */
    /* } */
}

contract Initialized_ChainlinkOracleImplTest is Initialized_PausableImplTest, Initialized_ChainlinkOracleImplBase {
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    function setUp() public virtual override(Initialized_PausableImplTest, Initialized_ChainlinkOracleImplBase) {
        Initialized_ChainlinkOracleImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Initialized_PausableImplTest, Initialized_ChainlinkOracleImplBase)
    {
        Initialized_ChainlinkOracleImplBase._initialize();
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
        ChainlinkOracleImpl.SetPairDetailParams[] memory nextSetPairDetails_
    ) public callerNotOwner(notOwner_) {
        vm.expectRevert(Unauthorized.selector);
        $oracle.setPairDetails(nextSetPairDetails_);
    }

    function testFork_setPairDetails_setsPairDetails() public callerOwner {
        $oracle.setPairDetails($nextPairDetails);

        uint256 length = $nextPairDetails.length;
        QuotePair[] memory quotePairs = new QuotePair[](length);
        ChainlinkOracleImpl.PairDetail[] memory nextPairDetails = new ChainlinkOracleImpl.PairDetail[](length);
        for (uint256 i; i < length; i++) {
            quotePairs[i] = $nextPairDetails[i].quotePair;
            nextPairDetails[i] = $nextPairDetails[i].pairDetail;
        }
        assertEq($oracle.getPairDetails(quotePairs), nextPairDetails);
    }

    function testForkFuzz_setPairDetails_setsPairDetails(
        QuotePair memory quotePair_,
        ChainlinkOracleImpl.Feed memory feed_
    ) public callerOwner {
        vm.assume(feed_.staleAfter > 1 hours && feed_.mul == true && quotePair_.base != quotePair_.quote);
        ChainlinkOracleImpl.Feed[] memory feed = new ChainlinkOracleImpl.Feed[](1);
        feed[0] = feed_;
        ChainlinkOracleImpl.PairDetail memory nextPairDetail =
            ChainlinkOracleImpl.PairDetail({path: feed.getPath(), inverted: false});
        ChainlinkOracleImpl.SetPairDetailParams memory nextSetPairDetails_ =
            ChainlinkOracleImpl.SetPairDetailParams({quotePair: quotePair_, pairDetail: nextPairDetail});
        uint256 length = 1;
        ChainlinkOracleImpl.SetPairDetailParams[] memory nextSetPairDetails =
            new ChainlinkOracleImpl.SetPairDetailParams[](length);
        nextSetPairDetails[0] = nextSetPairDetails_;

        vm.mockCall(
            address(feed_.feed),
            abi.encodeWithSelector(AggregatorV3Interface.decimals.selector),
            abi.encode(feed_.decimals)
        );
        vm.expectEmit();
        emit SetPairDetails(nextSetPairDetails);
        $oracle.setPairDetails(nextSetPairDetails);

        QuotePair[] memory quotePairs = new QuotePair[](length);
        ChainlinkOracleImpl.PairDetail[] memory newPairDetails = new ChainlinkOracleImpl.PairDetail[](length);
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

    function testFork_setPairDetails_reverts_invalidFeed_StaleAfter() public callerOwner {
        ChainlinkOracleImpl.Feed[] memory feed = new ChainlinkOracleImpl.Feed[](1);
        feed[0] =
            ChainlinkOracleImpl.Feed({feed: AggregatorV3Interface(address(0)), staleAfter: 0, decimals: 0, mul: true});

        ChainlinkOracleImpl.PairDetail memory nextPairDetail =
            ChainlinkOracleImpl.PairDetail({path: feed.getPath(), inverted: false});

        ChainlinkOracleImpl.SetPairDetailParams memory nextSetPairDetails_ = ChainlinkOracleImpl.SetPairDetailParams({
            quotePair: $nextPairDetails[0].quotePair,
            pairDetail: nextPairDetail
        });

        ChainlinkOracleImpl.SetPairDetailParams[] memory nextSetPairDetails =
            new ChainlinkOracleImpl.SetPairDetailParams[](1);
        nextSetPairDetails[0] = nextSetPairDetails_;

        vm.expectRevert(ChainlinkPairDetails.InvalidFeed_StaleAfter.selector);
        $oracle.setPairDetails(nextSetPairDetails);
    }

    function testFork_setPairDetails_reverts_invalidFeed_Decimals() public callerOwner {
        ChainlinkOracleImpl.Feed[] memory feed = new ChainlinkOracleImpl.Feed[](1);

        feed[0] = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface($testing_agg),
            staleAfter: 2 hours,
            decimals: 1,
            mul: true
        });

        ChainlinkOracleImpl.PairDetail memory nextPairDetail =
            ChainlinkOracleImpl.PairDetail({path: feed.getPath(), inverted: false});

        ChainlinkOracleImpl.SetPairDetailParams memory nextSetPairDetails_ = ChainlinkOracleImpl.SetPairDetailParams({
            quotePair: $nextPairDetails[0].quotePair,
            pairDetail: nextPairDetail
        });

        ChainlinkOracleImpl.SetPairDetailParams[] memory nextSetPairDetails =
            new ChainlinkOracleImpl.SetPairDetailParams[](1);
        nextSetPairDetails[0] = nextSetPairDetails_;

        vm.expectRevert(ChainlinkPairDetails.InvalidFeed_Decimals.selector);
        $oracle.setPairDetails(nextSetPairDetails);
    }

    function testForkFuzz_setPairDetails_reverts_len_extraBytes(bytes2 extra_) public callerOwner {
        ChainlinkOracleImpl.Feed[] memory feed = new ChainlinkOracleImpl.Feed[](1);

        feed[0] = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface($testing_agg),
            staleAfter: 2 hours,
            decimals: 1,
            mul: true
        });

        ChainlinkOracleImpl.PairDetail memory nextPairDetail =
            ChainlinkOracleImpl.PairDetail({path: bytes.concat(feed.getPath(), extra_), inverted: false});

        ChainlinkOracleImpl.SetPairDetailParams memory nextSetPairDetails_ = ChainlinkOracleImpl.SetPairDetailParams({
            quotePair: $nextPairDetails[0].quotePair,
            pairDetail: nextPairDetail
        });

        ChainlinkOracleImpl.SetPairDetailParams[] memory nextSetPairDetails =
            new ChainlinkOracleImpl.SetPairDetailParams[](1);
        nextSetPairDetails[0] = nextSetPairDetails_;

        vm.expectRevert("len_extraBytes");
        $oracle.setPairDetails(nextSetPairDetails);
    }

    function testFork_setPairDetails_EmptyFeed() public callerOwner {
        bytes memory path;
        ChainlinkOracleImpl.PairDetail memory nextPairDetail =
            ChainlinkOracleImpl.PairDetail({path: path, inverted: false});

        ChainlinkOracleImpl.SetPairDetailParams memory nextSetPairDetails_ = ChainlinkOracleImpl.SetPairDetailParams({
            quotePair: $nextPairDetails[0].quotePair,
            pairDetail: nextPairDetail
        });

        ChainlinkOracleImpl.SetPairDetailParams[] memory nextSetPairDetails =
            new ChainlinkOracleImpl.SetPairDetailParams[](1);
        nextSetPairDetails[0] = nextSetPairDetails_;

        $oracle.setPairDetails(nextSetPairDetails);

        QuotePair[] memory quotePairs = new QuotePair[](1);
        quotePairs[0] = $nextPairDetails[0].quotePair;
        ChainlinkOracleImpl.PairDetail[] memory details = $oracle.getPairDetails(quotePairs);
        assertEq(details[0].path.length, 0);
    }
}

contract Paused_Initialized_ChainlinkOracleImplTest is
    Initialized_ChainlinkOracleImplTest,
    Paused_Initialized_ChainlinkOracleImplBase
{
    function setUp()
        public
        virtual
        override(Paused_Initialized_ChainlinkOracleImplBase, Initialized_ChainlinkOracleImplTest)
    {
        Paused_Initialized_ChainlinkOracleImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Initialized_ChainlinkOracleImplBase, Initialized_ChainlinkOracleImplTest)
    {
        Initialized_ChainlinkOracleImplBase._initialize();
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

contract Unpaused_Initialized_ChainlinkOracleImplTest is
    Initialized_ChainlinkOracleImplTest,
    Unpaused_Initialized_ChainlinkOracleImplBase
{
    using TokenUtils for address;
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    function setUp()
        public
        virtual
        override(Initialized_ChainlinkOracleImplBase, Initialized_ChainlinkOracleImplTest)
    {
        Initialized_ChainlinkOracleImplBase.setUp();
    }

    function _initialize()
        internal
        virtual
        override(Initialized_ChainlinkOracleImplBase, Initialized_ChainlinkOracleImplTest)
    {
        Initialized_ChainlinkOracleImplBase._initialize();
    }

    /// -----------------------------------------------------------------------
    /// getQuoteAmounts
    /// --------------------------------------------------------------------

    function testFork_getQuoteAmounts_ifConvertedPairEqual_returnsBaseAmount() public unpaused {
        uint256[] memory quoteAmounts = $oracle.getQuoteAmounts($wethQuoteParams);
        assertEq(quoteAmounts[0], $wethQuoteParams[0].baseAmount);
    }

    function testFork_revertsWhen_FeedNotSet_getQuoteAmounts() public unpaused {
        bytes memory revertData = abi.encodeWithSelector(
            ChainlinkOracleImpl.InvalidPair_FeedNotSet.selector, $mockERC20QuoteParams[0].quotePair
        );
        vm.expectRevert(revertData);
        $oracle.getQuoteAmounts($mockERC20QuoteParams);
    }

    // testStalePrice
    function testFork_revertsWhen_StalePrice_getQuoteAmounts() public unpaused {
        uint256 updatedAt = block.timestamp - (1 days + 1 seconds);
        bytes memory revertData =
            abi.encodeWithSelector(ChainlinkOracleImpl.StalePrice.selector, USDC_ETH_AGG, updatedAt);
        vm.mockCall(
            USDC_ETH_AGG,
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(0, 1 ether, 0, block.timestamp - 86401, 0)
        );
        vm.expectRevert(revertData);
        $oracle.getQuoteAmounts($usdcQuoteParams);
    }

    // testNegativePrice
    function testFork_revertsWhen_NegativePrice_getQuoteAmounts() public unpaused {
        int256 answer = -1;
        bytes memory revertData =
            abi.encodeWithSelector(ChainlinkOracleImpl.NegativePrice.selector, USDC_ETH_AGG, answer);
        vm.mockCall(
            USDC_ETH_AGG,
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(0, answer, 0, block.timestamp, 0)
        );
        vm.expectRevert(revertData);
        $oracle.getQuoteAmounts($usdcQuoteParams);
    }

    function testFork_getQuoteAmounts_returnsApproximateAmount() public unpaused {
        // etherscan eth price on block
        // $1,909.49 / ETH
        // 1000 usdc -> ~0.52 eth
        uint256[] memory amounts = $oracle.getQuoteAmounts($usdcQuoteParams);
        assertTrue(amounts[0] > 0.515 ether);
        assertTrue(amounts[0] < 0.525 ether);
    }

    function testFork_getQuoteAmountsInverted_returnsApproximateAmount() public unpaused {
        QuoteParams[] memory ethUSDCQuoteParams = new QuoteParams[](1);
        ethUSDCQuoteParams[0] =
            QuoteParams({baseAmount: 1 ether, quotePair: QuotePair({base: ETH_ADDRESS, quote: USDC}), data: ""});
        uint256[] memory amounts = $oracle.getQuoteAmounts(ethUSDCQuoteParams);
        assertApproxEqAbs(amounts[0], 1900e6, 10e6);
    }

    function testFork_getQuoteAmounts_erc20s_returnsApproximateAmount() public unpaused {
        QuoteParams[] memory quoteParams = new QuoteParams[](1);
        quoteParams[0] = QuoteParams({baseAmount: 10e18, quotePair: QuotePair({base: DAI, quote: USDC}), data: ""});
        uint256[] memory amounts = $oracle.getQuoteAmounts(quoteParams);
        assertApproxEqAbs(amounts[0], 10e6, 1e6);
    }

    function testFork_getQuoteAmounts_quoteGreaterThan18Decimals_returnsApproximateAmount() public unpaused {
        QuoteParams[] memory quoteParams = new QuoteParams[](1);
        quoteParams[0] = QuoteParams({baseAmount: 1e19, quotePair: QuotePair({base: DAI, quote: USDC}), data: ""});
        vm.mockCall(USDC, abi.encodeWithSelector(IERC20.decimals.selector), abi.encode(20));
        uint256[] memory amounts = $oracle.getQuoteAmounts(quoteParams);
        assertApproxEqAbs(amounts[0], 1e21, 1e19);
    }

    function testFork_getQuoteAmounts_feedGreaterThan18Decimals_returnsApproximateAmount()
        public
        unpaused
        callerOwner
    {
        ChainlinkOracleImpl.Feed memory USDC_ETH_FEED = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface(USDC_ETH_AGG),
            staleAfter: 86400,
            decimals: 20,
            mul: true
        });
        ChainlinkOracleImpl.Feed[] memory usdcETHPath = new ChainlinkOracleImpl.Feed[](1);
        usdcETHPath[0] = USDC_ETH_FEED;

        ChainlinkOracleImpl.SetPairDetailParams[] memory pairDetails = new ChainlinkOracleImpl.SetPairDetailParams[](1);
        pairDetails[0] = ChainlinkOracleImpl.SetPairDetailParams({
            quotePair: $usdcETH,
            pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcETHPath.getPath(), inverted: false})
        });
        vm.mockCall(USDC_ETH_AGG, abi.encodeWithSelector(AggregatorV3Interface.decimals.selector), abi.encode(20));
        $oracle.setPairDetails(pairDetails);

        (
            , /* uint80 roundId, */
            int256 answer,
            , /* uint256 startedAt, */
            ,
            /* uint80 answeredInRound */
        ) = AggregatorV3Interface(USDC_ETH_AGG).latestRoundData();

        vm.mockCall(
            USDC_ETH_AGG,
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(0, answer * 10 ** 2, 0, block.timestamp - 86400, 0)
        );

        uint256[] memory amounts = $oracle.getQuoteAmounts($usdcQuoteParams);
        assertTrue(amounts[0] > 0.515 ether);
        assertTrue(amounts[0] < 0.525 ether);
    }
}
