// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ChainlinkOracleImpl} from "../ChainlinkOracleImpl.sol";

/// @title Oracle factory interface
interface IChainlinkOracleFactory {
    /// -----------------------------------------------------------------------
    /// events
    /// -----------------------------------------------------------------------

    event CreateChainlinkOracle(address indexed oracle, ChainlinkOracleImpl.InitParams params);

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    /**
     * @notice Create a new Chainlink Oracle
     * @param params_ The init params
     * @param salt_ The salt
     * @return oracle The oracle address
     */
    function createOracle(bytes calldata params_, bytes32 salt_) external returns (address);

    /**
     * @notice Predict the address of a new Chainlink Oracle
     * @param params_ The init params
     * @param salt_ The salt
     * @return oracle The oracle address
     */
    function createChainlinkOracle(ChainlinkOracleImpl.InitParams calldata params_, bytes32 salt_)
        external
        returns (address);

    /**
     * @notice Predict the address of a new Chainlink Oracle
     * @param params_ The init params
     * @param salt_ The salt
     * @return oracle The oracle address
     */
    function predictDeterministicAddress(ChainlinkOracleImpl.InitParams calldata params_, bytes32 salt_)
        external
        view
        returns (address);

    /// @notice The oracle implementation
    function ORACLE() external view returns (address);
}
