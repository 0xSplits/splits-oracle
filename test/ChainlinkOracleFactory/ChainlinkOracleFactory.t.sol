// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ChainlinkOracleFactory} from "src/chainlink/factory/ChainlinkOracleFactory.sol";
import {ChainlinkOracleImpl} from "src/chainlink/oracle/ChainlinkOracleImpl.sol";
import "splits-tests/Base.t.sol";

contract ChainlinkOracleFactoryTest is BaseTest {
    ChainlinkOracleFactory public $factory;

    ChainlinkOracleImpl.SetPairDetailParams[] $pairDetails;

    function setUp() public override {
        super.setUp();
        $factory = new ChainlinkOracleFactory(WETH9);
    }

    function testFuzz_createOracle_addressAsPredicted(bytes32 salt_) public {
        ChainlinkOracleImpl.InitParams memory params =
            ChainlinkOracleImpl.InitParams({owner: users.alice, paused: false, pairDetails: $pairDetails});

        address predictedAddress = $factory.predictDeterministicAddress(abi.encode(params), salt_);

        address oracle = $factory.createOracle(abi.encode(params), salt_);
        assertEq(oracle, predictedAddress);
        assertEq(ChainlinkOracleImpl(oracle).owner(), users.alice);
    }

    function testFuzz_createOracle_addressNotAsPredicted(bytes32 salt_) public {
        ChainlinkOracleImpl.InitParams memory params =
            ChainlinkOracleImpl.InitParams({owner: users.alice, paused: false, pairDetails: $pairDetails});

        address predictedAddress = $factory.predictDeterministicAddress(abi.encode(params), salt_);

        params.owner = users.bob;

        address oracle = $factory.createOracle(abi.encode(params), salt_);
        assertNotEq(oracle, predictedAddress);
        assertEq(ChainlinkOracleImpl(oracle).owner(), users.bob);
    }

    function testFuzz_createOracle_sameParamsWithDifferentSalts(bytes32 salt1_, bytes32 salt2_) public {
        ChainlinkOracleImpl.InitParams memory params =
            ChainlinkOracleImpl.InitParams({owner: users.alice, paused: false, pairDetails: $pairDetails});

        address predictedAddress1 = $factory.predictDeterministicAddress(abi.encode(params), salt1_);
        address predictedAddress2 = $factory.predictDeterministicAddress(abi.encode(params), salt2_);

        address oracle1 = $factory.createOracle(abi.encode(params), salt1_);
        address oracle2 = $factory.createOracle(abi.encode(params), salt2_);

        assertEq(ChainlinkOracleImpl(oracle1).owner(), users.alice);
        assertEq(ChainlinkOracleImpl(oracle2).owner(), users.alice);
        assertEq(oracle1, predictedAddress1);
        assertEq(oracle2, predictedAddress2);
        assertNotEq(predictedAddress1, predictedAddress2);
    }

    function test_createOracle_reverts_SameParamsAndSalt() public {
        bytes32 salt_ = keccak256(abi.encodePacked("salt"));

        ChainlinkOracleImpl.InitParams memory params =
            ChainlinkOracleImpl.InitParams({owner: users.alice, paused: false, pairDetails: $pairDetails});

        address predictedAddress = $factory.predictDeterministicAddress(abi.encode(params), salt_);

        address oracle = $factory.createOracle(abi.encode(params), salt_);

        assertEq(oracle, predictedAddress);
        assertEq(ChainlinkOracleImpl(oracle).owner(), users.alice);

        vm.expectRevert();
        $factory.createOracle(abi.encode(params), salt_);
    }
}
