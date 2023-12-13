// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {QuotePair} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultChainlinkOracle.base.s.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultChainlinkOracleGnosisScript is CreateDefaultOracleBaseScript {
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address constant USDC = 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83;
    address constant WBTC = 0x8e5bBbb09Ed1ebdE8674Cda39A0c169401db4252;
    address constant WETH = 0x6A023CCd1ff6F2045C3309768eAd9E68F978f6e1;
    address constant WXDAI = 0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d;

    AggregatorV3Interface constant ETH_USD_FEED = AggregatorV3Interface(0xa767f745331D267c7751297D982b050c93985627);
    uint24 constant ETH_USD_STALEAFTER = 1 days;
    uint8 constant ETH_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDC_USD_FEED = AggregatorV3Interface(0x26C31ac71010aF62E6B486D1132E266D6298857D);
    uint24 constant USDC_USD_STALEAFTER = 1 days;
    uint8 constant USDC_USD_DECIMALS = 8;

    AggregatorV3Interface constant WBTC_USD_FEED = AggregatorV3Interface(0x6C1d7e76EF7304a40e8456ce883BC56d3dEA3F7d);
    uint24 constant WBTC_USD_STALEAFTER = 1 days;
    uint8 constant WBTC_USD_DECIMALS = 8;

    /**
     * Pairs:
     * 0: USDC/WETH
     * 1: USDC/WBTC
     * 2: WBTC/WETH
     */

    function setUp() public {
        $weth9 = WXDAI;

        $owner = address(0);
        $paused = false;

        setUpPairDetails();
    }

    function setUpPairDetails() private {
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
                quotePair: QuotePair({base: USDC, quote: WETH}),
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

        // WBTC/WETH
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
    }
}
