// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultOracle.base.s.sol";

contract CreateDefaultOracleMainnetScript is CreateDefaultOracleBaseScript {
    using stdJson for string;

    address constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address constant cbETH = 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704;
    address constant LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address constant MATIC = 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0;
    address constant RPL = 0xD33526068D116cE69F19A9ee46F0bd304F21A51f;
    address constant LDO = 0x5A98FcBEA516Cf06857215779Fd812CA3beF1B32;
    address constant MKR = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address constant rETH = 0xae78736Cd615f374D3085123A210448E74Fc6393;
    address constant sETH2 = 0xFe2e637202056d30016725477c5da089Ab0A043A;

    function setUp() public {
        $owner = address(0x0);
        $paused = false;
        $defaultPeriod = 30 minutes;

        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: USDC, poolFee: uint24(5_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: WBTC, poolFee: uint24(30_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: DAI, poolFee: uint24(1_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: USDT, poolFee: uint24(1_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: USDT, poolFee: uint24(5_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: WBTC, poolFee: uint24(30_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: UNI, poolFee: uint24(30_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WBTC, tokenB: USDT, poolFee: uint24(30_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: cbETH, poolFee: uint24(5_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: LINK, poolFee: uint24(30_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: DAI, poolFee: uint24(30_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: MATIC, poolFee: uint24(30_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: RPL, poolFee: uint24(30_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: LDO, poolFee: uint24(30_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: MKR, poolFee: uint24(30_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: rETH, poolFee: uint24(5_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: sETH2, poolFee: uint24(30_00), period: uint32(0)}));
    }
}
