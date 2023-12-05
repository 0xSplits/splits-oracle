// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {QuotePair} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultChainlinkOracle.base.s.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultChainlinkOracleOptimismScript is CreateDefaultOracleBaseScript {
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address constant WETH9 = 0x4200000000000000000000000000000000000006;
    address constant OP = 0x4200000000000000000000000000000000000042;
    address constant USDC = 0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85;
    address constant USDCE = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
    address constant USDT = 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58;
    address constant WBTC = 0x68f180fcCe6836688e9084f035309E29Bf0A2095;
    address constant WSTETH = 0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb;

    AggregatorV3Interface constant DAI_USD_FEED = AggregatorV3Interface(0x8dBa75e83DA73cc766A7e5a0ee71F656BAb470d6);
    uint24 constant DAI_USD_STALEAFTER = 1 days;
    uint8 constant DAI_USD_DECIMALS = 8;

    AggregatorV3Interface constant ETH_USD_FEED = AggregatorV3Interface(0x13e3Ee699D1909E989722E753853AE30b17e08c5);
    uint24 constant ETH_USD_STALEAFTER = 1200;
    uint8 constant ETH_USD_DECIMALS = 8;

    AggregatorV3Interface constant OP_USD_FEED = AggregatorV3Interface(0x0D276FC14719f9292D5C1eA2198673d1f4269246);
    uint24 constant OP_USD_STALEAFTER = 1200;
    uint8 constant OP_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDC_USD_FEED = AggregatorV3Interface(0x16a9FA2FDa030272Ce99B29CF780dFA30361E0f3);
    uint24 constant USDC_USD_STALEAFTER = 1 days;
    uint8 constant USDC_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDT_USD_FEED = AggregatorV3Interface(0xECef79E109e997bCA29c1c0897ec9d7b03647F5E);
    uint24 constant USDT_USD_STALEAFTER = 1 days;
    uint8 constant USDT_USD_DECIMALS = 8;

    AggregatorV3Interface constant WBTC_USD_FEED = AggregatorV3Interface(0x718A5788b89454aAE3A028AE9c111A29Be6c2a6F);
    uint24 constant WBTC_USD_STALEAFTER = 1200;
    uint8 constant WBTC_USD_DECIMALS = 8;

    AggregatorV3Interface constant WSTETH_ETH_FEED = AggregatorV3Interface(0x524299Ab0987a7c4B3c8022a35669DdcdC715a10);
    uint24 constant WSTETH_ETH_STALEAFTER = 1 days;
    uint8 constant WSTETH_ETH_DECIMALS = 18;

    AggregatorV3Interface constant WSTETH_USD_FEED = AggregatorV3Interface(0x698B585CbC4407e2D54aa898B2600B53C68958f7);
    uint24 constant WSTETH_USD_STALEAFTER = 1 days;
    uint8 constant WSTETH_USD_DECIMALS = 8;

    /**
     * Pairs:
     * 0: USDT/USDC
     * 1: USDT/DAI
     * 2: USDT/WETH
     * 3: USDT/WBTC
     * 4: USDT/OP
     * 5: USDT/WSTETH
     * 6: USDC/DAI
     * 7: USDC/WETH
     * 8: USDC/WBTC
     * 9: USDC/OP
     * 10: USDC/WSTETH
     * 11: DAI/WETH
     * 12: DAI/WBTC
     * 13: DAI/OP
     * 14: DAI/WSTETH
     * 15: WETH/WBTC
     * 16: WETH/OP
     * 17: WETH/WSTETH
     * 18: WBTC/OP
     * 19: WBTC/WSTETH
     * 20: OP/WSTETH
     * 21: USDCE/USDC
     * 22: USDCE/USDT
     * 23: USDCE/DAI
     * 24: USDCE/WETH
     * 25: USDCE/WBTC
     * 26: USDCE/OP
     * 27: USDCE/WSTETH
     */

    function setUp() public {
        $sequencerFeed = 0x371EAD81c9102C9BF4874A9075FFFf170F2Ee389;
        $weth9 = WETH9;

        $owner = address(0);
        $paused = false;

        setUpPairDetails();
    }

    function setUpPairDetails() private {
        // USDT/USDC
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

        // USDT/DAI
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

        // USDT/WETH
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

        // USDT/WBTC
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

        // USDT/OP
        ChainlinkOracleImpl.Feed[] memory usdtOpFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtOpFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtOpFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: OP_USD_FEED,
            decimals: OP_USD_DECIMALS,
            staleAfter: OP_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: OP}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtOpFeeds.getPath(), inverted: false})
            })
        );

        // USDT/WSTETH
        ChainlinkOracleImpl.Feed[] memory usdtWstethFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_USD_FEED,
            decimals: WSTETH_USD_DECIMALS,
            staleAfter: WSTETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtWstethFeeds.getPath(), inverted: false})
            })
        );

        // USDC/DAI
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

        // USDC/WETH
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

        // USDC/WBTC
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

        // USDC/OP
        ChainlinkOracleImpl.Feed[] memory usdcOpFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcOpFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcOpFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: OP_USD_FEED,
            decimals: OP_USD_DECIMALS,
            staleAfter: OP_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: OP}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcOpFeeds.getPath(), inverted: false})
            })
        );

        // USDC/WSTETH
        ChainlinkOracleImpl.Feed[] memory usdcWstethFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_USD_FEED,
            decimals: WSTETH_USD_DECIMALS,
            staleAfter: WSTETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcWstethFeeds.getPath(), inverted: false})
            })
        );

        // DAI/WETH
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

        // DAI/WBTC
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

        // DAI/OP
        ChainlinkOracleImpl.Feed[] memory daiOpFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiOpFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiOpFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: OP_USD_FEED,
            decimals: OP_USD_DECIMALS,
            staleAfter: OP_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: OP}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiOpFeeds.getPath(), inverted: false})
            })
        );

        // DAI/WSTETH
        ChainlinkOracleImpl.Feed[] memory daiWstethFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_USD_FEED,
            decimals: WSTETH_USD_DECIMALS,
            staleAfter: WSTETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiWstethFeeds.getPath(), inverted: false})
            })
        );

        // WETH/WBTC
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

        // WETH/OP
        ChainlinkOracleImpl.Feed[] memory wethOpFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethOpFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethOpFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: OP_USD_FEED,
            decimals: OP_USD_DECIMALS,
            staleAfter: OP_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH9, quote: OP}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethOpFeeds.getPath(), inverted: false})
            })
        );

        // WETH/WSTETH
        ChainlinkOracleImpl.Feed[] memory wstethWETHFeeds = new ChainlinkOracleImpl.Feed[](1);
        wstethWETHFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_ETH_FEED,
            decimals: WSTETH_ETH_DECIMALS,
            staleAfter: WSTETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WSTETH, quote: WETH9}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wstethWETHFeeds.getPath(), inverted: false})
            })
        );

        // WBTC/OP
        ChainlinkOracleImpl.Feed[] memory wbtcOpFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcOpFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcOpFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: OP_USD_FEED,
            decimals: OP_USD_DECIMALS,
            staleAfter: OP_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: OP}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcOpFeeds.getPath(), inverted: false})
            })
        );

        // WBTC/WSTETH
        ChainlinkOracleImpl.Feed[] memory wbtcWstethFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_USD_FEED,
            decimals: WSTETH_USD_DECIMALS,
            staleAfter: WSTETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcWstethFeeds.getPath(), inverted: false})
            })
        );

        // OP/WSTETH
        ChainlinkOracleImpl.Feed[] memory opWstethFeeds = new ChainlinkOracleImpl.Feed[](2);
        opWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: OP_USD_FEED,
            decimals: OP_USD_DECIMALS,
            staleAfter: OP_USD_STALEAFTER,
            mul: true
        });
        opWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_USD_FEED,
            decimals: WSTETH_USD_DECIMALS,
            staleAfter: WSTETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: OP, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: opWstethFeeds.getPath(), inverted: false})
            })
        );

        // USDCE/USDC
        ChainlinkOracleImpl.Feed[] memory usdceUsdcFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceUsdcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceUsdcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: USDC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceUsdcFeeds.getPath(), inverted: false})
            })
        );

        // USDCE/USDT
        ChainlinkOracleImpl.Feed[] memory usdceUsdtFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceUsdtFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceUsdtFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: USDT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceUsdtFeeds.getPath(), inverted: false})
            })
        );

        // USDCE/DAI
        ChainlinkOracleImpl.Feed[] memory usdceDaiFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceDaiFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceDaiFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: DAI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceDaiFeeds.getPath(), inverted: false})
            })
        );

        // USDCE/WETH
        ChainlinkOracleImpl.Feed[] memory usdceWethFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceWethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: WETH9}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceWethFeeds.getPath(), inverted: false})
            })
        );

        // USDCE/WBTC
        ChainlinkOracleImpl.Feed[] memory usdceWbtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceWbtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceWbtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: WBTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceWbtcFeeds.getPath(), inverted: false})
            })
        );

        // USDCE/OP
        ChainlinkOracleImpl.Feed[] memory usdceOpFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceOpFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceOpFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: OP_USD_FEED,
            decimals: OP_USD_DECIMALS,
            staleAfter: OP_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: OP}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceOpFeeds.getPath(), inverted: false})
            })
        );

        // USDCE/WSTETH
        ChainlinkOracleImpl.Feed[] memory usdceWstethFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceWstethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceWstethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WSTETH_USD_FEED,
            decimals: WSTETH_USD_DECIMALS,
            staleAfter: WSTETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: WSTETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceWstethFeeds.getPath(), inverted: false})
            })
        );
    }
}
