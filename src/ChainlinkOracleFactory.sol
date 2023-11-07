// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {LibClone} from "solady/utils/LibClone.sol";
import {IChainlinkOracleFactory} from "./interfaces/IChainlinkOracleFactory.sol";
import {ChainlinkOracleImpl} from "./ChainlinkOracleImpl.sol";

/// @title Chainlink Oracle Factory
/// @author 0xSplits
/// @notice Factory for creating Chainlink Oracles
contract ChainlinkOracleFactory is IChainlinkOracleFactory {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using LibClone for address;

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    address public immutable ORACLE;

    /// -----------------------------------------------------------------------
    /// constructor
    /// -----------------------------------------------------------------------

    constructor(address weth9_) {
        ORACLE = address(new ChainlinkOracleImpl(weth9_));
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    /// @inheritdoc IChainlinkOracleFactory
    function createChainlinkOracle(ChainlinkOracleImpl.InitParams calldata params_, bytes32 salt_)
        external
        returns (address)
    {
        return _createChainlinkOracle(params_, salt_);
    }

    /// @inheritdoc IChainlinkOracleFactory
    function createOracle(bytes calldata data_, bytes32 salt_) external returns (address) {
        ChainlinkOracleImpl.InitParams memory params = abi.decode(data_, (ChainlinkOracleImpl.InitParams));
        return _createChainlinkOracle(params, salt_);
    }

    /// @inheritdoc IChainlinkOracleFactory
    function predictDeterministicAddress(ChainlinkOracleImpl.InitParams calldata params_, bytes32 salt_)
        external
        view
        returns (address)
    {
        return ORACLE.predictDeterministicAddress(keccak256(abi.encode(params_, salt_)), address(this));
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function _createChainlinkOracle(ChainlinkOracleImpl.InitParams memory params_, bytes32 salt_)
        internal
        returns (address oracle)
    {
        salt_ = keccak256(abi.encode(params_, salt_));
        oracle = address(ORACLE.cloneDeterministic(salt_));
        ChainlinkOracleImpl(oracle).initializer(params_);
        emit CreateChainlinkOracle({oracle: oracle, params: params_});
    }
}
