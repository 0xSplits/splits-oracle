// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {OracleImpl} from "../OracleImpl.sol";

/// @title Oracle factory interface
interface IOracleFactory {
    function createOracle(bytes calldata data_) external returns (OracleImpl oracle);
}
