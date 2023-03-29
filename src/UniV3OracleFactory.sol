// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {LibClone} from "solady/utils/LibClone.sol";

import {IOracle} from "src/interfaces/IOracle.sol";
import {IOracleFactory} from "src/interfaces/IOracleFactory.sol";
import {UniV3OracleImpl} from "src/UniV3OracleImpl.sol";

/// @title UniV3 Oracle Factory
/// @author 0xSplits
/// @notice Factory for creating uniV3 oracles
contract UniV3OracleFactory is IOracleFactory {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using LibClone for address;

    /// -----------------------------------------------------------------------
    /// events
    /// -----------------------------------------------------------------------

    event CreateOracle(UniV3OracleImpl indexed oracle, UniV3OracleImpl.InitParams params);

    /// -----------------------------------------------------------------------
    /// storage
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    UniV3OracleImpl public immutable uniV3OracleImpl;

    /// -----------------------------------------------------------------------
    /// constructor
    /// -----------------------------------------------------------------------

    constructor(IUniswapV3Factory uniswapV3Factory_, address weth9_) {
        uniV3OracleImpl = new UniV3OracleImpl({
            uniswapV3Factory_: uniswapV3Factory_,
            weth9_: weth9_
        });
    }

    /// -----------------------------------------------------------------------
    /// functions
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    function createOracle(UniV3OracleImpl.InitParams calldata params_) external returns (UniV3OracleImpl) {
        return _createOracle(params_);
    }

    function createOracle(bytes calldata init_) external returns (IOracle) {
        UniV3OracleImpl.InitParams memory params = abi.decode(init_, (UniV3OracleImpl.InitParams));
        return _createOracle(params);
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    function _createOracle(UniV3OracleImpl.InitParams memory params_) internal returns (UniV3OracleImpl oracle) {
        oracle = UniV3OracleImpl(address(uniV3OracleImpl).clone());
        oracle.initializer(params_);
        emit CreateOracle({oracle: oracle, params: params_});
    }
}
