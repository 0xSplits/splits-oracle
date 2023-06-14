// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {LibClone} from "solady/utils/LibClone.sol";

import {IOracle} from "./interfaces/IOracle.sol";
import {IOracleFactory} from "./interfaces/IOracleFactory.sol";
import {ChainlinkOracleImpl} from "./ChainlinkOracleImpl.sol";

/// @title Chainlink Oracle Factory
/// @author 0xSplits
/// @notice Factory for creating Chainlink Oracles
contract ChainlinkOracleFactory is IOracleFactory {
    using LibClone for address;

    event CreateChainlinkOracle(ChainlinkOracleImpl indexed oracle, ChainlinkOracleImpl.InitParams params);

    ChainlinkOracleImpl public immutable chainlinkOracleImpl;

    constructor() {
        chainlinkOracleImpl = new ChainlinkOracleImpl();
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    function createChainlinkOracle(ChainlinkOracleImpl.InitParams calldata params_)
        external
        returns (ChainlinkOracleImpl)
    {
        return _createChainlinkOracle(params_);
    }

    function createOracle(bytes calldata data_) external returns (IOracle) {
        ChainlinkOracleImpl.InitParams memory params = abi.decode(data_, (ChainlinkOracleImpl.InitParams));
        return _createChainlinkOracle(params);
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function _createChainlinkOracle(ChainlinkOracleImpl.InitParams memory params_)
        internal
        returns (ChainlinkOracleImpl oracle)
    {
        oracle = ChainlinkOracleImpl(address(chainlinkOracleImpl).clone());
        oracle.initializer(params_);
        emit CreateChainlinkOracle({oracle: oracle, params: params_});
    }
}
