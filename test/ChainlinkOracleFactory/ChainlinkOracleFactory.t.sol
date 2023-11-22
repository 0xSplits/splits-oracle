// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "splits-tests/Base.t.sol";
import {ChainlinkOracleFactory} from "src/chainlink/factory/ChainlinkOracleFactory.sol";
import {ChainlinkOracleImpl} from "src/chainlink/oracle/ChainlinkOracleImpl.sol";
import {ChainlinkPath} from "../../src/libraries/ChainlinkPath.sol";
import {QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";

contract ChainlinkOracleFactoryTest is BaseTest {
    using ChainlinkPath for bytes;
    using ChainlinkPath for ChainlinkOracleImpl.Feed[];

    ChainlinkOracleFactory public $factory;

    ChainlinkOracleImpl.SetPairDetailParams[] $pairDetails;
    QuotePair $usdcETH;
    QuoteParams[] $usdcQuoteParams;

    address constant USDC_ETH_AGG = 0x986b5E1e1755e3C2440e960477f25201B0a8bbD4;

    function setUp() public override {
        vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER);
        super.setUp();
        $factory = new ChainlinkOracleFactory(WETH9);

        ChainlinkOracleImpl.Feed memory USDC_ETH_FEED = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface(USDC_ETH_AGG),
            staleAfter: 1 hours,
            decimals: 18,
            mul: true
        });

        $usdcETH = QuotePair({base: USDC, quote: ETH_ADDRESS});

        ChainlinkOracleImpl.Feed[] memory usdcETHPath = new ChainlinkOracleImpl.Feed[](1);
        usdcETHPath[0] = USDC_ETH_FEED;

        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: $usdcETH,
                pairDetail: ChainlinkOracleImpl.PairDetail({path: usdcETHPath.getPath(), inverted: false})
            })
        );
    }

    function testFuzz_createOracle_addressAsPredicted(bytes32 salt_) public {
        ChainlinkOracleImpl.InitParams memory params =
            ChainlinkOracleImpl.InitParams({owner: users.alice, paused: false, pairDetails: $pairDetails});

        address predictedAddress = $factory.predictDeterministicAddress(abi.encode(params), salt_);
        (address deployableAddress, bool isDeployed) = $factory.isDeployed(abi.encode(params), salt_);
        assertEq(isDeployed, false);
        assertEq(deployableAddress, predictedAddress);

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
        vm.assume(salt1_ != salt2_);

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

    function testFuzz_createOracle_reverts_SameParamsAndSalt(bytes32 salt_) public {
        ChainlinkOracleImpl.InitParams memory params =
            ChainlinkOracleImpl.InitParams({owner: users.alice, paused: false, pairDetails: $pairDetails});

        address predictedAddress = $factory.predictDeterministicAddress(abi.encode(params), salt_);
        (, bool isDeployed) = $factory.isDeployed(abi.encode(params), salt_);
        assertEq(isDeployed, false);

        address oracle = $factory.createOracle(abi.encode(params), salt_);

        assertEq(oracle, predictedAddress);
        assertEq(ChainlinkOracleImpl(oracle).owner(), users.alice);

        (, isDeployed) = $factory.isDeployed(abi.encode(params), salt_);
        assertEq(isDeployed, true);

        vm.expectRevert();
        $factory.createOracle(abi.encode(params), salt_);
    }
}
