// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {LibClone} from "solady/utils/LibClone.sol";
import {IChainlinkOracleFactory} from "../../interfaces/IChainlinkOracleFactory.sol";
import {ChainlinkOracleImpl} from "../oracle/ChainlinkOracleImpl.sol";

/// @title Base Chainlink Oracle Factory
/// @author 0xSplits
/// @notice Factory for creating Chainlink Oracles
abstract contract BaseChainlinkOracleFactory is IChainlinkOracleFactory {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using LibClone for address;

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    /// @inheritdoc IChainlinkOracleFactory
    function createOracle(bytes calldata data_, bytes32 salt_) external returns (address) {
        return _createOracle(data_, salt_);
    }

    /// @inheritdoc IChainlinkOracleFactory
    function predictDeterministicAddress(bytes calldata data_, bytes32 salt_) external view returns (address) {
        return oracleImplementation().predictDeterministicAddress(_getSalt(data_, salt_), address(this));
    }

    function oracleImplementation() public view virtual returns (address oracle_) {}

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function _createOracle(bytes calldata data_, bytes32 salt_) internal returns (address oracle) {
        oracle = oracleImplementation().cloneDeterministic(_getSalt(data_, salt_));
        ChainlinkOracleImpl.InitParams memory params = abi.decode(data_, (ChainlinkOracleImpl.InitParams));
        ChainlinkOracleImpl(oracle).initializer(params);
        emit CreateChainlinkOracle({oracle: oracle, params: params});
    }

    function _getSalt(bytes calldata data_, bytes32 salt_) internal pure returns (bytes32) {
        return keccak256(bytes.concat(data_, salt_));
    }
}
