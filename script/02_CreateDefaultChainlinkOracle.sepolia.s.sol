// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {QuotePair} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultChainlinkOracle.base.s.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultChainlinkOracleScript is CreateDefaultOracleBaseScript {
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address constant WETH9 = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
    address constant USDC = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;

    AggregatorV3Interface constant ETH_USD_FEED = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    uint24 constant ETH_USD_STALEAFTER = 1 hours;
    uint8 constant ETH_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDC_USD_FEED = AggregatorV3Interface(0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E);
    uint24 constant USDC_USD_STALEAFTER = 1 days;
    uint8 constant USDC_USD_DECIMALS = 8;

    /**
     * Pairs:
     * 0: USDC/WETH
     */

    function setUp() public {
        $weth9 = WETH9;

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
                quotePair: QuotePair({base: USDC, quote: WETH9}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcWethFeeds.getPath(), inverted: false})
            })
        );
    }
}
