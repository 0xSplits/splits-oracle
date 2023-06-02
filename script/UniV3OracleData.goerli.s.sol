// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "v3-core/interfaces/IUniswapV3Pool.sol";
import {OracleLibrary} from "v3-periphery/libraries/OracleLibrary.sol";
import {FullMath} from "v3-core/libraries/FullMath.sol";
import {TickMath} from "v3-core/libraries/TickMath.sol";

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract UniV3OracleDataScript is Script {
    // goerli
    address[4] tokens = [
        0xdc31Ee1784292379Fbb2964b3B9C4124D8F89C60, // DAI
        0x07865c6E87B9F70255377e024ace6630C1Eaa37F, // USDC
        0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6, // WETH
        0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984 // UNI
    ];

    string[4] tokensStr = [
        "DAI", // DAI
        "USDC", // USDC
        "WETH", // WETH
        "UNI" // UNI
    ];

    uint24[4] fees = [uint24(1_00), uint24(5_00), uint24(30_00), uint24(100_00)];

    string[4] feesStr = ["0.01%", "0.05%", "0.3%", "1.0%"];

    uint32[5] periods = [uint32(1 minutes), uint32(5 minutes), uint32(10 minutes), uint32(30 minutes), uint32(1 hours)];

    uint128 constant baseAmount = 1e18;

    function run() public view {
        IUniswapV3Factory uniswapV3Factory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
        for (uint256 i = 0; i < tokens.length; i++) {
            for (uint256 j = i; j < tokens.length; j++) {
                if (i == j) continue;

                for (uint256 k = 0; k < fees.length; k++) {
                    address pool = uniswapV3Factory.getPool(tokens[i], tokens[j], fees[k]);
                    if (pool == address(0)) {
                        console.log("no pool for (%s, %s, %s)", tokensStr[i], tokensStr[j], feesStr[k]);
                        continue;
                    }

                    console.log();
                    console.log("pool %s", pool);
                    console.log("(%s, %s, %s)", tokensStr[i], tokensStr[j], feesStr[k]);
                    (uint160 sqrtRatioX96, int24 tick,, uint16 observationCardinality,,,) = IUniswapV3Pool(pool).slot0();

                    console.log("tick: ");
                    console.logInt(tick);
                    console.log("sqrtRatioX96: %s", sqrtRatioX96);

                    uint256 quoteAmount = OracleLibrary.getQuoteAtTick({
                        tick: tick,
                        baseAmount: baseAmount,
                        baseToken: tokens[i],
                        quoteToken: tokens[j]
                    });
                    console.log("receive %s of %s for", quoteAmount, tokensStr[j]);
                    console.log(" %s of %s", baseAmount, tokensStr[i]);
                    console.log("num observations: ", observationCardinality);

                    console.log("twaps:");
                    for (uint256 a = 0; a < periods.length; a++) {
                        /* uint32 period = periods[a]; */

                        uint32[] memory secondsAgo = new uint32[](2);
                        secondsAgo[0] = periods[a];
                        secondsAgo[1] = 0;

                        // consult reverts if not enough observations
                        try IUniswapV3Pool(pool).observe(secondsAgo) {
                            (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity) =
                                OracleLibrary.consult({pool: pool, secondsAgo: periods[a]});
                            quoteAmount = OracleLibrary.getQuoteAtTick({
                                tick: arithmeticMeanTick,
                                baseAmount: baseAmount,
                                baseToken: tokens[i],
                                quoteToken: tokens[j]
                            });
                            console.log("%s second twap", periods[a]);
                            console.log("   liquidity:");
                            console.logUint(harmonicMeanLiquidity);
                            console.log("   tick:");
                            console.logInt(arithmeticMeanTick);
                            console.log("   receive %s of %s for", quoteAmount, tokensStr[j]);
                            console.log("    %s of %s", baseAmount, tokensStr[i]);
                        } catch {
                            console.log("- %s second twap: not enough observations", periods[a]);
                        }
                    }
                }
            }
        }
    }
}
