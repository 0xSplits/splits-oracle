// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultOracle.base.s.sol";

contract CreateDefaultOracleOptimismScript is CreateDefaultOracleBaseScript {
    using stdJson for string;

    address constant WETH9 = 0x4200000000000000000000000000000000000006;
    address constant OP = 0x4200000000000000000000000000000000000042;
    address constant USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
    address constant WBTC = 0x68f180fcCe6836688e9084f035309E29Bf0A2095;
    address constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address constant USDT = 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58;
    address constant WSTETH = 0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb;

    function setUp() public {
        $uniswapV3Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
        $uniV3OracleFactory = address(0x498f316fEB85a250fdC64B859a130515491EC888); // need to deploy

        $owner = address(0x0);
        $paused = false;
        $defaultPeriod = 30 minutes;

        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: OP, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: USDC, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: WBTC, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: OP, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: DAI, poolFee: POINT_THREE_PERCENT, period: uint32(0)}));
        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: USDT, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: USDT, poolFee: POINT_ZERO_ONE_PERCENT, period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: USDC, tokenB: DAI, poolFee: POINT_ZERO_ONE_PERCENT, period: uint32(0)}));
        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: WSTETH, poolFee: POINT_ZERO_ONE_PERCENT, period: uint32(0)})
        );
        $pairDetails.push(
            PairDetail({tokenA: USDC, tokenB: WSTETH, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
    }
}
