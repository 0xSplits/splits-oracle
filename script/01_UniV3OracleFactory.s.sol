// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {UniV3OracleFactory} from "../src/UniV3OracleFactory.sol";

contract UniV3OracleFactoryScript is Script {
    using stdJson for string;

    address weth9;

    function run() public virtual returns (UniV3OracleFactory uof) {
        // https://book.getfoundry.sh/cheatcodes/parse-json
        string memory json = readInput("inputs");

        weth9 = json.readAddress(".weth9");

        uint256 privKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privKey);

        // don't use `CREATE2` bc differing network weth9 addresses ruin consistency
        uof = new UniV3OracleFactory({
            weth9_: weth9
        });

        vm.stopBroadcast();

        console2.log("UniV3OracleFactory Deployed:", address(uof));
        console2.log("UniV3OracleImpl Deployed:", address(uof.uniV3OracleImpl()));

        // https://book.getfoundry.sh/cheatcodes/serialize-json
        // https://book.getfoundry.sh/cheatcodes/write-json
        // https://github.com/foundry-rs/forge-std/blob/master/src/StdJson.sol
        string memory output = "deploymentArtifact";
        output.serialize("UniV3OracleFactory", address(uof));
        output = output.serialize("UniV3OracleImpl", address(uof.uniV3OracleImpl()));
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
