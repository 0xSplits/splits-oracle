// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";

import {QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";

import {ChainlinkOracleFactory} from "../src/chainlink/factory/ChainlinkOracleFactory.sol";
import {ChainlinkOracleImpl} from "../src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../src/libraries/ChainlinkPath.sol";

contract CreateDefaultOracleBaseScript is Script {
    using stdJson for string;
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    address $weth9;

    ChainlinkOracleFactory $chainlinkOracleFactory;

    address $owner;
    bool $paused;

    ChainlinkOracleImpl.SetPairDetailParams[] $pairDetails;

    function run() public returns (ChainlinkOracleImpl defaultOracle, ChainlinkOracleFactory chainlinkOracleFactory) {
        chainlinkOracleFactory = new ChainlinkOracleFactory($weth9);
        ChainlinkOracleImpl.InitParams memory params = getInitialParams();
        bytes32 salt;
        defaultOracle = ChainlinkOracleImpl(chainlinkOracleFactory.createOracle(abi.encode(params), salt));
        verifyPairDetails(defaultOracle, params);
    }

    function getInitialParams() internal view returns (ChainlinkOracleImpl.InitParams memory params) {
        params = ChainlinkOracleImpl.InitParams({owner: $owner, paused: $paused, pairDetails: $pairDetails});
    }

    function verifyPairDetails(ChainlinkOracleImpl oracle, ChainlinkOracleImpl.InitParams memory params_)
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
            if (quotePairs[i].base == 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2) {
                console.log("Base: ", "MKR");
            } else {
                console.log("Base: ", IERC20(quotePairs[i].base).symbol());
            }
            if (quotePairs[i].quote == 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2) {
                console.log("Quote: ", "MKR");
            } else {
                console.log("Quote: ", IERC20(quotePairs[i].quote).symbol());
            }
            console.log("Amount: ", quoteAmounts[i]);
        }
    }

    function getFactory() public returns (ChainlinkOracleFactory) {
        string memory json = readInput("inputs");
        return ChainlinkOracleFactory(json.readAddress(".chainlinkOracleFactory"));
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
