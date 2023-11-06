// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {LibClone} from "solady/utils/LibClone.sol";
import {IOracle} from "./interfaces/IOracle.sol";
import {IOracleFactory} from "./interfaces/IOracleFactory.sol";
import {ChainlinkOracleL2Impl} from "./ChainlinkOracleL2Impl.sol";
import {ChainlinkOracleImpl} from "./ChainlinkOracleImpl.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";

/// @title Chainlink Oracle Factory
/// @author 0xSplits
/// @notice Factory for creating Chainlink Oracles
contract ChainlinkOracleL2Factory is IOracleFactory {
    using LibClone for address;

    event CreateChainlinkOracle(ChainlinkOracleL2Impl indexed oracle, ChainlinkOracleL2Impl.InitParams params);

    ChainlinkOracleL2Impl public immutable chainlinkOracleImpl;

    constructor(address weth9_, AggregatorV3Interface sequencerFeed_) {
        chainlinkOracleImpl = new ChainlinkOracleL2Impl(weth9_, sequencerFeed_);
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    function createChainlinkOracle(ChainlinkOracleL2Impl.InitParams calldata params_)
        external
        returns (ChainlinkOracleL2Impl)
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
        returns (ChainlinkOracleL2Impl oracle)
    {
        oracle = ChainlinkOracleL2Impl(address(chainlinkOracleImpl).clone());
        oracle.initializer(params_);
        emit CreateChainlinkOracle({oracle: oracle, params: params_});
    }
}
