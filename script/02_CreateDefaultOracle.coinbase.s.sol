// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {CreateDefaultOracleBaseScript} from "./02_CreateDefaultOracle.base.s.sol";

contract CreateDefaultOracleCoinbaseScript is CreateDefaultOracleBaseScript {
    using stdJson for string;

    address constant WETH9 = 0x4200000000000000000000000000000000000006;
    address constant USDC = 0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA;

    function setUp() public {
        $uniswapV3Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
        $uniV3OracleFactory = address(0x498f316fEB85a250fdC64B859a130515491EC888); // need to deploy

        $owner = address(0x0);
        $paused = false;
        $defaultPeriod = 30 minutes;

        $pairDetails.push(
            PairDetail({tokenA: WETH9, tokenB: USDC, poolFee: POINT_ZERO_FIVE_PERCENT, period: uint32(0)})
        );
    }
}
