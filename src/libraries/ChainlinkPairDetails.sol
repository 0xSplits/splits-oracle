// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ConvertedQuotePair, QuotePair, SortedConvertedQuotePair} from "splits-utils/LibQuotes.sol";
import {ChainlinkOracleImpl} from "../chainlink/oracle/ChainlinkOracleImpl.sol";

/// @title Chainlink PairDetails Library
/// @author 0xSplits
/// @notice Setters & getters for quote pairs' chainlink details
library ChainlinkPairDetails {
    /// -----------------------------------------------------------------------
    /// errors
    /// -----------------------------------------------------------------------
    error InvalidFeed_StaleAfter();
    error InvalidFeed_Decimals();
    error InvalidFeed_Mul();

    /// set pair details
    function _set(
        mapping(address => mapping(address => ChainlinkOracleImpl.PairDetail)) storage self,
        function (address) internal view returns (address) convert,
        ChainlinkOracleImpl.SetPairDetailParams[] calldata params_
    ) internal {
        uint256 length = params_.length;
        for (uint256 i; i < length;) {
            _validate(params_[i]);
            _set(self, convert, params_[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// set pair details
    function _set(
        mapping(address => mapping(address => ChainlinkOracleImpl.PairDetail)) storage self,
        function (address) internal view returns (address) convert,
        ChainlinkOracleImpl.SetPairDetailParams calldata params_
    ) internal {
        ConvertedQuotePair memory cqp = params_.quotePair._convert(convert);
        self[cqp.cBase][cqp.cQuote] = params_.pairDetail;
        ChainlinkOracleImpl.PairDetail memory pairDetail = params_.pairDetail;
        pairDetail.inverted = !pairDetail.inverted;
        self[cqp.cQuote][cqp.cBase] = pairDetail;
    }

    /// get pair details
    function _get(
        mapping(address => mapping(address => ChainlinkOracleImpl.PairDetail)) storage self,
        function (address) internal view returns (address) convert,
        QuotePair calldata quotePair_
    ) internal view returns (ChainlinkOracleImpl.PairDetail memory) {
        return _get(self, quotePair_._convert(convert));
    }

    function _get(
        mapping(address => mapping(address => ChainlinkOracleImpl.PairDetail)) storage self,
        ConvertedQuotePair memory quotePair_
    ) internal view returns (ChainlinkOracleImpl.PairDetail memory) {
        return self[quotePair_.cBase][quotePair_.cQuote];
    }

    function _validate(ChainlinkOracleImpl.SetPairDetailParams calldata params_) private view {
        ChainlinkOracleImpl.Feed[] memory feed = abi.decode(params_.pairDetail.path, (ChainlinkOracleImpl.Feed[]));

        uint256 length = feed.length;
        for (uint256 i; i < length;) {
            if (feed[i].staleAfter < 1 hours) revert InvalidFeed_StaleAfter();
            if (feed[i].feed.decimals() != feed[i].decimals) revert InvalidFeed_Decimals();
            if (i == 0 && !feed[i].mul) revert InvalidFeed_Mul();
            unchecked {
                ++i;
            }
        }
    }
}
