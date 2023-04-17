// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {OwnableImpl} from "splits-utils/OwnableImpl.sol";
import {PausableImpl} from "splits-utils/PausableImpl.sol";

import {QuotePair} from "./utils/QuotePair.sol";

/// @title Oracle Implementation
/// @author 0xSplits
/// @notice Oracle clone-implementation
/// @dev acts as more of an interface
abstract contract OracleImpl is PausableImpl {
    /// slot 0 - 11 byte free

    /// OwnableImpl storage
    /// address internal $owner;
    /// 20 bytes

    /// PausableImpl storage
    /// bool internal $paused;
    /// 1 byte

    struct QuoteParams {
        QuotePair quotePair;
        uint128 baseAmount;
        bytes data;
    }

    function getQuoteAmounts(QuoteParams[] calldata quoteParams_) external view virtual returns (uint256[] memory);
}
