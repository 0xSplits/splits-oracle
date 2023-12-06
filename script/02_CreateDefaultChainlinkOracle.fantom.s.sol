// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {QuotePair} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultChainlinkOracle.base.s.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultChainlinkOracleFantomScript is CreateDefaultOracleBaseScript {
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address constant USDC = 0x04068DA6C83AFCFA0e13ba15A6696662335D5B75;
    address constant WBTC = 0x321162Cd933E2Be498Cd2267a90534A804051b11;
    address constant WETH = 0x74b23882a30290451A17c44f4F05243b6b58C76d;
    address constant WFTM = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;
    address constant DAI = 0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E;

    AggregatorV3Interface constant ETH_USD_FEED = AggregatorV3Interface(0x11DdD3d147E5b83D01cee7070027092397d63658);
    uint24 constant ETH_USD_STALEAFTER = 300;
    uint8 constant ETH_USD_DECIMALS = 8;

    AggregatorV3Interface constant DAI_USD_FEED = AggregatorV3Interface(0x91d5DEFAFfE2854C7D02F50c80FA1fdc8A721e52);
    uint24 constant DAI_USD_STALEAFTER = 1 days;
    uint8 constant DAI_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDC_USD_FEED = AggregatorV3Interface(0x2553f4eeb82d5A26427b8d1106C51499CBa5D99c);
    uint24 constant USDC_USD_STALEAFTER = 1 days;
    uint8 constant USDC_USD_DECIMALS = 8;

    AggregatorV3Interface constant FTM_USD_FEED = AggregatorV3Interface(0xf4766552D15AE4d256Ad41B6cf2933482B0680dc);
    uint24 constant FTM_USD_STALEAFTER = 60;
    uint8 constant FTM_USD_DECIMALS = 8;

    AggregatorV3Interface constant WBTC_USD_FEED = AggregatorV3Interface(0x9Da678cE7f28aAeC8A578A1e414219049509a552);
    uint24 constant WBTC_USD_STALEAFTER = 300;
    uint8 constant WBTC_USD_DECIMALS = 8;

    /**
     * Pairs:
     * 0: USDC/WETH
     * 1: USDC/WBTC
     * 2: USDC/FTM
     * 3: USDC/DAI
     * 4: WBTC/WETH
     * 5: WBTC/FTM
     * 6: WBTC/DAI
     * 7: WETH/FTM
     * 8: WETH/DAI
     * 9: FTM/DAI
     */

    function setUp() public {
        $weth9 = WFTM;

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

        // USDC/FTM
        ChainlinkOracleImpl.Feed[] memory usdcFtmFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcFtmFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcFtmFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: FTM_USD_FEED,
            decimals: FTM_USD_DECIMALS,
            staleAfter: FTM_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: WFTM}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcFtmFeeds.getPath(), inverted: false})
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

        // WBTC/FTM
        ChainlinkOracleImpl.Feed[] memory wbtcFtmFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcFtmFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcFtmFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: FTM_USD_FEED,
            decimals: FTM_USD_DECIMALS,
            staleAfter: FTM_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: WFTM}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcFtmFeeds.getPath(), inverted: false})
            })
        );

        // WBTC/DAI
        ChainlinkOracleImpl.Feed[] memory wbtcDaiFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcDaiFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_USD_FEED,
            decimals: WBTC_USD_DECIMALS,
            staleAfter: WBTC_USD_STALEAFTER,
            mul: true
        });
        wbtcDaiFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WBTC, quote: DAI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wbtcDaiFeeds.getPath(), inverted: false})
            })
        );

        // WETH/FTM
        ChainlinkOracleImpl.Feed[] memory wethFtmFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethFtmFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethFtmFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: FTM_USD_FEED,
            decimals: FTM_USD_DECIMALS,
            staleAfter: FTM_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH, quote: WFTM}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethFtmFeeds.getPath(), inverted: false})
            })
        );

        // WETH/DAI
        ChainlinkOracleImpl.Feed[] memory wethDaiFeeds = new ChainlinkOracleImpl.Feed[](2);
        wethDaiFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: true
        });
        wethDaiFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WETH, quote: DAI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: wethDaiFeeds.getPath(), inverted: false})
            })
        );

        // FTM/DAI
        ChainlinkOracleImpl.Feed[] memory ftmDaiFeeds = new ChainlinkOracleImpl.Feed[](2);
        ftmDaiFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: FTM_USD_FEED,
            decimals: FTM_USD_DECIMALS,
            staleAfter: FTM_USD_STALEAFTER,
            mul: true
        });
        ftmDaiFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: WFTM, quote: DAI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: ftmDaiFeeds.getPath(), inverted: false})
            })
        );
    }
}
