// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {QuotePair} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultChainlinkOracle.base.s.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultChainlinkOracleMainnetScript is CreateDefaultOracleBaseScript {
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant MKR = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address constant LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address constant LDO = 0x5A98FcBEA516Cf06857215779Fd812CA3beF1B32;
    address constant RPL = 0xD33526068D116cE69F19A9ee46F0bd304F21A51f;
    address constant MATIC = 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0;
    address constant YFI = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
    address constant BADGER = 0x3472A5A71965499acd81997a54BBA8D852C6E53d;
    address constant FXS = 0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0;
    address constant RETH = 0xae78736Cd615f374D3085123A210448E74Fc6393;
    address constant APE = 0x4d224452801ACEd8B2F0aebE155379bb5D594381;
    address constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;

    AggregatorV3Interface constant ETH_USD_FEED = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    uint24 constant ETH_USD_STALEAFTER = 1 hours;
    uint8 constant ETH_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDC_USD_FEED = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
    uint24 constant USDC_USD_STALEAFTER = 1 days;
    uint8 constant USDC_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDC_ETH_FEED = AggregatorV3Interface(0x986b5E1e1755e3C2440e960477f25201B0a8bbD4);
    uint24 constant USDC_ETH_STALEAFTER = 1 days;
    uint8 constant USDC_ETH_DECIMALS = 18;

    AggregatorV3Interface constant USDT_USD_FEED = AggregatorV3Interface(0x3E7d1eAB13ad0104d2750B8863b489D65364e32D);
    uint24 constant USDT_USD_STALEAFTER = 1 days;
    uint8 constant USDT_USD_DECIMALS = 8;

    AggregatorV3Interface constant USDT_ETH_FEED = AggregatorV3Interface(0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46);
    uint24 constant USDT_ETH_STALEAFTER = 1 days;
    uint8 constant USDT_ETH_DECIMALS = 18;

    AggregatorV3Interface constant BTC_USD_FEED = AggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);
    uint24 constant BTC_USD_STALEAFTER = 1 hours;
    uint8 constant BTC_USD_DECIMALS = 8;

    AggregatorV3Interface constant BTC_ETH_FEED = AggregatorV3Interface(0xdeb288F737066589598e9214E782fa5A8eD689e8);
    uint24 constant BTC_ETH_STALEAFTER = 1 days;
    uint8 constant BTC_ETH_DECIMALS = 18;

    AggregatorV3Interface constant WBTC_BTC_FEED = AggregatorV3Interface(0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23);
    uint24 constant WBTC_BTC_STALEAFTER = 1 days;
    uint8 constant WBTC_BTC_DECIMALS = 8;

    AggregatorV3Interface constant DAI_USD_FEED = AggregatorV3Interface(0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9);
    uint24 constant DAI_USD_STALEAFTER = 1 hours;
    uint8 constant DAI_USD_DECIMALS = 8;

    AggregatorV3Interface constant DAI_ETH_FEED = AggregatorV3Interface(0x773616E4d11A78F511299002da57A0a94577F1f4);
    uint24 constant DAI_ETH_STALEAFTER = 1 days;
    uint8 constant DAI_ETH_DECIMALS = 18;

    AggregatorV3Interface constant MKR_USD_FEED = AggregatorV3Interface(0xec1D1B3b0443256cc3860e24a46F108e699484Aa);
    uint24 constant MKR_USD_STALEAFTER = 1 hours;
    uint8 constant MKR_USD_DECIMALS = 8;

    AggregatorV3Interface constant MKR_ETH_FEED = AggregatorV3Interface(0x24551a8Fb2A7211A25a17B1481f043A8a8adC7f2);
    uint24 constant MKR_ETH_STALEAFTER = 1 days;
    uint8 constant MKR_ETH_DECIMALS = 18;

    AggregatorV3Interface constant LINK_USD_FEED = AggregatorV3Interface(0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c);
    uint24 constant LINK_USD_STALEAFTER = 1 hours;
    uint8 constant LINK_USD_DECIMALS = 8;

    AggregatorV3Interface constant LINK_ETH_FEED = AggregatorV3Interface(0xDC530D9457755926550b59e8ECcdaE7624181557);
    uint24 constant LINK_ETH_STALEAFTER = 21600;
    uint8 constant LINK_ETH_DECIMALS = 18;

    AggregatorV3Interface constant UNI_USD_FEED = AggregatorV3Interface(0x553303d460EE0afB37EdFf9bE42922D8FF63220e);
    uint24 constant UNI_USD_STALEAFTER = 1 hours;
    uint8 constant UNI_USD_DECIMALS = 8;

    AggregatorV3Interface constant UNI_ETH_FEED = AggregatorV3Interface(0xD6aA3D25116d8dA79Ea0246c4826EB951872e02e);
    uint24 constant UNI_ETH_STALEAFTER = 1 days;
    uint8 constant UNI_ETH_DECIMALS = 18;

    AggregatorV3Interface constant LDO_ETH_FEED = AggregatorV3Interface(0x4e844125952D32AcdF339BE976c98E22F6F318dB);
    uint24 constant LDO_ETH_STALEAFTER = 1 days;
    uint8 constant LDO_ETH_DECIMALS = 18;

    AggregatorV3Interface constant RPL_USD_FEED = AggregatorV3Interface(0x4E155eD98aFE9034b7A5962f6C84c86d869daA9d);
    uint24 constant RPL_USD_STALEAFTER = 1 days;
    uint8 constant RPL_USD_DECIMALS = 8;

    AggregatorV3Interface constant MATIC_USD_FEED = AggregatorV3Interface(0x7bAC85A8a13A4BcD8abb3eB7d6b4d632c5a57676);
    uint24 constant MATIC_USD_STALEAFTER = 1 hours;
    uint8 constant MATIC_USD_DECIMALS = 8;

    AggregatorV3Interface constant YFI_USD_FEED = AggregatorV3Interface(0xA027702dbb89fbd58938e4324ac03B58d812b0E1);
    uint24 constant YFI_USD_STALEAFTER = 1 hours;
    uint8 constant YFI_USD_DECIMALS = 8;

    AggregatorV3Interface constant YFI_ETH_FEED = AggregatorV3Interface(0x7c5d4F8345e66f68099581Db340cd65B078C41f4);
    uint24 constant YFI_ETH_STALEAFTER = 1 days;
    uint8 constant YFI_ETH_DECIMALS = 18;

    AggregatorV3Interface constant BADGER_ETH_FEED = AggregatorV3Interface(0x58921Ac140522867bf50b9E009599Da0CA4A2379);
    uint24 constant BADGER_ETH_STALEAFTER = 1 days;
    uint8 constant BADGER_ETH_DECIMALS = 18;

    AggregatorV3Interface constant FXS_USD_FEED = AggregatorV3Interface(0x6Ebc52C8C1089be9eB3945C4350B68B8E4C2233f);
    uint24 constant FXS_USD_STALEAFTER = 1 days;
    uint8 constant FXS_USD_DECIMALS = 8;

    AggregatorV3Interface constant RETH_ETH_FEED = AggregatorV3Interface(0x536218f9E9Eb48863970252233c8F271f554C2d0);
    uint24 constant RETH_ETH_STALEAFTER = 1 days;
    uint8 constant RETH_ETH_DECIMALS = 18;

    AggregatorV3Interface constant APE_USD_FEED = AggregatorV3Interface(0xD10aBbC76679a20055E167BB80A24ac851b37056);
    uint24 constant APE_USD_STALEAFTER = 1 days;
    uint8 constant APE_USD_DECIMALS = 8;

    AggregatorV3Interface constant APE_ETH_FEED = AggregatorV3Interface(0xc7de7f4d4C9c991fF62a07D18b3E31e349833A18);
    uint24 constant APE_ETH_STALEAFTER = 1 days;
    uint8 constant APE_ETH_DECIMALS = 18;

    AggregatorV3Interface constant CRV_USD_FEED = AggregatorV3Interface(0xCd627aA160A6fA45Eb793D19Ef54f5062F20f33f);
    uint24 constant CRV_USD_STALEAFTER = 1 days;
    uint8 constant CRV_USD_DECIMALS = 8;

    AggregatorV3Interface constant CRV_ETH_FEED = AggregatorV3Interface(0x8a12Be339B0cD1829b91Adc01977caa5E9ac121e);
    uint24 constant CRV_ETH_STALEAFTER = 1 days;
    uint8 constant CRV_ETH_DECIMALS = 18;

    /**
     * Pairs:
     * 0: USDC/WETH
     * 1: USDC/WBTC
     * 2: USDC/USDT
     * 3: USDC/DAI
     * 4: USDC/MKR
     * 5: USDC/LINK
     * 6: USDC/UNI
     * 7: USDC/LDO
     * 8: USDC/RPL
     * 9: USDC/MATIC
     * 10: USDC/YFI
     * 11: USDC/BADGER
     * 12: USDC/FXS
     * 13: USDC/RETH
     * 14: USDC/APE
     * 15: USDC/CRV
     * 16: USDT/WETH
     * 17: USDT/WBTC
     * 18: USDT/DAI
     * 19: USDT/MKR
     * 20: USDT/LINK
     * 21: USDT/UNI
     * 22: USDT/LDO
     * 23: USDT/RPL
     * 24: USDT/MATIC
     * 25: USDT/YFI
     * 26: USDT/BADGER
     * 27: USDT/FXS
     * 28: USDT/RETH
     * 29: USDT/APE
     * 30: USDT/CRV
     * 31: DAI/WETH
     * 32: DAI/WBTC
     * 33: DAI/MKR
     * 34: DAI/LINK
     * 35: DAI/UNI
     * 36: DAI/LDO
     * 37: DAI/RPL
     * 38: DAI/MATIC
     * 39: DAI/YFI
     * 40: DAI/BADGER
     * 41: DAI/FXS
     * 42: DAI/RETH
     * 43: DAI/APE
     * 44: DAI/CRV
     * 45: WBTC/WETH
     * 46: MKR/WETH
     * 47: LINK/WETH
     * 48: UNI/WETH
     * 49: LDO/WETH
     * 50: RPL/WETH
     * 51: MATIC/WETH
     * 52: YFI/WETH
     * 53: BADGER/WETH
     * 54: FXS/WETH
     * 55: RETH/WETH
     * 56: APE/WETH
     * 57: CRV/WETH
     */

    function setUp() public {
        $owner = address(0);
        $paused = false;

        setUpPairDetails();
    }

    function setUpPairDetails() private {
        // 0: USDC/WETH
        ChainlinkOracleImpl.Feed[] memory usdcWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        usdcWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_ETH_FEED,
            decimals: USDC_ETH_DECIMALS,
            staleAfter: USDC_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcWethFeeds.getPath(), inverted: false})
            })
        );

        // 1: USDC/WBTC
        ChainlinkOracleImpl.Feed[] memory usdcWbtcFeeds = new ChainlinkOracleImpl.Feed[](3);
        usdcWbtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcWbtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: false
        });
        usdcWbtcFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WBTC_BTC_FEED,
            decimals: WBTC_BTC_DECIMALS,
            staleAfter: WBTC_BTC_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: WBTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcWbtcFeeds.getPath(), inverted: false})
            })
        );

        // 2: USDC/USDT
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

        // 3: USDC/DAI
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

        // 4: USDC/MKR
        ChainlinkOracleImpl.Feed[] memory usdcMkrFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcMkrFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcMkrFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: MKR_USD_FEED,
            decimals: MKR_USD_DECIMALS,
            staleAfter: MKR_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: MKR}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcMkrFeeds.getPath(), inverted: false})
            })
        );

        // 5: USDC/LINK
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

        // 6: USDC/UNI
        ChainlinkOracleImpl.Feed[] memory usdcUniFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcUniFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcUniFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: UNI_USD_FEED,
            decimals: UNI_USD_DECIMALS,
            staleAfter: UNI_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: UNI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcUniFeeds.getPath(), inverted: false})
            })
        );

        // 7: USDC/LDO
        ChainlinkOracleImpl.Feed[] memory usdcLdoFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcLdoFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_ETH_FEED,
            decimals: USDC_ETH_DECIMALS,
            staleAfter: USDC_ETH_STALEAFTER,
            mul: true
        });
        usdcLdoFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: LDO_ETH_FEED,
            decimals: LDO_ETH_DECIMALS,
            staleAfter: LDO_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: LDO}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcLdoFeeds.getPath(), inverted: false})
            })
        );

        // 8: USDC/RPL
        ChainlinkOracleImpl.Feed[] memory usdcRplFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcRplFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcRplFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RPL_USD_FEED,
            decimals: RPL_USD_DECIMALS,
            staleAfter: RPL_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: RPL}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcRplFeeds.getPath(), inverted: false})
            })
        );

        // 9: USDC/MATIC
        ChainlinkOracleImpl.Feed[] memory usdcMaticFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcMaticFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcMaticFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: MATIC_USD_FEED,
            decimals: MATIC_USD_DECIMALS,
            staleAfter: MATIC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: MATIC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcMaticFeeds.getPath(), inverted: false})
            })
        );

        // 10: USDC/YFI
        ChainlinkOracleImpl.Feed[] memory usdcYfiFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcYfiFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_ETH_FEED,
            decimals: USDC_ETH_DECIMALS,
            staleAfter: USDC_ETH_STALEAFTER,
            mul: true
        });
        usdcYfiFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: YFI_ETH_FEED,
            decimals: YFI_ETH_DECIMALS,
            staleAfter: YFI_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: YFI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcYfiFeeds.getPath(), inverted: false})
            })
        );

        // 11: USDC/BADGER
        ChainlinkOracleImpl.Feed[] memory usdcBadgerFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcBadgerFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_ETH_FEED,
            decimals: USDC_ETH_DECIMALS,
            staleAfter: USDC_ETH_STALEAFTER,
            mul: true
        });
        usdcBadgerFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BADGER_ETH_FEED,
            decimals: BADGER_ETH_DECIMALS,
            staleAfter: BADGER_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: BADGER}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcBadgerFeeds.getPath(), inverted: false})
            })
        );

        // 12: USDC/FXS
        ChainlinkOracleImpl.Feed[] memory usdcFxsFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcFxsFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcFxsFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: FXS_USD_FEED,
            decimals: FXS_USD_DECIMALS,
            staleAfter: FXS_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: FXS}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcFxsFeeds.getPath(), inverted: false})
            })
        );

        // 13: USDC/RETH
        ChainlinkOracleImpl.Feed[] memory usdcRethFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcRethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_ETH_FEED,
            decimals: USDC_ETH_DECIMALS,
            staleAfter: USDC_ETH_STALEAFTER,
            mul: true
        });
        usdcRethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RETH_ETH_FEED,
            decimals: RETH_ETH_DECIMALS,
            staleAfter: RETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: RETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcRethFeeds.getPath(), inverted: false})
            })
        );

        // 14: USDC/APE
        ChainlinkOracleImpl.Feed[] memory usdcApeFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcApeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_USD_FEED,
            decimals: USDC_USD_DECIMALS,
            staleAfter: USDC_USD_STALEAFTER,
            mul: true
        });
        usdcApeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: APE_USD_FEED,
            decimals: APE_USD_DECIMALS,
            staleAfter: APE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: APE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcApeFeeds.getPath(), inverted: false})
            })
        );

        // 15: USDC/CRV
        ChainlinkOracleImpl.Feed[] memory usdcCrvFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdcCrvFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDC_ETH_FEED,
            decimals: USDC_ETH_DECIMALS,
            staleAfter: USDC_ETH_STALEAFTER,
            mul: true
        });
        usdcCrvFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: CRV_ETH_FEED,
            decimals: CRV_ETH_DECIMALS,
            staleAfter: CRV_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDC, quote: CRV}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcCrvFeeds.getPath(), inverted: false})
            })
        );

        // 16: USDT/WETH
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

        // 17: USDT/WBTC
        ChainlinkOracleImpl.Feed[] memory usdtWbtcFeeds = new ChainlinkOracleImpl.Feed[](3);
        usdtWbtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtWbtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: false
        });
        usdtWbtcFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WBTC_BTC_FEED,
            decimals: WBTC_BTC_DECIMALS,
            staleAfter: WBTC_BTC_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: WBTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtWbtcFeeds.getPath(), inverted: false})
            })
        );

        // 18: USDT/DAI
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

        // 19: USDT/MKR
        ChainlinkOracleImpl.Feed[] memory usdtMkrFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtMkrFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtMkrFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: MKR_USD_FEED,
            decimals: MKR_USD_DECIMALS,
            staleAfter: MKR_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: MKR}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtMkrFeeds.getPath(), inverted: false})
            })
        );

        // 20: USDT/LINK
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

        // 21: USDT/UNI
        ChainlinkOracleImpl.Feed[] memory usdtUniFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtUniFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtUniFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: UNI_USD_FEED,
            decimals: UNI_USD_DECIMALS,
            staleAfter: UNI_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: UNI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtUniFeeds.getPath(), inverted: false})
            })
        );

        // 22: USDT/LDO
        ChainlinkOracleImpl.Feed[] memory usdtLdoFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtLdoFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_ETH_FEED,
            decimals: USDT_ETH_DECIMALS,
            staleAfter: USDT_ETH_STALEAFTER,
            mul: true
        });
        usdtLdoFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: LDO_ETH_FEED,
            decimals: LDO_ETH_DECIMALS,
            staleAfter: LDO_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: LDO}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtLdoFeeds.getPath(), inverted: false})
            })
        );

        // 23: USDT/RPL
        ChainlinkOracleImpl.Feed[] memory usdtRplFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtRplFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtRplFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RPL_USD_FEED,
            decimals: RPL_USD_DECIMALS,
            staleAfter: RPL_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: RPL}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtRplFeeds.getPath(), inverted: false})
            })
        );

        // 24: USDT/MATIC
        ChainlinkOracleImpl.Feed[] memory usdtMaticFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtMaticFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtMaticFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: MATIC_USD_FEED,
            decimals: MATIC_USD_DECIMALS,
            staleAfter: MATIC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: MATIC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtMaticFeeds.getPath(), inverted: false})
            })
        );

        // 25: USDT/YFI
        ChainlinkOracleImpl.Feed[] memory usdtYfiFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtYfiFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_ETH_FEED,
            decimals: USDT_ETH_DECIMALS,
            staleAfter: USDT_ETH_STALEAFTER,
            mul: true
        });
        usdtYfiFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: YFI_ETH_FEED,
            decimals: YFI_ETH_DECIMALS,
            staleAfter: YFI_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: YFI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtYfiFeeds.getPath(), inverted: false})
            })
        );

        // 26: USDT/BADGER
        ChainlinkOracleImpl.Feed[] memory usdtBadgerFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtBadgerFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_ETH_FEED,
            decimals: USDT_ETH_DECIMALS,
            staleAfter: USDT_ETH_STALEAFTER,
            mul: true
        });
        usdtBadgerFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BADGER_ETH_FEED,
            decimals: BADGER_ETH_DECIMALS,
            staleAfter: BADGER_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: BADGER}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtBadgerFeeds.getPath(), inverted: false})
            })
        );

        // 27: USDT/FXS
        ChainlinkOracleImpl.Feed[] memory usdtFxsFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtFxsFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtFxsFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: FXS_USD_FEED,
            decimals: FXS_USD_DECIMALS,
            staleAfter: FXS_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: FXS}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtFxsFeeds.getPath(), inverted: false})
            })
        );

        // 28: USDT/RETH
        ChainlinkOracleImpl.Feed[] memory usdtRethFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtRethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_ETH_FEED,
            decimals: USDT_ETH_DECIMALS,
            staleAfter: USDT_ETH_STALEAFTER,
            mul: true
        });
        usdtRethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RETH_ETH_FEED,
            decimals: RETH_ETH_DECIMALS,
            staleAfter: RETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: RETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtRethFeeds.getPath(), inverted: false})
            })
        );

        // 29: USDT/APE
        ChainlinkOracleImpl.Feed[] memory usdtApeFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtApeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_USD_FEED,
            decimals: USDT_USD_DECIMALS,
            staleAfter: USDT_USD_STALEAFTER,
            mul: true
        });
        usdtApeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: APE_USD_FEED,
            decimals: APE_USD_DECIMALS,
            staleAfter: APE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: APE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtApeFeeds.getPath(), inverted: false})
            })
        );

        // 30: USDT/CRV
        ChainlinkOracleImpl.Feed[] memory usdtCrvFeeds = new ChainlinkOracleImpl.Feed[](2);
        usdtCrvFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: USDT_ETH_FEED,
            decimals: USDT_ETH_DECIMALS,
            staleAfter: USDT_ETH_STALEAFTER,
            mul: true
        });
        usdtCrvFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: CRV_ETH_FEED,
            decimals: CRV_ETH_DECIMALS,
            staleAfter: CRV_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: USDT, quote: CRV}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdtCrvFeeds.getPath(), inverted: false})
            })
        );

        // 31: DAI/WETH
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

        // 32: DAI/WBTC
        ChainlinkOracleImpl.Feed[] memory daiWbtcFeeds = new ChainlinkOracleImpl.Feed[](3);
        daiWbtcFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiWbtcFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BTC_USD_FEED,
            decimals: BTC_USD_DECIMALS,
            staleAfter: BTC_USD_STALEAFTER,
            mul: false
        });
        daiWbtcFeeds[2] = ChainlinkOracleImpl.Feed({
            feed: WBTC_BTC_FEED,
            decimals: WBTC_BTC_DECIMALS,
            staleAfter: WBTC_BTC_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: WBTC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiWbtcFeeds.getPath(), inverted: false})
            })
        );

        // 33: DAI/MKR
        ChainlinkOracleImpl.Feed[] memory daiMkrFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiMkrFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiMkrFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: MKR_USD_FEED,
            decimals: MKR_USD_DECIMALS,
            staleAfter: MKR_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: MKR}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiMkrFeeds.getPath(), inverted: false})
            })
        );

        // 34: DAI/LINK
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

        // 35: DAI/UNI
        ChainlinkOracleImpl.Feed[] memory daiUniFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiUniFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiUniFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: UNI_USD_FEED,
            decimals: UNI_USD_DECIMALS,
            staleAfter: UNI_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: UNI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiUniFeeds.getPath(), inverted: false})
            })
        );

        // 36: DAI/LDO
        ChainlinkOracleImpl.Feed[] memory daiLdoFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiLdoFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_ETH_FEED,
            decimals: DAI_ETH_DECIMALS,
            staleAfter: DAI_ETH_STALEAFTER,
            mul: true
        });
        daiLdoFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: LDO_ETH_FEED,
            decimals: LDO_ETH_DECIMALS,
            staleAfter: LDO_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: LDO}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiLdoFeeds.getPath(), inverted: false})
            })
        );

        // 37: DAI/RPL
        ChainlinkOracleImpl.Feed[] memory daiRplFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiRplFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiRplFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RPL_USD_FEED,
            decimals: RPL_USD_DECIMALS,
            staleAfter: RPL_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: RPL}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiRplFeeds.getPath(), inverted: false})
            })
        );

        // 38: DAI/MATIC
        ChainlinkOracleImpl.Feed[] memory daiMaticFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiMaticFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiMaticFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: MATIC_USD_FEED,
            decimals: MATIC_USD_DECIMALS,
            staleAfter: MATIC_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: MATIC}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiMaticFeeds.getPath(), inverted: false})
            })
        );

        // 39: DAI/YFI
        ChainlinkOracleImpl.Feed[] memory daiYfiFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiYfiFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_ETH_FEED,
            decimals: DAI_ETH_DECIMALS,
            staleAfter: DAI_ETH_STALEAFTER,
            mul: true
        });
        daiYfiFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: YFI_ETH_FEED,
            decimals: YFI_ETH_DECIMALS,
            staleAfter: YFI_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: YFI}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiYfiFeeds.getPath(), inverted: false})
            })
        );

        // 40: DAI/BADGER
        ChainlinkOracleImpl.Feed[] memory daiBadgerFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiBadgerFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_ETH_FEED,
            decimals: DAI_ETH_DECIMALS,
            staleAfter: DAI_ETH_STALEAFTER,
            mul: true
        });
        daiBadgerFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: BADGER_ETH_FEED,
            decimals: BADGER_ETH_DECIMALS,
            staleAfter: BADGER_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: BADGER}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiBadgerFeeds.getPath(), inverted: false})
            })
        );

        // 41: DAI/FXS
        ChainlinkOracleImpl.Feed[] memory daiFxsFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiFxsFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiFxsFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: FXS_USD_FEED,
            decimals: FXS_USD_DECIMALS,
            staleAfter: FXS_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: FXS}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiFxsFeeds.getPath(), inverted: false})
            })
        );

        // 42: DAI/RETH
        ChainlinkOracleImpl.Feed[] memory daiRethFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiRethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_ETH_FEED,
            decimals: DAI_ETH_DECIMALS,
            staleAfter: DAI_ETH_STALEAFTER,
            mul: true
        });
        daiRethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: RETH_ETH_FEED,
            decimals: RETH_ETH_DECIMALS,
            staleAfter: RETH_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: RETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiRethFeeds.getPath(), inverted: false})
            })
        );

        // 43: DAI/APE
        ChainlinkOracleImpl.Feed[] memory daiApeFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiApeFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_USD_FEED,
            decimals: DAI_USD_DECIMALS,
            staleAfter: DAI_USD_STALEAFTER,
            mul: true
        });
        daiApeFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: APE_USD_FEED,
            decimals: APE_USD_DECIMALS,
            staleAfter: APE_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: APE}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiApeFeeds.getPath(), inverted: false})
            })
        );

        // 44: DAI/CRV
        ChainlinkOracleImpl.Feed[] memory daiCrvFeeds = new ChainlinkOracleImpl.Feed[](2);
        daiCrvFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: DAI_ETH_FEED,
            decimals: DAI_ETH_DECIMALS,
            staleAfter: DAI_ETH_STALEAFTER,
            mul: true
        });
        daiCrvFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: CRV_ETH_FEED,
            decimals: CRV_ETH_DECIMALS,
            staleAfter: CRV_ETH_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: DAI, quote: CRV}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: daiCrvFeeds.getPath(), inverted: false})
            })
        );

        // 45: WBTC/WETH
        ChainlinkOracleImpl.Feed[] memory wbtcWethFeeds = new ChainlinkOracleImpl.Feed[](2);
        wbtcWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: WBTC_BTC_FEED,
            decimals: WBTC_BTC_DECIMALS,
            staleAfter: WBTC_BTC_STALEAFTER,
            mul: true
        });
        wbtcWethFeeds[1] = ChainlinkOracleImpl.Feed({
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

        // 46: MKR/WETH
        ChainlinkOracleImpl.Feed[] memory mkrWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        mkrWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: MKR_ETH_FEED,
            decimals: MKR_ETH_DECIMALS,
            staleAfter: MKR_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: MKR, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: mkrWethFeeds.getPath(), inverted: false})
            })
        );

        // 47: LINK/WETH
        ChainlinkOracleImpl.Feed[] memory linkWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        linkWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: LINK_ETH_FEED,
            decimals: LINK_ETH_DECIMALS,
            staleAfter: LINK_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: LINK, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: linkWethFeeds.getPath(), inverted: false})
            })
        );

        // 48: UNI/WETH
        ChainlinkOracleImpl.Feed[] memory uniWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        uniWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: UNI_ETH_FEED,
            decimals: UNI_ETH_DECIMALS,
            staleAfter: UNI_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: UNI, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: uniWethFeeds.getPath(), inverted: false})
            })
        );

        // 49: LDO/WETH
        ChainlinkOracleImpl.Feed[] memory ldoWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        ldoWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: LDO_ETH_FEED,
            decimals: LDO_ETH_DECIMALS,
            staleAfter: LDO_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: LDO, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: ldoWethFeeds.getPath(), inverted: false})
            })
        );

        // 50: RPL/WETH
        ChainlinkOracleImpl.Feed[] memory rplWethFeeds = new ChainlinkOracleImpl.Feed[](2);
        rplWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: RPL_USD_FEED,
            decimals: RPL_USD_DECIMALS,
            staleAfter: RPL_USD_STALEAFTER,
            mul: true
        });
        rplWethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: RPL, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: rplWethFeeds.getPath(), inverted: false})
            })
        );

        // 51: MATIC/WETH
        ChainlinkOracleImpl.Feed[] memory maticWethFeeds = new ChainlinkOracleImpl.Feed[](2);
        maticWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: MATIC_USD_FEED,
            decimals: MATIC_USD_DECIMALS,
            staleAfter: MATIC_USD_STALEAFTER,
            mul: true
        });
        maticWethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: MATIC, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: maticWethFeeds.getPath(), inverted: false})
            })
        );

        // 52: YFI/WETH
        ChainlinkOracleImpl.Feed[] memory yfiWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        yfiWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: YFI_ETH_FEED,
            decimals: YFI_ETH_DECIMALS,
            staleAfter: YFI_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: YFI, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: yfiWethFeeds.getPath(), inverted: false})
            })
        );

        // 53: BADGER/WETH
        ChainlinkOracleImpl.Feed[] memory badgerWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        badgerWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: BADGER_ETH_FEED,
            decimals: BADGER_ETH_DECIMALS,
            staleAfter: BADGER_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: BADGER, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: badgerWethFeeds.getPath(), inverted: false})
            })
        );

        // 54: FXS/WETH
        ChainlinkOracleImpl.Feed[] memory fxsWethFeeds = new ChainlinkOracleImpl.Feed[](2);
        fxsWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: FXS_USD_FEED,
            decimals: FXS_USD_DECIMALS,
            staleAfter: FXS_USD_STALEAFTER,
            mul: true
        });
        fxsWethFeeds[1] = ChainlinkOracleImpl.Feed({
            feed: ETH_USD_FEED,
            decimals: ETH_USD_DECIMALS,
            staleAfter: ETH_USD_STALEAFTER,
            mul: false
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: FXS, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: fxsWethFeeds.getPath(), inverted: false})
            })
        );

        // 55: RETH/WETH
        ChainlinkOracleImpl.Feed[] memory rethWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        rethWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: RETH_ETH_FEED,
            decimals: RETH_ETH_DECIMALS,
            staleAfter: RETH_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: RETH, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: rethWethFeeds.getPath(), inverted: false})
            })
        );

        // 56: APE/WETH
        ChainlinkOracleImpl.Feed[] memory apeWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        apeWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: APE_ETH_FEED,
            decimals: APE_ETH_DECIMALS,
            staleAfter: APE_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: APE, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: apeWethFeeds.getPath(), inverted: false})
            })
        );

        // 57: CRV/WETH
        ChainlinkOracleImpl.Feed[] memory crvWethFeeds = new ChainlinkOracleImpl.Feed[](1);
        crvWethFeeds[0] = ChainlinkOracleImpl.Feed({
            feed: CRV_ETH_FEED,
            decimals: CRV_ETH_DECIMALS,
            staleAfter: CRV_ETH_STALEAFTER,
            mul: true
        });
        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: CRV, quote: WETH}),
                pairDetail: ChainlinkOracleImpl.PairDetail({path: crvWethFeeds.getPath(), inverted: false})
            })
        );
    }
}
