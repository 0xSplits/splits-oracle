// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultOracle.base.s.sol";

contract CreateDefaultOracleGoerliScript is CreateDefaultOracleBaseScript {
    using stdJson for string;

    address constant WETH9 = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address constant DAI = 0xdc31Ee1784292379Fbb2964b3B9C4124D8F89C60;
    address constant USDC = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;
    address constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;

    function setUp() public {
        $owner = address(0x0);
        $paused = false;
        $defaultPeriod = 30 minutes;

        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: USDC, poolFee: uint24(1_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: DAI, poolFee: uint24(5_00), period: uint32(0)}));
        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: UNI, poolFee: uint24(5_00), period: uint32(60 minutes)}));
        $pairDetails.push(PairDetail({tokenA: UNI, tokenB: USDC, poolFee: uint24(30_00), period: uint32(0)}));
    }
}
