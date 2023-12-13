// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {QuotePair} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultChainlinkOracleL2.base.s.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultChainlinkOracleArbitrumScript is CreateDefaultOracleBaseScript {
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address constant WETH9 = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant ARB = 0x912CE59144191C1204E64559FE8253a0e49E6548;
    address constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant USDCE = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address constant USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address constant WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address constant WSTETH = 0x0fBcbaEA96Ce0cF7Ee00A8c19c3ab6f5Dc8E1921;
    address constant GMX = 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a;
    address constant LINK = 0xf97f4df75117a78c1A5a0DBb814Af92458539FB4;
    address constant PENDLE = 0x0c880f6761F1af8d9Aa9C466984b80DAb9a8c9e8;
    address constant RDNT = 0x3082CC23568eA640225c2467653dB90e9250AaA0;

    AggregatorV3Interface constant DAI_USD_FEED = AggregatorV3Interface(0xc5C8E77B397E531B8EC06BFb0048328B30E9eCfB);
    uint24 constant DAI_USD_STALEAFTER = 1 days;
    uint8 constant DAI_USD_DECIMALS = 8;

    AggregatorV3Interface constant ETH_USD_FEED = AggregatorV3Interface(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612);
    uint24 constant ETH_USD_STALEAFTER = 1200;
    uint8 constant ETH_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDC_USD_FEED = AggregatorV3Interface(0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3);
    uint24 constant USDC_USD_STALEAFTER = 1 days;
    uint8 constant USDC_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDT_USD_FEED = AggregatorV3Interface(0x3f3f5dF88dC9F13eac63DF89EC16ef6e7E25DdE7);
    uint24 constant USDT_USD_STALEAFTER = 1 days;
    uint8 constant USDT_USD_DECIMALS = 8;

    AggregatorV3Interface constant WBTC_USD_FEED = AggregatorV3Interface(0xd0C7101eACbB49F3deCcCc166d238410D6D46d57);
    uint24 constant WBTC_USD_STALEAFTER = 1 days;
    uint8 constant WBTC_USD_DECIMALS = 8;

    AggregatorV3Interface constant WSTETH_ETH_FEED = AggregatorV3Interface(0xb523AE262D20A936BC152e6023996e46FDC2A95D);
    uint24 constant WSTETH_ETH_STALEAFTER = 1 days;
    uint8 constant WSTETH_ETH_DECIMALS = 18;

    AggregatorV3Interface constant ARB_USD_FEED = AggregatorV3Interface(0xb2A824043730FE05F3DA2efaFa1CBbe83fa548D6);
    uint24 constant ARB_USD_STALEAFTER = 1 days;
    uint8 constant ARB_USD_DECIMALS = 8;

    AggregatorV3Interface constant GMX_USD_FEED = AggregatorV3Interface(0xDB98056FecFff59D032aB628337A4887110df3dB);
    uint24 constant GMX_USD_STALEAFTER = 1 days;
    uint8 constant GMX_USD_DECIMALS = 8;

    AggregatorV3Interface constant LINK_USD_FEED = AggregatorV3Interface(0x86E53CF1B870786351Da77A57575e79CB55812CB);
    uint24 constant LINK_USD_STALEAFTER = 1 hours;
    uint8 constant LINK_USD_DECIMALS = 8;

    AggregatorV3Interface constant PENDLE_USD_FEED = AggregatorV3Interface(0x66853E19d73c0F9301fe099c324A1E9726953433);
    uint24 constant PENDLE_USD_STALEAFTER = 1 days;
    uint8 constant PENDLE_USD_DECIMALS = 8;

    AggregatorV3Interface constant RDNT_USD_FEED = AggregatorV3Interface(0x20d0Fcab0ECFD078B036b6CAf1FaC69A6453b352);
    uint24 constant RDNT_USD_STALEAFTER = 1 days;
    uint8 constant RDNT_USD_DECIMALS = 8;

    /**
     * Pairs:
     * 0: USDT/USDC
     * 1: USDT/DAI
     * 2: USDT/WETH
     * 3: USDT/WBTC
     * 4: USDT/USDCE
     * 5: USDT/ARB
     * 6: USDT/GMX
     * 7: USDT/LINK
     * 8: USDT/PENDLE
     * 9: USDT/RDNT
     * 10: USDT/WSTETH
     * 11: USDC/DAI
     * 12: USDC/WETH
     * 13: USDC/WBTC
     * 14: USDC/USDCE
     * 15: USDC/ARB
     * 16: USDC/GMX
     * 17: USDC/LINK
     * 18: USDC/PENDLE
     * 19: USDC/RDNT
     * 20: USDC/WSTETH
     * 21: DAI/WETH
     * 22: DAI/WBTC
     * 23: DAI/USDCE
     * 24: DAI/ARB
     * 25: DAI/GMX
     * 26: DAI/LINK
     * 27: DAI/PENDLE
     * 28: DAI/RDNT
     * 29: DAI/WSTETH
     * 30: WETH/WBTC
     * 31: WETH/USDCE
     * 32: WETH/ARB
     * 33: WETH/GMX
     * 34: WETH/LINK
     * 35: WETH/PENDLE
     * 36: WETH/RDNT
     * 37: WETH/WSTETH
     * 38: WBTC/USDCE
     * 39: WBTC/ARB
     * 40: WBTC/GMX
     * 41: WBTC/LINK
     * 42: WBTC/PENDLE
     * 43: WBTC/RDNT
     * 44: WBTC/WSTETH
     * 45: USDCE/ARB
     * 46: USDCE/GMX
     * 47: USDCE/LINK
     * 48: USDCE/PENDLE
     * 49: USDCE/RDNT
     * 50: USDCE/WSTETH
     * 51: ARB/GMX
     * 52: ARB/LINK
     * 53: ARB/PENDLE
     * 54: ARB/RDNT
     * 55: ARB/WSTETH
     * 56: GMX/LINK
     * 57: GMX/PENDLE
     * 58: GMX/RDNT
     * 59: GMX/WSTETH
     * 60: LINK/PENDLE
     * 61: LINK/RDNT
     * 62: LINK/WSTETH
     * 63: PENDLE/RDNT
     * 64: PENDLE/WSTETH
     * 65: RDNT/WSTETH
     */

    function setUp() public {
        $sequencerFeed = 0xFdB631F5EE196F0ed6FAa767959853A9F217697D;
        $weth9 = WETH9;

        $owner = address(0);
        $paused = false;

        setUpPairDetails();
    }

    function setUpPairDetails() private {
        //0: USDT/USDC
        ChainlinkOracleImpl.Feed[] memory usdtUsdcFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtUsdcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtUsdcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: USDC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtUsdcFeeds.getPath(), inverted: false})
            })
        );

        //1: USDT/DAI
        ChainlinkOracleImpl.Feed[] memory usdtDaiFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtDaiFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtDaiFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: DAI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtDaiFeeds.getPath(), inverted: false})
            })
        );

        //2: USDT/WETH
        ChainlinkOracleImpl.Feed[] memory usdtWethFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtWethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: WETH9}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtWethFeeds.getPath(), inverted: false})
            })
        );

        //3: USDT/WBTC
        ChainlinkOracleImpl.Feed[] memory usdtWbtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtWbtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtWbtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: WBTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtWbtcFeeds.getPath(), inverted: false})
            })
        );

        //4: USDT/USDCE
        ChainlinkOracleImpl.Feed[] memory usdtUsdceFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtUsdceFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtUsdceFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: USDCE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtUsdceFeeds.getPath(), inverted: false})
            })
        );

        //5: USDT/ARB
        ChainlinkOracleImpl.Feed[] memory usdtArbFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtArbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtArbFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ARB_USD_FEED,
            decimals: ARB_USD_DECIMALS,
            staleAfter: ARB_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: ARB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtArbFeeds.getPath(), inverted: false})
            })
        );

        //6: USDT/GMX
        ChainlinkOracleImpl.Feed[] memory usdtGmxFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtGmxFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtGmxFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: GMX}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtGmxFeeds.getPath(), inverted: false})
            })
        );

        //7: USDT/LINK
        ChainlinkOracleImpl.Feed[] memory usdtLinkFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtLinkFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtLinkFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: LINK_USD_FEED,
            decimals: LINK_USD_DECIMALS,
            staleAfter: LINK_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: LINK}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtLinkFeeds.getPath(), inverted: false})
            })
        );

        //8: USDT/PENDLE
        ChainlinkOracleImpl.Feed[] memory usdtPendleFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtPendleFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtPendleFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: PENDLE_USD_FEED,
            decimals: PENDLE_USD_DECIMALS,
            staleAfter: PENDLE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: PENDLE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtPendleFeeds.getPath(), inverted: false})
            })
        );

        //9: USDT/RDNT
        ChainlinkOracleImpl.Feed[] memory usdtRdntFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtRdntFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtRdntFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RDNT_USD_FEED,
            decimals: RDNT_USD_DECIMALS,
            staleAfter: RDNT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: RDNT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtRdntFeeds.getPath(), inverted: false})
            })
        );

        //10: USDT/WSTETH
        ChainlinkOracleImpl.Feed[] memory usdtWstethFeeds = new ChainlinkOracleImpl.Feed[](3);
        usdtWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        usdtWstethFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtWstethFeeds.getPath(), inverted: false})
            })
        );

        //11: USDC/DAI
        ChainlinkOracleImpl.Feed[] memory usdcDaiFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcDaiFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcDaiFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: DAI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcDaiFeeds.getPath(), inverted: false})
            })
        );

        //12: USDC/WETH
        ChainlinkOracleImpl.Feed[] memory usdcWethFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcWethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: WETH9}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcWethFeeds.getPath(), inverted: false})
            })
        );

        //13: USDC/WBTC
        ChainlinkOracleImpl.Feed[] memory usdcWbtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcWbtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcWbtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: WBTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcWbtcFeeds.getPath(), inverted: false})
            })
        );

        //14: USDC/USDCE
        ChainlinkOracleImpl.Feed[] memory usdcUsdceFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcUsdceFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcUsdceFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: USDCE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcUsdceFeeds.getPath(), inverted: false})
            })
        );

        //15: USDC/ARB
        ChainlinkOracleImpl.Feed[] memory usdcArbFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcArbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcArbFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ARB_USD_FEED,
            decimals: ARB_USD_DECIMALS,
            staleAfter: ARB_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: ARB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcArbFeeds.getPath(), inverted: false})
            })
        );

        //16: USDC/GMX
        ChainlinkOracleImpl.Feed[] memory usdcGmxFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcGmxFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcGmxFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: GMX}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcGmxFeeds.getPath(), inverted: false})
            })
        );

        //17: USDC/LINK
        ChainlinkOracleImpl.Feed[] memory usdcLinkFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcLinkFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcLinkFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: LINK_USD_FEED,
            decimals: LINK_USD_DECIMALS,
            staleAfter: LINK_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: LINK}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcLinkFeeds.getPath(), inverted: false})
            })
        );

        //18: USDC/PENDLE
        ChainlinkOracleImpl.Feed[] memory usdcPendleFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcPendleFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcPendleFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: PENDLE_USD_FEED,
            decimals: PENDLE_USD_DECIMALS,
            staleAfter: PENDLE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: PENDLE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcPendleFeeds.getPath(), inverted: false})
            })
        );

        //19: USDC/RDNT
        ChainlinkOracleImpl.Feed[] memory usdcRdntFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcRdntFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcRdntFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RDNT_USD_FEED,
            decimals: RDNT_USD_DECIMALS,
            staleAfter: RDNT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: RDNT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcRdntFeeds.getPath(), inverted: false})
            })
        );

        //20: USDC/WSTETH
        ChainlinkOracleImpl.Feed[] memory usdcWstethFeeds = new ChainlinkOracleImpl.Feed[](3);
        usdcWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        usdcWstethFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcWstethFeeds.getPath(), inverted: false})
            })
        );

        //21: DAI/WETH
        ChainlinkOracleImpl.Feed[] memory daiWethFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiWethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: WETH9}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiWethFeeds.getPath(), inverted: false})
            })
        );

        //22: DAI/WBTC
        ChainlinkOracleImpl.Feed[] memory daiWbtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiWbtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiWbtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: WBTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiWbtcFeeds.getPath(), inverted: false})
            })
        );

        //23: DAI/USDCE
        ChainlinkOracleImpl.Feed[] memory daiUsdceFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiUsdceFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiUsdceFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: USDCE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiUsdceFeeds.getPath(), inverted: false})
            })
        );

        //24: DAI/ARB
        ChainlinkOracleImpl.Feed[] memory daiArbFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiArbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiArbFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ARB_USD_FEED,
            decimals: ARB_USD_DECIMALS,
            staleAfter: ARB_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: ARB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiArbFeeds.getPath(), inverted: false})
            })
        );

        //25: DAI/GMX
        ChainlinkOracleImpl.Feed[] memory daiGmxFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiGmxFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiGmxFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: GMX}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiGmxFeeds.getPath(), inverted: false})
            })
        );

        //26: DAI/LINK
        ChainlinkOracleImpl.Feed[] memory daiLinkFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiLinkFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiLinkFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: LINK_USD_FEED,
            decimals: LINK_USD_DECIMALS,
            staleAfter: LINK_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: LINK}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiLinkFeeds.getPath(), inverted: false})
            })
        );

        //27: DAI/PENDLE
        ChainlinkOracleImpl.Feed[] memory daiPendleFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiPendleFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiPendleFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: PENDLE_USD_FEED,
            decimals: PENDLE_USD_DECIMALS,
            staleAfter: PENDLE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: PENDLE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiPendleFeeds.getPath(), inverted: false})
            })
        );

        //28: DAI/RDNT
        ChainlinkOracleImpl.Feed[] memory daiRdntFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiRdntFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiRdntFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RDNT_USD_FEED,
            decimals: RDNT_USD_DECIMALS,
            staleAfter: RDNT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: RDNT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiRdntFeeds.getPath(), inverted: false})
            })
        );

        //29: DAI/WSTETH
        ChainlinkOracleImpl.Feed[] memory daiWstethFeeds = new ChainlinkOracleImpl.Feed[](3);
        daiWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        daiWstethFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiWstethFeeds.getPath(), inverted: false})
            })
        );

        //30: WETH/WBTC
        ChainlinkOracleImpl.Feed[] memory wethWbtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethWbtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethWbtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH9, quote: WBTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethWbtcFeeds.getPath(), inverted: false})
            })
        );

        //31: WETH/USDCE
        ChainlinkOracleImpl.Feed[] memory wethUsdceFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethUsdceFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethUsdceFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH9, quote: USDCE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethUsdceFeeds.getPath(), inverted: false})
            })
        );

        //32: WETH/ARB
        ChainlinkOracleImpl.Feed[] memory wethArbFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethArbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethArbFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ARB_USD_FEED,
            decimals: ARB_USD_DECIMALS,
            staleAfter: ARB_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH9, quote: ARB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethArbFeeds.getPath(), inverted: false})
            })
        );

        //33: WETH/GMX
        ChainlinkOracleImpl.Feed[] memory wethGmxFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethGmxFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethGmxFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH9, quote: GMX}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethGmxFeeds.getPath(), inverted: false})
            })
        );

        //34: WETH/LINK
        ChainlinkOracleImpl.Feed[] memory wethLinkFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethLinkFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethLinkFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: LINK_USD_FEED,
            decimals: LINK_USD_DECIMALS,
            staleAfter: LINK_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH9, quote: LINK}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethLinkFeeds.getPath(), inverted: false})
            })
        );

        //35: WETH/PENDLE
        ChainlinkOracleImpl.Feed[] memory wethPendleFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethPendleFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethPendleFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: PENDLE_USD_FEED,
            decimals: PENDLE_USD_DECIMALS,
            staleAfter: PENDLE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH9, quote: PENDLE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethPendleFeeds.getPath(), inverted: false})
            })
        );

        //36: WETH/RDNT
        ChainlinkOracleImpl.Feed[] memory wethRdntFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethRdntFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethRdntFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RDNT_USD_FEED,
            decimals: RDNT_USD_DECIMALS,
            staleAfter: RDNT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH9, quote: RDNT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethRdntFeeds.getPath(), inverted: false})
            })
        );

        //37: WSTETH/WETH
        ChainlinkOracleImpl.Feed[] memory wethWstethFeeds = new ChainlinkOracleImpl.Feed[](1);
        wethWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WSTETH, quote: WETH9}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethWstethFeeds.getPath(), inverted: false})
            })
        );

        //38: WBTC/USDCE
        ChainlinkOracleImpl.Feed[] memory wbtcUsdceFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcUsdceFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcUsdceFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: USDCE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcUsdceFeeds.getPath(), inverted: false})
            })
        );

        //39: WBTC/ARB
        ChainlinkOracleImpl.Feed[] memory wbtcArbFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcArbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcArbFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ARB_USD_FEED,
            decimals: ARB_USD_DECIMALS,
            staleAfter: ARB_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: ARB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcArbFeeds.getPath(), inverted: false})
            })
        );

        //40: WBTC/GMX
        ChainlinkOracleImpl.Feed[] memory wbtcGmxFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcGmxFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcGmxFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: GMX}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcGmxFeeds.getPath(), inverted: false})
            })
        );

        //41: WBTC/LINK
        ChainlinkOracleImpl.Feed[] memory wbtcLinkFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcLinkFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcLinkFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: LINK_USD_FEED,
            decimals: LINK_USD_DECIMALS,
            staleAfter: LINK_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: LINK}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcLinkFeeds.getPath(), inverted: false})
            })
        );

        //42: WBTC/PENDLE
        ChainlinkOracleImpl.Feed[] memory wbtcPendleFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcPendleFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcPendleFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: PENDLE_USD_FEED,
            decimals: PENDLE_USD_DECIMALS,
            staleAfter: PENDLE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: PENDLE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcPendleFeeds.getPath(), inverted: false})
            })
        );

        //43: WBTC/RDNT
        ChainlinkOracleImpl.Feed[] memory wbtcRdntFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcRdntFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcRdntFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RDNT_USD_FEED,
            decimals: RDNT_USD_DECIMALS,
            staleAfter: RDNT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: RDNT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcRdntFeeds.getPath(), inverted: false})
            })
        );

        //44: WBTC/WSTETH
        ChainlinkOracleImpl.Feed[] memory wbtcWstethFeeds = new ChainlinkOracleImpl.Feed[](3);
        wbtcWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        wbtcWstethFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcWstethFeeds.getPath(), inverted: false})
            })
        );

        //45: USDCE/ARB
        ChainlinkOracleImpl.Feed[] memory usdceArbFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceArbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceArbFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ARB_USD_FEED,
            decimals: ARB_USD_DECIMALS,
            staleAfter: ARB_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: ARB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceArbFeeds.getPath(), inverted: false})
            })
        );

        //46: USDCE/GMX
        ChainlinkOracleImpl.Feed[] memory usdceGmxFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceGmxFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceGmxFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: GMX}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceGmxFeeds.getPath(), inverted: false})
            })
        );

        //47: USDCE/LINK
        ChainlinkOracleImpl.Feed[] memory usdceLinkFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceLinkFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceLinkFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: LINK_USD_FEED,
            decimals: LINK_USD_DECIMALS,
            staleAfter: LINK_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: LINK}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceLinkFeeds.getPath(), inverted: false})
            })
        );

        //48: USDCE/PENDLE
        ChainlinkOracleImpl.Feed[] memory usdcePendleFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcePendleFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcePendleFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: PENDLE_USD_FEED,
            decimals: PENDLE_USD_DECIMALS,
            staleAfter: PENDLE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: PENDLE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcePendleFeeds.getPath(), inverted: false})
            })
        );

        //49: USDCE/RDNT
        ChainlinkOracleImpl.Feed[] memory usdceRdntFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceRdntFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceRdntFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RDNT_USD_FEED,
            decimals: RDNT_USD_DECIMALS,
            staleAfter: RDNT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: RDNT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceRdntFeeds.getPath(), inverted: false})
            })
        );

        //50: USDCE/WSTETH
        ChainlinkOracleImpl.Feed[] memory usdceWstethFeeds = new ChainlinkOracleImpl.Feed[](3);
        usdceWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        usdceWstethFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceWstethFeeds.getPath(), inverted: false})
            })
        );

        //51: ARB/GMX
        ChainlinkOracleImpl.Feed[] memory arbGmxFeeds = new ChainlinkOracleImpl.Feed[](2);
        arbGmxFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ARB_USD_FEED,
            decimals: ARB_USD_DECIMALS,
            staleAfter: ARB_USD_STALEAFTER,
            mul: true
        });
        arbGmxFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: ARB, quote: GMX}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: arbGmxFeeds.getPath(), inverted: false})
            })
        );

        //52: ARB/LINK
        ChainlinkOracleImpl.Feed[] memory arbLinkFeeds = new ChainlinkOracleImpl.Feed[](2);
        arbLinkFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ARB_USD_FEED,
            decimals: ARB_USD_DECIMALS,
            staleAfter: ARB_USD_STALEAFTER,
            mul: true
        });
        arbLinkFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: LINK_USD_FEED,
            decimals: LINK_USD_DECIMALS,
            staleAfter: LINK_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: ARB, quote: LINK}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: arbLinkFeeds.getPath(), inverted: false})
            })
        );

        //53: ARB/PENDLE
        ChainlinkOracleImpl.Feed[] memory arbPendleFeeds = new ChainlinkOracleImpl.Feed[](2);
        arbPendleFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ARB_USD_FEED,
            decimals: ARB_USD_DECIMALS,
            staleAfter: ARB_USD_STALEAFTER,
            mul: true
        });
        arbPendleFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: PENDLE_USD_FEED,
            decimals: PENDLE_USD_DECIMALS,
            staleAfter: PENDLE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: ARB, quote: PENDLE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: arbPendleFeeds.getPath(), inverted: false})
            })
        );

        //54: ARB/RDNT
        ChainlinkOracleImpl.Feed[] memory arbRdntFeeds = new ChainlinkOracleImpl.Feed[](2);
        arbRdntFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ARB_USD_FEED,
            decimals: ARB_USD_DECIMALS,
            staleAfter: ARB_USD_STALEAFTER,
            mul: true
        });
        arbRdntFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RDNT_USD_FEED,
            decimals: RDNT_USD_DECIMALS,
            staleAfter: RDNT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: ARB, quote: RDNT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: arbRdntFeeds.getPath(), inverted: false})
            })
        );

        //55: ARB/WSTETH
        ChainlinkOracleImpl.Feed[] memory arbWstethFeeds = new ChainlinkOracleImpl.Feed[](3);
        arbWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ARB_USD_FEED,
            decimals: ARB_USD_DECIMALS,
            staleAfter: ARB_USD_STALEAFTER,
            mul: true
        });
        arbWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        arbWstethFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: ARB, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: arbWstethFeeds.getPath(), inverted: false})
            })
        );

        //56: GMX/LINK
        ChainlinkOracleImpl.Feed[] memory gmxLinkFeeds = new ChainlinkOracleImpl.Feed[](2);
        gmxLinkFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: true
        });
        gmxLinkFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: LINK_USD_FEED,
            decimals: LINK_USD_DECIMALS,
            staleAfter: LINK_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: GMX, quote: LINK}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: gmxLinkFeeds.getPath(), inverted: false})
            })
        );

        //57: GMX/PENDLE
        ChainlinkOracleImpl.Feed[] memory gmxPendleFeeds = new ChainlinkOracleImpl.Feed[](2);
        gmxPendleFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: true
        });
        gmxPendleFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: PENDLE_USD_FEED,
            decimals: PENDLE_USD_DECIMALS,
            staleAfter: PENDLE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: GMX, quote: PENDLE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: gmxPendleFeeds.getPath(), inverted: false})
            })
        );

        //58: GMX/RDNT
        ChainlinkOracleImpl.Feed[] memory gmxRdntFeeds = new ChainlinkOracleImpl.Feed[](2);
        gmxRdntFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: true
        });
        gmxRdntFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RDNT_USD_FEED,
            decimals: RDNT_USD_DECIMALS,
            staleAfter: RDNT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: GMX, quote: RDNT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: gmxRdntFeeds.getPath(), inverted: false})
            })
        );

        //59: GMX/WSTETH
        ChainlinkOracleImpl.Feed[] memory gmxWstethFeeds = new ChainlinkOracleImpl.Feed[](3);
        gmxWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: true
        });
        gmxWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        gmxWstethFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: GMX, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: gmxWstethFeeds.getPath(), inverted: false})
            })
        );

        //60: LINK/PENDLE
        ChainlinkOracleImpl.Feed[] memory linkPendleFeeds = new ChainlinkOracleImpl.Feed[](2);
        linkPendleFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: LINK_USD_FEED,
            decimals: LINK_USD_DECIMALS,
            staleAfter: LINK_USD_STALEAFTER,
            mul: true
        });
        linkPendleFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: PENDLE_USD_FEED,
            decimals: PENDLE_USD_DECIMALS,
            staleAfter: PENDLE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: LINK, quote: PENDLE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: linkPendleFeeds.getPath(), inverted: false})
            })
        );

        //61: LINK/RDNT
        ChainlinkOracleImpl.Feed[] memory linkRdntFeeds = new ChainlinkOracleImpl.Feed[](2);
        linkRdntFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: LINK_USD_FEED,
            decimals: LINK_USD_DECIMALS,
            staleAfter: LINK_USD_STALEAFTER,
            mul: true
        });
        linkRdntFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RDNT_USD_FEED,
            decimals: RDNT_USD_DECIMALS,
            staleAfter: RDNT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: LINK, quote: RDNT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: linkRdntFeeds.getPath(), inverted: false})
            })
        );

        //62: LINK/WSTETH
        ChainlinkOracleImpl.Feed[] memory linkWstethFeeds = new ChainlinkOracleImpl.Feed[](3);
        linkWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: LINK_USD_FEED,
            decimals: LINK_USD_DECIMALS,
            staleAfter: LINK_USD_STALEAFTER,
            mul: true
        });
        linkWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        linkWstethFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: LINK, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: linkWstethFeeds.getPath(), inverted: false})
            })
        );

        //63: PENDLE/RDNT
        ChainlinkOracleImpl.Feed[] memory pendleRdntFeeds = new ChainlinkOracleImpl.Feed[](2);
        pendleRdntFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: PENDLE_USD_FEED,
            decimals: PENDLE_USD_DECIMALS,
            staleAfter: PENDLE_USD_STALEAFTER,
            mul: true
        });
        pendleRdntFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RDNT_USD_FEED,
            decimals: RDNT_USD_DECIMALS,
            staleAfter: RDNT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: PENDLE, quote: RDNT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: pendleRdntFeeds.getPath(), inverted: false})
            })
        );

        //64: PENDLE/WSTETH
        ChainlinkOracleImpl.Feed[] memory pendleWstethFeeds = new ChainlinkOracleImpl.Feed[](3);
        pendleWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: PENDLE_USD_FEED,
            decimals: PENDLE_USD_DECIMALS,
            staleAfter: PENDLE_USD_STALEAFTER,
            mul: true
        });
        pendleWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        pendleWstethFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: PENDLE, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: pendleWstethFeeds.getPath(), inverted: false})
            })
        );

        //65: RDNT/WSTETH
        ChainlinkOracleImpl.Feed[] memory rdntWstethFeeds = new ChainlinkOracleImpl.Feed[](3);
        rdntWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: RDNT_USD_FEED,
            decimals: RDNT_USD_DECIMALS,
            staleAfter: RDNT_USD_STALEAFTER,
            mul: true
        });
        rdntWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        rdntWstethFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: RDNT, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: rdntWstethFeeds.getPath(), inverted: false})
            })
        );
    }
}
