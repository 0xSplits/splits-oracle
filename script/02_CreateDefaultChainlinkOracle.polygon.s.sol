// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {QuotePair} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultChainlinkOracle.base.s.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultChainlinkOraclePolygonScript is CreateDefaultOracleBaseScript {
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address constant DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address constant USDCE = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address constant WBTC = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6;
    address constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;

    AggregatorV3Interface constant DAI_USD_FEED = AggregatorV3Interface(0x4746DeC9e833A82EC7C2C1356372CcF2cfcD2F3D);
    uint24 constant DAI_USD_STALEAFTER = 27;
    uint8 constant DAI_USD_DECIMALS = 8;

    AggregatorV3Interface constant DAI_ETH_FEED = AggregatorV3Interface(0xFC539A559e170f848323e19dfD66007520510085);
    uint24 constant DAI_ETH_STALEAFTER = 1 days;
    uint8 constant DAI_ETH_DECIMALS = 18;

    AggregatorV3Interface constant ETH_USD_FEED = AggregatorV3Interface(0xF9680D99D6C9589e2a93a78A04A279e509205945);
    uint24 constant ETH_USD_STALEAFTER = 27;
    uint8 constant ETH_USD_DECIMALS = 8;

    AggregatorV3Interface constant MATIC_USD_FEED = AggregatorV3Interface(0xAB594600376Ec9fD91F8e885dADF0CE036862dE0);
    uint24 constant MATIC_USD_STALEAFTER = 27;
    uint8 constant MATIC_USD_DECIMALS = 8;

    AggregatorV3Interface constant MATIC_ETH_FEED = AggregatorV3Interface(0x327e23A4855b6F663a28c5161541d69Af8973302);
    uint24 constant MATIC_ETH_STALEAFTER = 1 days;
    uint8 constant MATIC_ETH_DECIMALS = 18;

    AggregatorV3Interface constant USDC_USD_FEED = AggregatorV3Interface(0xfE4A8cc5b5B2366C1B58Bea3858e81843581b2F7);
    uint24 constant USDC_USD_STALEAFTER = 27;
    uint8 constant USDC_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDC_ETH_FEED = AggregatorV3Interface(0xefb7e6be8356cCc6827799B6A7348eE674A80EaE);
    uint24 constant USDC_ETH_STALEAFTER = 1 days;
    uint8 constant USDC_ETH_DECIMALS = 18;

    AggregatorV3Interface constant USDT_USD_FEED = AggregatorV3Interface(0x0A6513e40db6EB1b165753AD52E80663aeA50545);
    uint24 constant USDT_USD_STALEAFTER = 27;
    uint8 constant USDT_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDT_ETH_FEED = AggregatorV3Interface(0xf9d5AAC6E5572AEFa6bd64108ff86a222F69B64d);
    uint24 constant USDT_ETH_STALEAFTER = 1 days;
    uint8 constant USDT_ETH_DECIMALS = 18;

    AggregatorV3Interface constant WBTC_USD_FEED = AggregatorV3Interface(0xc907E116054Ad103354f2D350FD2514433D57F6f);
    uint24 constant WBTC_USD_STALEAFTER = 27;
    uint8 constant WBTC_USD_DECIMALS = 8;

    AggregatorV3Interface constant WBTC_ETH_FEED = AggregatorV3Interface(0x19b0F0833C78c0848109E3842D34d2fDF2cA69BA);
    uint24 constant WBTC_ETH_STALEAFTER = 1 days;
    uint8 constant WBTC_ETH_DECIMALS = 18;

    /**
     * Pairs:
     * 0: DAI/USDCE
     * 1: DAI/USDT
     * 2: DAI/WETH
     * 3: DAI/WBTC
     * 4: DAI/WMATIC
     * 5: USDCE/USDT
     * 6: USDCE/WETH
     * 7: USDCE/WBTC
     * 8: USDCE/WMATIC
     * 9: USDT/WETH
     * 10: USDT/WBTC
     * 11: USDT/WMATIC
     * 12: WETH/WBTC
     * 13: WETH/WMATIC
     * 14: WBTC/WMATIC
     */

    function setUp() public {
        $owner = address(0);
        $paused = false;

        setUpPairDetails();
    }

    function setUpPairDetails() private {
        // DAI/USDCE
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

        // DAI/USDT
        ChainlinkOracleImpl.Feed[] memory daiUsdtFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiUsdtFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiUsdtFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: USDT}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiUsdtFeeds.getPath(), inverted: false})
            })
        );

        // DAI/WETH
        ChainlinkOracleImpl.Feed[] memory daiWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        daiWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_ETH_FEED,
            decimals: DAI_ETH_DECIMALS,
            staleAfter: DAI_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: WETH}),
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

        // DAI/WMATIC
        ChainlinkOracleImpl.Feed[] memory daiWmaticFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiWmaticFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiWmaticFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: MATIC_USD_FEED,
            decimals: MATIC_USD_DECIMALS,
            staleAfter: MATIC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: WMATIC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiWmaticFeeds.getPath(), inverted: false})
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

        // USDCE/WETH
        ChainlinkOracleImpl.Feed[] memory usdceWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        usdceWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_ETH_FEED,
            decimals: USDC_ETH_DECIMALS,
            staleAfter: USDC_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: WETH}),
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

        // USDCE/WMATIC
        ChainlinkOracleImpl.Feed[] memory usdceWmaticFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdceWmaticFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdceWmaticFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: MATIC_USD_FEED,
            decimals: MATIC_USD_DECIMALS,
            staleAfter: MATIC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDCE, quote: WMATIC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdceWmaticFeeds.getPath(), inverted: false})
            })
        );

        // USDT/WETH
        ChainlinkOracleImpl.Feed[] memory usdtWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        usdtWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_ETH_FEED,
            decimals: USDT_ETH_DECIMALS,
            staleAfter: USDT_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: WETH}),
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

        // USDT/WMATIC
        ChainlinkOracleImpl.Feed[] memory usdtWmaticFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtWmaticFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtWmaticFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: MATIC_USD_FEED,
            decimals: MATIC_USD_DECIMALS,
            staleAfter: MATIC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: WMATIC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtWmaticFeeds.getPath(), inverted: false})
            })
        );

        // WBTC/WETH
        ChainlinkOracleImpl.Feed[] memory wbtcWETHFeeds = new ChainlinkOracleImpl.Feed[](1);
        wbtcWETHFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_ETH_FEED,
            decimals: WBTC_ETH_DECIMALS,
            staleAfter: WBTC_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcWETHFeeds.getPath(), inverted: false})
            })
        );

        // WMATIC/ETH
        ChainlinkOracleImpl.Feed[] memory maticEthFeeds = new ChainlinkOracleImpl.Feed[](1);
        maticEthFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: MATIC_ETH_FEED,
            decimals: MATIC_ETH_DECIMALS,
            staleAfter: MATIC_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WMATIC, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: maticEthFeeds.getPath(), inverted: false})
            })
        );

        // WBTC/WMATIC
        ChainlinkOracleImpl.Feed[] memory wbtcWmaticFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcWmaticFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcWmaticFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: MATIC_USD_FEED,
            decimals: MATIC_USD_DECIMALS,
            staleAfter: MATIC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: WMATIC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcWmaticFeeds.getPath(), inverted: false})
            })
        );
    }
}
