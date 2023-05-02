// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {QuotePair} from "../utils/QuotePair.sol";

// TODO: may want to move QuotePair & QuoteParams to splits-utils

/// @title Oracle Interface
/// @author 0xSplits
interface IOracle {
    struct QuoteParams {
        QuotePair quotePair;
        uint128 baseAmount;
        bytes data;
    }

    function getQuoteAmounts(QuoteParams[] calldata quoteParams_) external view returns (uint256[] memory);
}
