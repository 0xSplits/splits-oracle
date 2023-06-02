// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {QuotePair} from "splits-utils/LibQuotes.sol";

import {UniV3OracleFactory} from "../src/UniV3OracleFactory.sol";
import {UniV3OracleImpl} from "../src/UniV3OracleImpl.sol";

contract CreateDefaultOracleBaseScript is Script {
    using stdJson for string;

    struct PairDetail {
        address tokenA;
        address tokenB;
        uint24 poolFee;
        uint32 period;
    }

    address $uniswapV3Factory;
    address $uniV3OracleFactory;

    address $owner;
    bool $paused;
    uint32 $defaultPeriod;
    PairDetail[] $pairDetails;

    function run() public returns (UniV3OracleImpl defaultOracle) {
        uint256 numPairs = $pairDetails.length;
        UniV3OracleImpl.SetPairDetailParams[] memory pairDetails = new UniV3OracleImpl.SetPairDetailParams[](numPairs);
        for (uint256 i = 0; i < numPairs; i++) {
            PairDetail memory pairDetail = $pairDetails[i];

            pairDetails[i] = UniV3OracleImpl.SetPairDetailParams({
                quotePair: QuotePair({base: pairDetail.tokenA, quote: pairDetail.tokenB}),
                pairDetail: UniV3OracleImpl.PairDetail({
                    pool: IUniswapV3Factory($uniswapV3Factory).getPool(pairDetail.tokenA, pairDetail.tokenB, pairDetail.poolFee),
                    period: pairDetail.period
                })
            });
        }

        UniV3OracleImpl.InitParams memory params = UniV3OracleImpl.InitParams({
            owner: $owner,
            paused: $paused,
            defaultPeriod: $defaultPeriod,
            pairDetails: pairDetails
        });

        uint256 privKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privKey);

        defaultOracle = UniV3OracleFactory($uniV3OracleFactory).createUniV3Oracle(params);

        vm.stopBroadcast();

        console2.log("Default Oracle Deployed:", address(defaultOracle));
    }
}
