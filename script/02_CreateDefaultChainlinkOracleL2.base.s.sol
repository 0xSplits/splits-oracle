// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";

import {QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";

import {ChainlinkOracleL2Factory} from "../src/chainlink/factory/ChainlinkOracleL2Factory.sol";
import {ChainlinkOracleL2Impl} from "../src/chainlink/oracle/ChainlinkOracleL2Impl.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultOracleBaseScript is Script {
    using stdJson for string;
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address $sequencerFeed;
    address $weth9;

    ChainlinkOracleL2Factory $chainlinkOracleFactory;

    address $owner;
    bool $paused;

    ChainlinkOracleImpl.SetPairDetailParams[] $pairDetails;

    function run()
        public
        returns (ChainlinkOracleL2Impl defaultOracle, ChainlinkOracleL2Factory chainlinkOracleFactory)
    {
        chainlinkOracleFactory = new ChainlinkOracleL2Factory($weth9, $sequencerFeed);
        ChainlinkOracleImpl.InitParams memory params = getInitialParams();
        bytes32 salt;
        defaultOracle = ChainlinkOracleL2Impl(chainlinkOracleFactory.createOracle(abi.encode(params), salt));
        verifyPairDetails(defaultOracle, params);
    }

    function getInitialParams() internal view returns (ChainlinkOracleImpl.InitParams memory params) {
        params = ChainlinkOracleImpl.InitParams({owner: $owner, paused: $paused, pairDetails: $pairDetails});
    }

    function verifyPairDetails(ChainlinkOracleL2Impl oracle, ChainlinkOracleImpl.InitParams memory params_)
        internal
        view
    {
        QuotePair[] memory quotePairs = new QuotePair[](params_.pairDetails.length);
        for (uint256 i = 0; i < params_.pairDetails.length; i++) {
            quotePairs[i] = params_.pairDetails[i].quotePair;
        }

        QuoteParams[] memory quoteParams = new QuoteParams[](quotePairs.length);
        for (uint256 i = 0; i < quotePairs.length; i++) {
            quoteParams[i] = QuoteParams({
                quotePair: quotePairs[i],
                baseAmount: uint128(10 ** IERC20(quotePairs[i].base).decimals()),
                data: ""
            });
        }

        uint256[] memory quoteAmounts = oracle.getQuoteAmounts(quoteParams);

        for (uint256 i = 0; i < quoteAmounts.length; i++) {
            console.log("Base: ", IERC20(quotePairs[i].base).symbol());
            console.log("Quote: ", IERC20(quotePairs[i].quote).symbol());
            console.log("Amount: ", quoteAmounts[i]);
        }
    }

    function getFactory() public returns (ChainlinkOracleL2Factory) {
        string memory json = readInput("inputs");
        return ChainlinkOracleL2Factory(json.readAddress(".chainlinkOracleFactory"));
    }

    function readJson(string memory input) internal view returns (bytes memory) {
        return vm.parseJson(readInput(input));
    }

    function readInput(string memory input) internal view returns (string memory) {
        string memory inputDir = string.concat(vm.projectRoot(), "/script/input/");
        string memory chainDir = string.concat(vm.toString(block.chainid), "/");
        string memory file = string.concat(input, ".json");
        return vm.readFile(string.concat(inputDir, chainDir, file));
    }
}
