// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {BaseChainlinkOracleFactory} from "./BaseChainlinkOracleFactory.sol";
import {ChainlinkOracleL2Impl} from "../oracle/ChainlinkOracleL2Impl.sol";

/// @title Chainlink Oracle Factory L2
/// @author 0xSplits
/// @notice Factory for creating Chainlink Oracles
contract ChainlinkOracleL2Factory is BaseChainlinkOracleFactory {
    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    address public immutable ORACLE;

    /// -----------------------------------------------------------------------
    /// constructor
    /// -----------------------------------------------------------------------

    constructor(address weth9_, address sequencerFeed_) {
        ORACLE = address(new ChainlinkOracleL2Impl(weth9_, sequencerFeed_));
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    function oracleImplementation() public view override returns (address) {
        return ORACLE;
    }
}
