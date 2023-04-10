// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {LibClone} from "solady/utils/LibClone.sol";

import {OracleImpl} from "./OracleImpl.sol";
import {IOracleFactory} from "./interfaces/IOracleFactory.sol";
import {UniV3OracleImpl} from "./UniV3OracleImpl.sol";

/// @title UniV3 Oracle Factory
/// @author 0xSplits
/// @notice Factory for creating uniV3 oracles
contract UniV3OracleFactory is IOracleFactory {
    using LibClone for address;

    event CreateUniV3Oracle(UniV3OracleImpl indexed oracle, UniV3OracleImpl.InitParams params);

    UniV3OracleImpl public immutable uniV3OracleImpl;

    constructor(IUniswapV3Factory uniswapV3Factory_, address weth9_) {
        uniV3OracleImpl = new UniV3OracleImpl({
            uniswapV3Factory_: uniswapV3Factory_,
            weth9_: weth9_
        });
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    function createUniV3Oracle(UniV3OracleImpl.InitParams calldata params_) external returns (UniV3OracleImpl) {
        return _createUniV3Oracle(params_);
    }

    function createOracle(bytes calldata data_) external returns (OracleImpl) {
        UniV3OracleImpl.InitParams memory params = abi.decode(data_, (UniV3OracleImpl.InitParams));
        return _createUniV3Oracle(params);
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function _createUniV3Oracle(UniV3OracleImpl.InitParams memory params_) internal returns (UniV3OracleImpl oracle) {
        oracle = UniV3OracleImpl(address(uniV3OracleImpl).clone());
        oracle.initializer(params_);
        emit CreateUniV3Oracle({oracle: oracle, params: params_});
    }
}
