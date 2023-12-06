// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {QuotePair} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultChainlinkOracle.base.s.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultChainlinkOracleBSCScript is CreateDefaultOracleBaseScript {
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address constant WBTC = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address constant CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address constant WETH = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;

    AggregatorV3Interface constant BNB_USD_FEED = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
    uint24 constant BNB_USD_STALEAFTER = 27;
    uint8 constant BNB_USD_DECIMALS = 8;

    AggregatorV3Interface constant BTC_BNB_FEED = AggregatorV3Interface(0x116EeB23384451C78ed366D4f67D5AD44eE771A0);
    uint24 constant BTC_BNB_STALEAFTER = 1 days;
    uint8 constant BTC_BNB_DECIMALS = 18;

    AggregatorV3Interface constant BTC_ETH_FEED = AggregatorV3Interface(0xf1769eB4D1943AF02ab1096D7893759F6177D6B8);
    uint24 constant BTC_ETH_STALEAFTER = 1 days;
    uint8 constant BTC_ETH_DECIMALS = 18;

    AggregatorV3Interface constant BTC_USD_FEED = AggregatorV3Interface(0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf);
    uint24 constant BTC_USD_STALEAFTER = 60;
    uint8 constant BTC_USD_DECIMALS = 8;

    AggregatorV3Interface constant BUSD_BNB_FEED = AggregatorV3Interface(0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941);
    uint24 constant BUSD_BNB_STALEAFTER = 1 days;
    uint8 constant BUSD_BNB_DECIMALS = 18;

    AggregatorV3Interface constant BUSD_USD_FEED = AggregatorV3Interface(0xcBb98864Ef56E9042e7d2efef76141f15731B82f);
    uint24 constant BUSD_USD_STALEAFTER = 900;
    uint8 constant BUSD_USD_DECIMALS = 8;

    AggregatorV3Interface constant ETH_BNB_FEED = AggregatorV3Interface(0x63D407F32Aa72E63C7209ce1c2F5dA40b3AaE726);
    uint24 constant ETH_BNB_STALEAFTER = 1 days;
    uint8 constant ETH_BNB_DECIMALS = 18;

    AggregatorV3Interface constant ETH_USD_FEED = AggregatorV3Interface(0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e);
    uint24 constant ETH_USD_STALEAFTER = 60;
    uint8 constant ETH_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDC_BNB_FEED = AggregatorV3Interface(0x45f86CA2A8BC9EBD757225B19a1A0D7051bE46Db);
    uint24 constant USDC_BNB_STALEAFTER = 1 days;
    uint8 constant USDC_BNB_DECIMALS = 18;

    AggregatorV3Interface constant USDC_USD_FEED = AggregatorV3Interface(0x51597f405303C4377E36123cBc172b13269EA163);
    uint24 constant USDC_USD_STALEAFTER = 900;
    uint8 constant USDC_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDT_BNB_FEED = AggregatorV3Interface(0xD5c40f5144848Bd4EF08a9605d860e727b991513);
    uint24 constant USDT_BNB_STALEAFTER = 1 days;
    uint8 constant USDT_BNB_DECIMALS = 18;

    AggregatorV3Interface constant USDT_USD_FEED = AggregatorV3Interface(0xB97Ad0E74fa7d920791E90258A6E2085088b4320);
    uint24 constant USDT_USD_STALEAFTER = 900;
    uint8 constant USDT_USD_DECIMALS = 8;

    AggregatorV3Interface constant CAKE_BNB_FEED = AggregatorV3Interface(0xcB23da9EA243f53194CBc2380A6d4d9bC046161f);
    uint24 constant CAKE_BNB_STALEAFTER = 1 days;
    uint8 constant CAKE_BNB_DECIMALS = 18;

    AggregatorV3Interface constant CAKE_USD_FEED = AggregatorV3Interface(0xB6064eD41d4f67e353768aA239cA86f4F73665a1);
    uint24 constant CAKE_USD_STALEAFTER = 60;
    uint8 constant CAKE_USD_DECIMALS = 8;

    /**
     * Pairs:
     * 0: WBTC/WETH
     * 1: WBTC/USDC
     * 2: WBTC/USDT
     * 3: WBTC/BUSD
     * 4: WBTC/CAKE
     * 5: WBTC/WBNB
     * 6: WETH/USDC
     * 7: WETH/USDT
     * 8: WETH/BUSD
     * 9: WETH/CAKE
     * 10: WETH/WBNB
     * 11: USDC/USDT
     * 12: USDC/BUSD
     * 13: USDC/CAKE
     * 14: USDC/WBNB
     * 15: USDT/BUSD
     * 16: USDT/CAKE
     * 17: USDT/WBNB
     * 18: BUSD/CAKE
     * 19: BUSD/WBNB
     * 20: CAKE/WBNB
     */
    function setUp() public {
        $weth9 = WBNB;

        $owner = address(0);
        $paused = false;

        setUpPairDetails();
    }

    function setUpPairDetails() private {
        // 0: WBTC/WETH
        ChainlinkOracleImpl.Feed[] memory wbtcWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        wbtcWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: BTC_ETH_FEED,
            decimals: BTC_ETH_DECIMALS,
            staleAfter: BTC_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcWethFeeds.getPath(), inverted: false})
            })
        );

        // 1: WBTC/USDC
        ChainlinkOracleImpl.Feed[] memory wbtcUsdcFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcUsdcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: true
        });
        wbtcUsdcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: USDC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcUsdcFeeds.getPath(), inverted: false})
            })
        );

        // 2: WBTC/USDT
        ChainlinkOracleImpl.Feed[] memory wbtcUsdtFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcUsdtFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: true
        });
        wbtcUsdtFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: USDT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcUsdtFeeds.getPath(), inverted: false})
            })
        );

        // 3: WBTC/BUSD
        ChainlinkOracleImpl.Feed[] memory wbtcBusdFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcBusdFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: true
        });
        wbtcBusdFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BUSD_USD_FEED,
            decimals: BUSD_USD_DECIMALS,
            staleAfter: BUSD_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: BUSD}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcBusdFeeds.getPath(), inverted: false})
            })
        );

        // 4: WBTC/CAKE
        ChainlinkOracleImpl.Feed[] memory wbtcCakeFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcCakeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: true
        });
        wbtcCakeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: CAKE_USD_FEED,
            decimals: CAKE_USD_DECIMALS,
            staleAfter: CAKE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: CAKE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcCakeFeeds.getPath(), inverted: false})
            })
        );

        // 5: WBTC/WBNB
        ChainlinkOracleImpl.Feed[] memory wbtcWbnbFeeds = new ChainlinkOracleImpl.Feed[](1);
        wbtcWbnbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: BTC_BNB_FEED,
            decimals: BTC_BNB_DECIMALS,
            staleAfter: BTC_BNB_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: WBNB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcWbnbFeeds.getPath(), inverted: false})
            })
        );

        // 6: WETH/USDC
        ChainlinkOracleImpl.Feed[] memory wethUsdcFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethUsdcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethUsdcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH, quote: USDC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethUsdcFeeds.getPath(), inverted: false})
            })
        );

        // 7: WETH/USDT
        ChainlinkOracleImpl.Feed[] memory wethUsdtFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethUsdtFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethUsdtFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH, quote: USDT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethUsdtFeeds.getPath(), inverted: false})
            })
        );

        // 8: WETH/BUSD
        ChainlinkOracleImpl.Feed[] memory wethBusdFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethBusdFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethBusdFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BUSD_USD_FEED,
            decimals: BUSD_USD_DECIMALS,
            staleAfter: BUSD_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH, quote: BUSD}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethBusdFeeds.getPath(), inverted: false})
            })
        );

        // 9: WETH/CAKE
        ChainlinkOracleImpl.Feed[] memory wethCakeFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethCakeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethCakeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: CAKE_USD_FEED,
            decimals: CAKE_USD_DECIMALS,
            staleAfter: CAKE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH, quote: CAKE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethCakeFeeds.getPath(), inverted: false})
            })
        );

        // 10: WETH/WBNB
        ChainlinkOracleImpl.Feed[] memory wethWbnbFeeds = new ChainlinkOracleImpl.Feed[](1);
        wethWbnbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_BNB_FEED,
            decimals: ETH_BNB_DECIMALS,
            staleAfter: ETH_BNB_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH, quote: WBNB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethWbnbFeeds.getPath(), inverted: false})
            })
        );

        // 11: USDC/USDT
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

        // 12: USDC/BUSD
        ChainlinkOracleImpl.Feed[] memory usdcBusdFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcBusdFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcBusdFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BUSD_USD_FEED,
            decimals: BUSD_USD_DECIMALS,
            staleAfter: BUSD_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: BUSD}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcBusdFeeds.getPath(), inverted: false})
            })
        );

        // 13: USDC/CAKE
        ChainlinkOracleImpl.Feed[] memory usdcCakeFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcCakeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcCakeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: CAKE_USD_FEED,
            decimals: CAKE_USD_DECIMALS,
            staleAfter: CAKE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: CAKE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcCakeFeeds.getPath(), inverted: false})
            })
        );

        // 14: USDC/WBNB
        ChainlinkOracleImpl.Feed[] memory usdcWbnbFeeds = new ChainlinkOracleImpl.Feed[](1);
        usdcWbnbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_BNB_FEED,
            decimals: USDC_BNB_DECIMALS,
            staleAfter: USDC_BNB_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: WBNB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcWbnbFeeds.getPath(), inverted: false})
            })
        );

        // 15: USDT/BUSD
        ChainlinkOracleImpl.Feed[] memory usdtBusdFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtBusdFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtBusdFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BUSD_USD_FEED,
            decimals: BUSD_USD_DECIMALS,
            staleAfter: BUSD_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: BUSD}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtBusdFeeds.getPath(), inverted: false})
            })
        );

        // 16: USDT/CAKE
        ChainlinkOracleImpl.Feed[] memory usdtCakeFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtCakeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtCakeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: CAKE_USD_FEED,
            decimals: CAKE_USD_DECIMALS,
            staleAfter: CAKE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: CAKE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtCakeFeeds.getPath(), inverted: false})
            })
        );

        // 17: USDT/WBNB
        ChainlinkOracleImpl.Feed[] memory usdtWbnbFeeds = new ChainlinkOracleImpl.Feed[](1);
        usdtWbnbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_BNB_FEED,
            decimals: USDT_BNB_DECIMALS,
            staleAfter: USDT_BNB_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: WBNB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtWbnbFeeds.getPath(), inverted: false})
            })
        );

        // 18: BUSD/CAKE
        ChainlinkOracleImpl.Feed[] memory busdCakeFeeds = new ChainlinkOracleImpl.Feed[](2);
        busdCakeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: BUSD_USD_FEED,
            decimals: BUSD_USD_DECIMALS,
            staleAfter: BUSD_USD_STALEAFTER,
            mul: true
        });
        busdCakeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: CAKE_USD_FEED,
            decimals: CAKE_USD_DECIMALS,
            staleAfter: CAKE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: BUSD, quote: CAKE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: busdCakeFeeds.getPath(), inverted: false})
            })
        );

        // 19: BUSD/WBNB
        ChainlinkOracleImpl.Feed[] memory busdWbnbFeeds = new ChainlinkOracleImpl.Feed[](1);
        busdWbnbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: BUSD_BNB_FEED,
            decimals: BUSD_BNB_DECIMALS,
            staleAfter: BUSD_BNB_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: BUSD, quote: WBNB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: busdWbnbFeeds.getPath(), inverted: false})
            })
        );

        // 20: CAKE/WBNB
        ChainlinkOracleImpl.Feed[] memory cakeWbnbFeeds = new ChainlinkOracleImpl.Feed[](1);
        cakeWbnbFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: CAKE_BNB_FEED,
            decimals: CAKE_BNB_DECIMALS,
            staleAfter: CAKE_BNB_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: CAKE, quote: WBNB}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: cakeWbnbFeeds.getPath(), inverted: false})
            })
        );
    }
}
