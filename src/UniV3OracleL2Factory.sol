// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {LibClone} from "solady/utils/LibClone.sol";

import {IOracle} from "./interfaces/IOracle.sol";
import {IOracleFactory} from "./interfaces/IOracleFactory.sol";
import {UniV3OracleL2Impl} from "./UniV3OracleL2Impl.sol";

/// @title UniV3 Oracle L2 Factory
/// @author 0xSplits
/// @notice Factory for creating UniV3 Oracles on L2s
contract UniV3OracleL2Factory is IOracleFactory {
    using LibClone for address;

    event CreateUniV3Oracle(UniV3OracleL2Impl indexed oracle, UniV3OracleL2Impl.InitParams params);

    UniV3OracleL2Impl public immutable uniV3OracleImpl;

    constructor(address weth9_, address sequencerFeed_) {
        uniV3OracleImpl = new UniV3OracleL2Impl(weth9_, sequencerFeed_);
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    function createUniV3Oracle(UniV3OracleL2Impl.InitParams calldata params_) external returns (UniV3OracleL2Impl) {
        return _createUniV3Oracle(params_);
    }

    function createOracle(bytes calldata data_) external returns (IOracle) {
        UniV3OracleL2Impl.InitParams memory params = abi.decode(data_, (UniV3OracleL2Impl.InitParams));
        return _createUniV3Oracle(params);
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function _createUniV3Oracle(UniV3OracleL2Impl.InitParams memory params_)
        internal
        returns (UniV3OracleL2Impl oracle)
    {
        oracle = UniV3OracleL2Impl(address(uniV3OracleImpl).clone());
        oracle.initializer(params_);
        emit CreateUniV3Oracle({oracle: oracle, params: params_});
    }
}
