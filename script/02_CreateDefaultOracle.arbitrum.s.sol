// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultOracleL2.base.s.sol";

contract CreateDefaultOracleArbitrumScript is CreateDefaultOracleBaseScript {
    using stdJson for string;

    address constant WETH9 = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant USDCE = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant GMX = 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a;
    address constant ARB = 0x912CE59144191C1204E64559FE8253a0e49E6548;
    address constant USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address constant WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address constant WSTETH = 0x5979D7b546E38E414F7E9822514be443A4800529;
    address constant PENDLE = 0x0c880f6761F1af8d9Aa9C466984b80DAb9a8c9e8;
    address constant LINK = 0xf97f4df75117a78c1A5a0DBb814Af92458539FB4;
    address constant RDNT = 0x3082CC23568eA640225c2467653dB90e9250AaA0;
    address constant UNI = 0xFa7F8980b0f1E64A2062791cc3b0871572f1F7f0;

    function setUp() public {
        $owner = address(0x0);
        $paused = false;
        $defaultPeriod = 30 minutes;

        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: USDCE, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: USDC, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: GMX, poolFee: ONE_PERCENT, period: uint32(0)}));
        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: WBTC, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: ARB, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)}));
        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: USDT, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: WSTETH, poolFee: POINT_ZERO_ONE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: DAI, poolFee: POINT_ZERO_ONE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: USDT, poolFee: POINT_ZERO_ONE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: LINK, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: PENDLE, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: RDNT, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
    }
}
