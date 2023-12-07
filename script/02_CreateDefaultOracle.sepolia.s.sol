// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultOracle.base.s.sol";

contract CreateDefaultOracleSepoliaScript is CreateDefaultOracleBaseScript {
    using stdJson for string;

    address constant WETH9 = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
    address constant USDC = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;

    function setUp() public {
        $uniswapV3Factory = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c;
        $uniV3OracleFactory = 0x074827E8bD77B0A66c6008a51AF9BD1F33105caf;

        $owner = address(0x0);
        $paused = false;
        $defaultPeriod = 30 minutes;

        $pairDetails.push(PairDetail({tokenA: WETH9, tokenB: USDC, poolFee: uint24(5_00), period: uint32(0)}));
    }
}
