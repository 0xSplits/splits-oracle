// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {QuotePair} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultChainlinkOracleL2.base.s.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultChainlinkOracleCoinbaseScript is CreateDefaultOracleBaseScript {
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address constant WETH9 = 0x4200000000000000000000000000000000000006;
    address constant DAI = 0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb;
    address constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address constant CBETH = 0x2Ae3F1Ec7F1F5012CFEab0185bfc7aa3cf0DEc22;

    AggregatorV3Interface constant DAI_USD_FEED = AggregatorV3Interface(0x591e79239a7d679378eC8c847e5038150364C78F);
    uint24 constant DAI_USD_STALEAFTER = 1 days;
    uint8 constant DAI_USD_DECIMALS = 8;

    AggregatorV3Interface constant ETH_USD_FEED = AggregatorV3Interface(0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70);
    uint24 constant ETH_USD_STALEAFTER = 1200;
    uint8 constant ETH_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDC_USD_FEED = AggregatorV3Interface(0x7e860098F58bBFC8648a4311b374B1D669a2bc6B);
    uint24 constant USDC_USD_STALEAFTER = 1 days;
    uint8 constant USDC_USD_DECIMALS = 8;

    AggregatorV3Interface constant CBETH_ETH_FEED = AggregatorV3Interface(0x806b4Ac04501c29769051e42783cF04dCE41440b);
    uint24 constant CBETH_ETH_STALEAFTER = 1 days;
    uint8 constant CBETH_ETH_DECIMALS = 18;

    AggregatorV3Interface constant CBETH_USD_FEED = AggregatorV3Interface(0xd7818272B9e248357d13057AAb0B417aF31E817d);
    uint24 constant CBETH_USD_STALEAFTER = 1200;
    uint8 constant CBETH_USD_DECIMALS = 8;

    /**
     * Pairs:
     * 0: WETH9/DAI
     * 1: WETH9/USDC
     * 2: CBETH/WETH9
     * 3: DAI/USDC
     * 4: DAI/CBETH
     * 5: USDC/CBETH
     */

    function setUp() public {
        $owner = address(0);
        $paused = false;

        setUpPairDetails();
    }

    function setUpPairDetails() private {
        // WETH9/DAI
        ChainlinkOracleImpl.Feed[] memory weth9DaiFeeds = new ChainlinkOracleImpl.Feed[](2);
        weth9DaiFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        weth9DaiFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH9, quote: DAI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: weth9DaiFeeds.getPath(), inverted: false})
            })
        );

        // WETH9/USDC
        ChainlinkOracleImpl.Feed[] memory weth9UsdcFeeds = new ChainlinkOracleImpl.Feed[](2);
        weth9UsdcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        weth9UsdcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH9, quote: USDC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: weth9UsdcFeeds.getPath(), inverted: false})
            })
        );

        // CBETH/WETH9
        ChainlinkOracleImpl.Feed[] memory cbethWeth9Feeds = new ChainlinkOracleImpl.Feed[](1);
        cbethWeth9Feeds[0] = ChainlinkOracleImpl.Feed({
            feed: CBETH_ETH_FEED,
            decimals: CBETH_ETH_DECIMALS,
            staleAfter: CBETH_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: CBETH, quote: WETH9}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: cbethWeth9Feeds.getPath(), inverted: false})
            })
        );

        // DAI/USDC
        ChainlinkOracleImpl.Feed[] memory daiUsdcFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiUsdcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiUsdcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: USDC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiUsdcFeeds.getPath(), inverted: false})
            })
        );

        // DAI/CBETH
        ChainlinkOracleImpl.Feed[] memory daiCbethFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiCbethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiCbethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: CBETH_USD_FEED,
            decimals: CBETH_USD_DECIMALS,
            staleAfter: CBETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: CBETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiCbethFeeds.getPath(), inverted: false})
            })
        );

        // USDC/CBETH
        ChainlinkOracleImpl.Feed[] memory usdcCbethFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcCbethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcCbethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: CBETH_USD_FEED,
            decimals: CBETH_USD_DECIMALS,
            staleAfter: CBETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: CBETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcCbethFeeds.getPath(), inverted: false})
            })
        );
    }
}
