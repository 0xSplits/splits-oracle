// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {QuotePair} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultChainlinkOracle.base.s.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultChainlinkOracleAvaxScript is CreateDefaultOracleBaseScript {
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address constant WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    address constant USDC = 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E;
    address constant BTC = 0x152b9d0FdC40C096757F570A51E494bd4b943E50;
    address constant WETH = 0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB;
    address constant WBTC = 0x50b7545627a5162F82A992c33b87aDc75187B218;
    address constant USDT = 0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7;
    address constant JOE = 0x6e84a6216eA6dACC71eE8E6b0a5B7322EEbC0fDd;
    address constant GMX = 0x62edc0692BD897D2295872a9FFCac5425011c661;

    AggregatorV3Interface constant AVAX_USD_FEED = AggregatorV3Interface(0x0A77230d17318075983913bC2145DB16C7366156);
    uint24 constant AVAX_USD_STALEAFTER = 120;
    uint8 constant AVAX_USD_DECIMALS = 8;

    AggregatorV3Interface constant BTC_USD_FEED = AggregatorV3Interface(0x2779D32d5166BAaa2B2b658333bA7e6Ec0C65743);
    uint24 constant BTC_USD_STALEAFTER = 1 days;
    uint8 constant BTC_USD_DECIMALS = 8;

    AggregatorV3Interface constant ETH_USD_FEED = AggregatorV3Interface(0x976B3D034E162d8bD72D6b9C989d545b839003b0);
    uint24 constant ETH_USD_STALEAFTER = 1 days;
    uint8 constant ETH_USD_DECIMALS = 8;

    AggregatorV3Interface constant GMX_USD_FEED = AggregatorV3Interface(0x3F968A21647d7ca81Fb8A5b69c0A452701d5DCe8);
    uint24 constant GMX_USD_STALEAFTER = 1 days;
    uint8 constant GMX_USD_DECIMALS = 8;

    AggregatorV3Interface constant JOE_USD_FEED = AggregatorV3Interface(0x02D35d3a8aC3e1626d3eE09A78Dd87286F5E8e3a);
    uint24 constant JOE_USD_STALEAFTER = 1800;
    uint8 constant JOE_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDC_USD_FEED = AggregatorV3Interface(0xF096872672F44d6EBA71458D74fe67F9a77a23B9);
    uint24 constant USDC_USD_STALEAFTER = 1 days;
    uint8 constant USDC_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDT_USD_FEED = AggregatorV3Interface(0xEBE676ee90Fe1112671f19b6B7459bC678B67e8a);
    uint24 constant USDT_USD_STALEAFTER = 1 days;
    uint8 constant USDT_USD_DECIMALS = 8;

    AggregatorV3Interface constant WBTC_USD_FEED = AggregatorV3Interface(0x86442E3a98558357d46E6182F4b262f76c4fa26F);
    uint24 constant WBTC_USD_STALEAFTER = 1 days;
    uint8 constant WBTC_USD_DECIMALS = 8;

    /**
     * Pairs:
     * 0: WAVAX/USDC
     * 1: WAVAX/USDT
     * 2: WAVAX/WBTC
     * 3: WAVAX/WETH
     * 4: WAVAX/GMX
     * 5: WAVAX/JOE
     * 6: WAVAX/BTC
     * 7: USDC/USDT
     * 8: USDC/WBTC
     * 9: USDC/WETH
     * 10: USDC/GMX
     * 11: USDC/JOE
     * 12: USDC/BTC
     * 13: USDT/WBTC
     * 14: USDT/WETH
     * 15: USDT/GMX
     * 16: USDT/JOE
     * 17: USDT/BTC
     * 18: WBTC/WETH
     * 19: WBTC/GMX
     * 20: WBTC/JOE
     * 21: WBTC/BTC
     * 22: WETH/GMX
     * 23: WETH/JOE
     * 24: WETH/BTC
     * 25: GMX/JOE
     * 26: GMX/BTC
     * 27: JOE/BTC
     */

    function setUp() public {
        $weth9 = WAVAX;

        $owner = address(0);
        $paused = false;

        setUpPairDetails();
    }

    function setUpPairDetails() private {
        // 0: WAVAX/USDC
        ChainlinkOracleImpl.Feed[] memory wavaxUsdcFeeds = new ChainlinkOracleImpl.Feed[](2);
        wavaxUsdcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: AVAX_USD_FEED,
            decimals: AVAX_USD_DECIMALS,
            staleAfter: AVAX_USD_STALEAFTER,
            mul: true
        });
        wavaxUsdcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WAVAX, quote: USDC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wavaxUsdcFeeds.getPath(), inverted: false})
            })
        );

        // 1: WAVAX/USDT
        ChainlinkOracleImpl.Feed[] memory wavaxUsdtFeeds = new ChainlinkOracleImpl.Feed[](2);
        wavaxUsdtFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: AVAX_USD_FEED,
            decimals: AVAX_USD_DECIMALS,
            staleAfter: AVAX_USD_STALEAFTER,
            mul: true
        });
        wavaxUsdtFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WAVAX, quote: USDT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wavaxUsdtFeeds.getPath(), inverted: false})
            })
        );

        // 2: WAVAX/WBTC
        ChainlinkOracleImpl.Feed[] memory wavaxWbtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        wavaxWbtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: AVAX_USD_FEED,
            decimals: AVAX_USD_DECIMALS,
            staleAfter: AVAX_USD_STALEAFTER,
            mul: true
        });
        wavaxWbtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WAVAX, quote: WBTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wavaxWbtcFeeds.getPath(), inverted: false})
            })
        );

        // 3: WAVAX/WETH
        ChainlinkOracleImpl.Feed[] memory wavaxWethFeeds = new ChainlinkOracleImpl.Feed[](2);
        wavaxWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: AVAX_USD_FEED,
            decimals: AVAX_USD_DECIMALS,
            staleAfter: AVAX_USD_STALEAFTER,
            mul: true
        });
        wavaxWethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WAVAX, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wavaxWethFeeds.getPath(), inverted: false})
            })
        );

        // 4: WAVAX/GMX
        ChainlinkOracleImpl.Feed[] memory wavaxGmxFeeds = new ChainlinkOracleImpl.Feed[](2);
        wavaxGmxFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: AVAX_USD_FEED,
            decimals: AVAX_USD_DECIMALS,
            staleAfter: AVAX_USD_STALEAFTER,
            mul: true
        });
        wavaxGmxFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WAVAX, quote: GMX}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wavaxGmxFeeds.getPath(), inverted: false})
            })
        );

        // 5: WAVAX/JOE
        ChainlinkOracleImpl.Feed[] memory wavaxJoeFeeds = new ChainlinkOracleImpl.Feed[](2);
        wavaxJoeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: AVAX_USD_FEED,
            decimals: AVAX_USD_DECIMALS,
            staleAfter: AVAX_USD_STALEAFTER,
            mul: true
        });
        wavaxJoeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: JOE_USD_FEED,
            decimals: JOE_USD_DECIMALS,
            staleAfter: JOE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WAVAX, quote: JOE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wavaxJoeFeeds.getPath(), inverted: false})
            })
        );

        // 6: WAVAX/BTC
        ChainlinkOracleImpl.Feed[] memory wavaxBtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        wavaxBtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: AVAX_USD_FEED,
            decimals: AVAX_USD_DECIMALS,
            staleAfter: AVAX_USD_STALEAFTER,
            mul: true
        });
        wavaxBtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WAVAX, quote: BTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wavaxBtcFeeds.getPath(), inverted: false})
            })
        );

        // 7: USDC/USDT
        ChainlinkOracleImpl.Feed[] memory usdcUsdtFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcUsdtFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcUsdtFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: USDT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcUsdtFeeds.getPath(), inverted: false})
            })
        );

        // 8: USDC/WBTC
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

        // 9: USDC/WETH
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
                quotePair: QuotePair({base: USDC, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcWethFeeds.getPath(), inverted: false})
            })
        );

        // 10: USDC/GMX
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

        // 11: USDC/JOE
        ChainlinkOracleImpl.Feed[] memory usdcJoeFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcJoeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcJoeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: JOE_USD_FEED,
            decimals: JOE_USD_DECIMALS,
            staleAfter: JOE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: JOE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcJoeFeeds.getPath(), inverted: false})
            })
        );

        // 12: USDC/BTC
        ChainlinkOracleImpl.Feed[] memory usdcBtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcBtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcBtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: BTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcBtcFeeds.getPath(), inverted: false})
            })
        );

        // 13: USDT/WBTC
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

        // 14: USDT/WETH
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
                quotePair: QuotePair({base: USDT, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtWethFeeds.getPath(), inverted: false})
            })
        );

        // 15: USDT/GMX
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

        // 16: USDT/JOE
        ChainlinkOracleImpl.Feed[] memory usdtJoeFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtJoeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtJoeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: JOE_USD_FEED,
            decimals: JOE_USD_DECIMALS,
            staleAfter: JOE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: JOE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtJoeFeeds.getPath(), inverted: false})
            })
        );

        // 17: USDT/BTC
        ChainlinkOracleImpl.Feed[] memory usdtBtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtBtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtBtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: BTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtBtcFeeds.getPath(), inverted: false})
            })
        );

        // 18: WBTC/WETH
        ChainlinkOracleImpl.Feed[] memory wbtcWethFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcWethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcWethFeeds.getPath(), inverted: false})
            })
        );

        // 19: WBTC/GMX
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

        // 20: WBTC/JOE
        ChainlinkOracleImpl.Feed[] memory wbtcJoeFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcJoeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcJoeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: JOE_USD_FEED,
            decimals: JOE_USD_DECIMALS,
            staleAfter: JOE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: JOE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcJoeFeeds.getPath(), inverted: false})
            })
        );

        // 21: WBTC/BTC
        ChainlinkOracleImpl.Feed[] memory wbtcBtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcBtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcBtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: BTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcBtcFeeds.getPath(), inverted: false})
            })
        );

        // 22: WETH/GMX
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
                quotePair: QuotePair({base: WETH, quote: GMX}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethGmxFeeds.getPath(), inverted: false})
            })
        );

        // 23: WETH/JOE
        ChainlinkOracleImpl.Feed[] memory wethJoeFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethJoeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethJoeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: JOE_USD_FEED,
            decimals: JOE_USD_DECIMALS,
            staleAfter: JOE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH, quote: JOE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethJoeFeeds.getPath(), inverted: false})
            })
        );

        // 24: WETH/BTC
        ChainlinkOracleImpl.Feed[] memory wethBtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethBtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethBtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH, quote: BTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethBtcFeeds.getPath(), inverted: false})
            })
        );

        // 25: GMX/JOE
        ChainlinkOracleImpl.Feed[] memory gmxJoeFeeds = new ChainlinkOracleImpl.Feed[](2);
        gmxJoeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: true
        });
        gmxJoeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: JOE_USD_FEED,
            decimals: JOE_USD_DECIMALS,
            staleAfter: JOE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: GMX, quote: JOE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: gmxJoeFeeds.getPath(), inverted: false})
            })
        );

        // 26: GMX/BTC
        ChainlinkOracleImpl.Feed[] memory gmxBtcFeeds = new ChainlinkOracleImpl.Feed[](2);
        gmxBtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: GMX_USD_FEED,
            decimals: GMX_USD_DECIMALS,
            staleAfter: GMX_USD_STALEAFTER,
            mul: true
        });
        gmxBtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: GMX, quote: BTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: gmxBtcFeeds.getPath(), inverted: false})
            })
        );
    }
}
