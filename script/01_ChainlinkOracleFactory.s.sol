// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {ChainlinkOracleFactory} from "../src/chainlink/factory/ChainlinkOracleFactory.sol";
import {CREATE3} from "solady/utils/CREATE3.sol";

contract ChainlinkOracleFactoryScript is Script {
    using stdJson for string;

    address $weth9;

    function run() public virtual returns (ChainlinkOracleFactory uof) {
        string memory json = readInput("inputs");

        $weth9 = json.readAddress(".weth9");

        uint256 privKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privKey);

        uof = new ChainlinkOracleFactory($weth9);

        vm.stopBroadcast();

        console2.log("Chainlink Oracle Factory Deployed:", address(uof));
        console2.log("Chainlink oracle Implementation Deployed:", address(uof.oracleImplementation()));

        string memory output = "deploymentArtifact";
        output.serialize("ChainlinkOracleL2Factory", address(uof));
        output = output.serialize("ChainlinkOracleL2Impl", address(uof.oracleImplementation()));
        writeOutput(output);
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

    function writeOutput(string memory output) internal {
        string memory outputDir = string.concat(vm.projectRoot(), "/deployments/");
        string memory file = string.concat(vm.toString(block.chainid), ".json");
        output.write(string.concat(outputDir, file));
    }
}
