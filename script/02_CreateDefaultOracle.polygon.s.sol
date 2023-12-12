// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultOracle.base.s.sol";

contract CreateDefaultOraclePolygonScript is CreateDefaultOracleBaseScript {
    using stdJson for string;

    address constant WETH9 = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address constant WBTC = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6;
    address constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address constant LINK = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;
    address constant DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address constant AAVE = 0xD6DF932A45C0f255f85145f286eA0b292B21C90B;
    address constant GNS = 0xE5417Af564e4bFDA1c483642db72007871397896;

    function setUp() public {
        $uniswapV3Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
        $uniV3OracleFactory = address(0x498f316fEB85a250fdC64B859a130515491EC888); // need to setup

        $owner = address(0x0);
        $paused = false;
        $defaultPeriod = 30 minutes;

        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: WBTC, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: USDC, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: WMATIC, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: LINK, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: AAVE, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(
            PairDetail({tokenA: USDC, tokenB: WMATIC, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: USDT, poolFee: POINT_ZERO_ONE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: WBTC, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: LINK, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: DAI, poolFee: POINT_ZERO_ONE_PERCENT, period: uint32(0)}));
        $pairDetails.push(
            PairDetail({tokenA: USDT, tokenB: WMATIC, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(PairDetail({tokenA: LINK, tokenB: WMATIC, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: AAVE, tokenB: WMATIC, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: GNS, tokenB: WMATIC, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: AAVE, tokenB: WETH9, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
    }
}
