// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {FeedRegistryInterface} from "chainlink/interfaces/FeedRegistryInterface.sol";
import {LibClone} from "solady/utils/LibClone.sol";

import {IOracle} from "src/interfaces/IOracle.sol";
import {IOracleFactory} from "src/interfaces/IOracleFactory.sol";
import {ChainlinkOracleImpl} from "src/ChainlinkOracleImpl.sol";

/// @title Chainlink Oracle Factory
/// @author 0xSplits
/// @notice Factory for creating chainlink oracles
contract ChainlinkOracleFactory is IOracleFactory {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using LibClone for address;

    /// -----------------------------------------------------------------------
    /// events
    /// -----------------------------------------------------------------------

    event CreateOracle(ChainlinkOracleImpl indexed oracle, ChainlinkOracleImpl.InitParams params);

    /// -----------------------------------------------------------------------
    /// storage
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    ChainlinkOracleImpl public immutable chainlinkOracleImpl;

    /// -----------------------------------------------------------------------
    /// constructor
    /// -----------------------------------------------------------------------

    constructor(FeedRegistryInterface clFeedRegistry_, address weth9_, address clETH_) {
        chainlinkOracleImpl = new ChainlinkOracleImpl({
            clFeedRegistry_: clFeedRegistry_,
            weth9_: weth9_,
            clETH_: clETH_
        });
    }

    /// -----------------------------------------------------------------------
    /// functions
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    function createOracle(ChainlinkOracleImpl.InitParams calldata params_) external returns (ChainlinkOracleImpl) {
        return _createOracle(params_);
    }

    function createOracle(bytes calldata init_) external returns (IOracle) {
        ChainlinkOracleImpl.InitParams memory params = abi.decode(init_, (ChainlinkOracleImpl.InitParams));
        return _createOracle(params);
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function _createOracle(ChainlinkOracleImpl.InitParams memory params_)
        internal
        returns (ChainlinkOracleImpl oracle)
    {
        oracle = ChainlinkOracleImpl(address(chainlinkOracleImpl).clone());
        oracle.initializer(params_);
        emit CreateOracle({oracle: oracle, params: params_});
    }
}
