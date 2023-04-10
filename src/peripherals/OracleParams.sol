// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {AddressUtils} from "splits-utils/AddressUtils.sol";

import {IOracleFactory} from "../interfaces/IOracleFactory.sol";
import {OracleImpl} from "../OracleImpl.sol";

using {_parseIntoOracle} for OracleParams global;

using AddressUtils for address;

struct OracleParams {
    OracleImpl oracle;
    CreateOracleParams createOracleParams;
}

struct CreateOracleParams {
    IOracleFactory factory;
    bytes data;
}

function _parseIntoOracle(OracleParams calldata oracleParams_) returns (OracleImpl) {
    if (address(oracleParams_.oracle)._isNotEmpty()) {
        return oracleParams_.oracle;
    } else {
        // if oracle not provided, create one with provided params
        CreateOracleParams calldata createOracleParams = oracleParams_.createOracleParams;
        return createOracleParams.factory.createOracle(createOracleParams.data);
    }
}
