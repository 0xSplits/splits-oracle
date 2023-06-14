// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ConvertedQuotePair, QuotePair, SortedConvertedQuotePair} from "splits-utils/LibQuotes.sol";

import {ChainlinkOracleImpl} from "../ChainlinkOracleImpl.sol";

/// @title Chainlink PairDetails Library
/// @author 0xSplits
/// @notice Setters & getters for quote pairs' chainlink details
library ChainlinkPairDetails {
    /// set pair details
    function _set(
        mapping(address => mapping(address => ChainlinkOracleImpl.PairDetail)) storage self,
        function (address) internal view returns (address) convert_,
        ChainlinkOracleImpl.SetPairDetailParams[] calldata params_
    ) internal {
        uint256 length = params_.length;
        for (uint256 i; i < length;) {
            _set(self, convert_, params_[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// set pair details
    function _set(
        mapping(address => mapping(address => ChainlinkOracleImpl.PairDetail)) storage self,
        function (address) internal view returns (address) convert_,
        ChainlinkOracleImpl.SetPairDetailParams calldata params_
    ) internal {
        ConvertedQuotePair memory cqp = params_.quotePair._convert(convert_);
        SortedConvertedQuotePair memory scqp = cqp._sort();
        if (cqp.cBase == scqp.cToken0) {
            self[scqp.cToken0][scqp.cToken1] = params_.pairDetail;
        } else {
            ChainlinkOracleImpl.PairDetail memory pairDetail = params_.pairDetail;
            pairDetail.inverted = !pairDetail.inverted;
            self[scqp.cToken0][scqp.cToken1] = pairDetail;
        }
    }

    /// get pair details
    function _get(
        mapping(address => mapping(address => ChainlinkOracleImpl.PairDetail)) storage self,
        function (address) internal view returns (address) convert_,
        QuotePair calldata quotePair_
    ) internal view returns (ChainlinkOracleImpl.PairDetail memory) {
        return _get(self, quotePair_._convertAndSort(convert_));
    }

    /// get pair details
    function _get(
        mapping(address => mapping(address => ChainlinkOracleImpl.PairDetail)) storage self,
        SortedConvertedQuotePair memory scqp_
    ) internal view returns (ChainlinkOracleImpl.PairDetail memory) {
        return self[scqp_.cToken0][scqp_.cToken1];
    }
}
