// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {
    Unpaused_Initialized_ChainlinkOracleImplTest,
    Initialized_ChainlinkOracleImplTest
} from "./ChainlinkOracleImpl.t.sol";
import {ChainlinkOracleL2Impl} from "src/chainlink/oracle/ChainlinkOracleL2Impl.sol";
import {ChainlinkOracleL2Factory} from "src/chainlink/factory/ChainlinkOracleL2Factory.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {IChainlinkOracleFactory} from "../../src/interfaces/IChainlinkOracleFactory.sol";
import {IOracle} from "../../src/interfaces/IOracle.sol";
import {ChainlinkOracleImpl} from "src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";
import {
    Initialized_ChainlinkOracleImplBase,
    Paused_Initialized_ChainlinkOracleImplBase,
    Uninitialized_ChainlinkOracleImplBase,
    Unpaused_Initialized_ChainlinkOracleImplBase
} from "./ChainlinkOracleImplBase.t.sol";
import {
    Initialized_PausableImplBase,
    PausableImplHarness,
    Uninitialized_PausableImplBase
} from "splits-tests/PausableImpl/PausableImplBase.t.sol";
import {ChainlinkPath} from "../../src/libraries/ChainlinkPath.sol";

contract Unpaused_Initialized_ChainlinkOracleL2ImplTest is
    Initialized_ChainlinkOracleImplTest,
    Unpaused_Initialized_ChainlinkOracleImplBase
{
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address constant SEQUENCER_FEED = 0xFdB631F5EE196F0ed6FAa767959853A9F217697D;

    address constant WETH9_ARB = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant USDC_ARB = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant USDT_ARB = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address constant DAI_ARB = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

    address constant USDC_USD_ARB_AGG = 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3;
    address constant DAI_USD_ARB_AGG = 0xc5C8E77B397E531B8EC06BFb0048328B30E9eCfB;
    address constant ETH_USD_ARB_AGG = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
    address constant USDT_USD_ARB_AGG = 0x3f3f5dF88dC9F13eac63DF89EC16ef6e7E25DdE7;

    function setUp() public override(Initialized_ChainlinkOracleImplBase, Initialized_ChainlinkOracleImplTest) {
        vm.createSelectFork(vm.rpcUrl("arbitrum"));

        Uninitialized_PausableImplBase.setUp();

        $oracleFactory = IChainlinkOracleFactory(address(new ChainlinkOracleL2Factory(WETH9_ARB, SEQUENCER_FEED)));

        /// setup feeds
        ChainlinkOracleImpl.Feed memory USDC_USD_FEED = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface(USDC_USD_ARB_AGG),
            staleAfter: 86400,
            decimals: 8,
            mul: true
        });

        ChainlinkOracleImpl.Feed memory DAI_USD_FEED = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface(DAI_USD_ARB_AGG),
            staleAfter: 86400,
            decimals: 8,
            mul: true
        });

        ChainlinkOracleImpl.Feed memory ETH_USD_FEED = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface(ETH_USD_ARB_AGG),
            staleAfter: 86400,
            decimals: 8,
            mul: false
        });

        ChainlinkOracleImpl.Feed memory USDT_USD_FEED = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface(USDT_USD_ARB_AGG),
            staleAfter: 86400,
            decimals: 8,
            mul: true
        });

        $testing_agg = USDC_USD_ARB_AGG;

        /// setup quotepairs
        $wethETH = QuotePair({base: WETH9_ARB, quote: ETH_ADDRESS});
        $usdcETH = QuotePair({base: USDC_ARB, quote: ETH_ADDRESS});
        $daiETH = QuotePair({base: DAI_ARB, quote: ETH_ADDRESS});
        $ethUSDT = QuotePair({base: ETH_ADDRESS, quote: USDT_ARB});
        $daiUSDC = QuotePair({base: DAI_ARB, quote: USDC_ARB});

        /// setup paths
        ChainlinkOracleImpl.Feed[] memory usdcETHPath = new ChainlinkOracleImpl.Feed[](2);
        usdcETHPath[0] = USDC_USD_FEED;
        usdcETHPath[1] = ETH_USD_FEED;
        ChainlinkOracleImpl.Feed[] memory daiETHPath = new ChainlinkOracleImpl.Feed[](2);
        daiETHPath[0] = DAI_USD_FEED;
        daiETHPath[1] = ETH_USD_FEED;
        ChainlinkOracleImpl.Feed[] memory usdtETHPath = new ChainlinkOracleImpl.Feed[](2);
        usdtETHPath[0] = USDT_USD_FEED;
        usdtETHPath[1] = ETH_USD_FEED;
        ChainlinkOracleImpl.Feed[] memory daiUSDCPath = new ChainlinkOracleImpl.Feed[](2);
        daiUSDCPath[0] = DAI_USD_FEED;
        daiUSDCPath[1] = USDC_USD_FEED;

        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: $usdcETH,
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcETHPath.getPath(), inverted: false})
            })
        );

        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: $daiETH,
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiETHPath.getPath(), inverted: false})
            })
        );

        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: $ethUSDT,
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtETHPath.getPath(), inverted: false})
            })
        );

        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: $daiUSDC,
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiUSDCPath.getPath(), inverted: false})
            })
        );

        $nextPairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: $usdcETH,
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcETHPath.getPath(), inverted: false})
            })
        );

        $wethQuoteParams.push(QuoteParams({quotePair: $wethETH, baseAmount: 1 ether, data: ""}));

        $usdcQuoteParams.push(
            QuoteParams({
                quotePair: $usdcETH,
                baseAmount: 10 ** 9, // $1,000 usc ~= 0.5 eth
                data: ""
            })
        );

        $ethUSDTQuoteParams.push(
            QuoteParams({
                quotePair: $ethUSDT,
                baseAmount: 10 ** 18, // $1,000 usc ~= 0.5 eth
                data: ""
            })
        );

        $daiQuoteParams.push(
            QuoteParams({
                quotePair: $daiETH,
                baseAmount: 10 ** 21, // $1,000 dai ~= 0.5 eth
                data: ""
            })
        );

        _setUpChainlinkOracleImplState({
            oracle_: address($oracleFactory.oracleImplementation()),
            owner_: users.alice,
            paused_: false,
            notFactory_: users.eve,
            pairDetails_: $pairDetails,
            nextPairDetails_: $nextPairDetails,
            wethQuoteParams_: $wethQuoteParams,
            usdcQuoteParams_: $usdcQuoteParams,
            daiQuoteParams_: $daiQuoteParams,
            mockERC20QuoteParams_: $mockERC20QuoteParams
        });
        _initialize();
    }

    function _initialize()
        internal
        override(Initialized_ChainlinkOracleImplBase, Initialized_ChainlinkOracleImplTest)
    {
        Initialized_ChainlinkOracleImplBase._initialize();
    }

    function testForkFuzz_revertWhen_sequencerDown(QuoteParams[] calldata quoteParams_) public unpaused {
        vm.mockCall(
            SEQUENCER_FEED,
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(0, 1, 0, 0, 0)
        );

        vm.expectRevert(abi.encodeWithSelector(ChainlinkOracleL2Impl.SequencerDown.selector));
        $oracle.getQuoteAmounts(quoteParams_);
    }

    function testForkFuzz_revertWhen_gracePeriodNotOver(QuoteParams[] calldata quoteParams_) public unpaused {
        vm.mockCall(
            SEQUENCER_FEED,
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(0, 0, block.timestamp - 100, 0, 0)
        );

        vm.expectRevert(abi.encodeWithSelector(ChainlinkOracleL2Impl.GracePeriodNotOver.selector));
        $oracle.getQuoteAmounts(quoteParams_);
    }
}
