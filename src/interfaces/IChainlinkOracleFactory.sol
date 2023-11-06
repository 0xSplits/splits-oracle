// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {IOracle} from "./IOracle.sol";
import {ChainlinkOracleImpl} from "../ChainlinkOracleImpl.sol";

/// @title Oracle factory interface
interface IChainlinkOracleFactory {
    function createOracle(bytes calldata data_) external returns (IOracle);
    function createChainlinkOracle(ChainlinkOracleImpl.InitParams calldata params_) external returns (IOracle);
    function chainlinkOracleImpl() external view returns (IOracle);
}
