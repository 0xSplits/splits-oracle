// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {QuotePair, SortedConvertedQuotePair} from "splits-utils/LibQuotes.sol";

import {UniV3OracleL2Impl} from "../UniV3OracleL2Impl.sol";

/// @title PairDetails Library for L2s
/// @author 0xSplits
/// @notice Setters & getters for quote pairs' details
/// @dev clone of src/libraries/PairDetails
library PairDetails {
    /// set pair details
    function _set(
        mapping(address => mapping(address => UniV3OracleL2Impl.PairDetail)) storage self,
        function (address) internal view returns (address) convert,
        UniV3OracleL2Impl.SetPairDetailParams[] calldata params_
    ) internal {
        uint256 length = params_.length;
        for (uint256 i; i < length;) {
            _set(self, convert, params_[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// set pair details
    function _set(
        mapping(address => mapping(address => UniV3OracleL2Impl.PairDetail)) storage self,
        function (address) internal view returns (address) convert,
        UniV3OracleL2Impl.SetPairDetailParams calldata params_
    ) internal {
        SortedConvertedQuotePair memory scqp = params_.quotePair._convertAndSort(convert);
        self[scqp.cToken0][scqp.cToken1] = params_.pairDetail;
    }

    /// get pair details
    function _get(
        mapping(address => mapping(address => UniV3OracleL2Impl.PairDetail)) storage self,
        function (address) internal view returns (address) convert,
        QuotePair calldata quotePair_
    ) internal view returns (UniV3OracleL2Impl.PairDetail memory) {
        return _get(self, quotePair_._convertAndSort(convert));
    }

    /// get pair details
    function _get(
        mapping(address => mapping(address => UniV3OracleL2Impl.PairDetail)) storage self,
        SortedConvertedQuotePair memory scqp_
    ) internal view returns (UniV3OracleL2Impl.PairDetail memory) {
        return self[scqp_.cToken0][scqp_.cToken1];
    }
}
