// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {AddressUtils} from "splits-utils/AddressUtils.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {ConvertedQuotePair, QuotePair, QuoteParams, SortedConvertedQuotePair} from "splits-utils/LibQuotes.sol";
import {OracleLibrary} from "v3-periphery/libraries/OracleLibrary.sol";
import {QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";
import {TokenUtils} from "splits-utils/TokenUtils.sol";

import {OracleImpl} from "./OracleImpl.sol";
import {ChainlinkPairDetails} from "./libraries/ChainlinkPairDetails.sol";

/// @title Chainlink Oracle Implementation
/// @author 0xSplits
/// @notice A clone-implementation of an oracle using Chainlink
/// @dev This contract uses token = address(0) to refer to ETH.
contract ChainlinkOracleImpl is OracleImpl {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using AddressUtils for address;
    using TokenUtils for address;
    using ChainlinkPairDetails for mapping(address => mapping(address => PairDetail));

    /// -----------------------------------------------------------------------
    /// errors
    /// -----------------------------------------------------------------------

    error InvalidPair_FeedNotSet(QuotePair qp);
    error StalePrice(AggregatorV3Interface feed, uint256 timestamp);
    error NegativePrice(AggregatorV3Interface feed, int256 price);

    /// -----------------------------------------------------------------------
    /// structs
    /// -----------------------------------------------------------------------

    struct InitParams {
        address owner;
        bool paused;
        uint32 defaultStaleAfter;
        SetTokenOverrideParams[] tokenOverrides;
        SetPairDetailParams[] pairDetails;
    }

    struct SetTokenOverrideParams {
        address token;
        address tokenOverride;
    }

    struct SetPairDetailParams {
        QuotePair quotePair;
        PairDetail pairDetail;
    }

    struct PairDetail {
        AggregatorV3Interface feed;
        bool inverted;
        uint32 staleAfter;
    }

    /// -----------------------------------------------------------------------
    /// events
    /// -----------------------------------------------------------------------

    event SetDefaultStaleAfter(uint32 defaultStaleAfter);
    event SetTokenOverrides(SetTokenOverrideParams[] params);
    event SetPairDetails(SetPairDetailParams[] params);

    /// -----------------------------------------------------------------------
    /// storage
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    address public immutable chainlinkOracleFactory;

    /// -----------------------------------------------------------------------
    /// storage - mutables
    /// -----------------------------------------------------------------------

    /// slot 0 - 7 byte free

    /// OwnableImpl storage
    /// address internal $owner;
    /// 20 bytes

    /// PausableImpl storage
    /// bool internal $paused;
    /// 1 byte

    /// default time until CL updates become stale
    /// 4 bytes
    uint32 internal $defaultStaleAfter;

    /// slot 1 - 0 bytes free

    /// overrides for tokens
    /// 32 bytes
    mapping(address => address) internal $_tokenOverrides;

    /// slot 2 - 0 bytes free

    /// details for specific quote pairs
    /// 32 bytes
    mapping(address => mapping(address => PairDetail)) internal $_pairDetails;

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    constructor() {
        chainlinkOracleFactory = msg.sender;
    }

    function initializer(InitParams calldata params_) external {
        // only chainlinkOracleFactory may call `initializer`
        if (msg.sender != chainlinkOracleFactory) revert Unauthorized();

        __initOwnable(params_.owner);
        $paused = params_.paused;
        $defaultStaleAfter = params_.defaultStaleAfter;

        _setTokenOverrides(params_.tokenOverrides);
        _setPairDetails(params_.pairDetails);
    }

    /// -----------------------------------------------------------------------
    /// functions
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// functions - public & external - onlyOwner
    /// -----------------------------------------------------------------------

    /// set defaultStaleAfter
    function setDefaultStaleAfter(uint32 defaultStaleAfter_) external onlyOwner {
        $defaultStaleAfter = defaultStaleAfter_;
        emit SetDefaultStaleAfter(defaultStaleAfter_);
    }

    /// set token overrides
    function setTokenOverrides(SetTokenOverrideParams[] calldata params_) external onlyOwner {
        _setTokenOverrides(params_);
        emit SetTokenOverrides(params_);
    }

    /// set pair details
    function setPairDetails(SetPairDetailParams[] calldata params_) external onlyOwner {
        _setPairDetails(params_);
        emit SetPairDetails(params_);
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external - view
    /// -----------------------------------------------------------------------

    function defaultStaleAfter() external view returns (uint32) {
        return $defaultStaleAfter;
    }

    /// get token overrides for an array of tokens
    function getTokenOverrides(address[] calldata tokens_) external view returns (address[] memory tokenOverrides) {
        uint256 length = tokens_.length;
        tokenOverrides = new address[](length);
        for (uint256 i; i < length;) {
            tokenOverrides[i] = $_tokenOverrides[tokens_[i]];
            unchecked {
                ++i;
            }
        }
    }

    /// get pair details for an array of quote pairs
    function getPairDetails(QuotePair[] calldata quotePairs_) external view returns (PairDetail[] memory pairDetails) {
        uint256 length = quotePairs_.length;
        pairDetails = new PairDetail[](length);
        for (uint256 i; i < length;) {
            pairDetails[i] = $_pairDetails._get(_convert, quotePairs_[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// get amounts for an array of quotes
    function getQuoteAmounts(QuoteParams[] calldata quoteParams_)
        external
        view
        override
        pausable
        returns (uint256[] memory quoteAmounts)
    {
        uint256 length = quoteParams_.length;
        quoteAmounts = new uint256[](length);
        for (uint256 i; i < length;) {
            quoteAmounts[i] = _getQuoteAmount(quoteParams_[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal
    /// -----------------------------------------------------------------------

    /// set token overrides
    function _setTokenOverrides(SetTokenOverrideParams[] calldata params_) internal {
        uint256 length = params_.length;
        for (uint256 i; i < length;) {
            _setTokenOverride(params_[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// set token override
    function _setTokenOverride(SetTokenOverrideParams calldata params_) internal {
        $_tokenOverrides[params_.token] = params_.tokenOverride;
    }

    /// set pair details
    function _setPairDetails(SetPairDetailParams[] calldata params_) internal {
        $_pairDetails._set(_convert, params_);
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal - views
    /// -----------------------------------------------------------------------

    /// get amount for a quote
    function _getQuoteAmount(QuoteParams calldata quoteParams_) internal view returns (uint256) {
        ConvertedQuotePair memory cqp = quoteParams_.quotePair._convert(_convert);

        // skip oracle if converted tokens are equal
        if (cqp.cBase == cqp.cQuote) {
            return quoteParams_.baseAmount;
        }

        SortedConvertedQuotePair memory scqp = cqp._sort();
        PairDetail memory pd = $_pairDetails._get(scqp);
        if (address(pd.feed)._isEmpty()) {
            revert InvalidPair_FeedNotSet(quoteParams_.quotePair);
        }
        if (pd.staleAfter == 0) {
            pd.staleAfter = $defaultStaleAfter;
        }

        (
            , /* uint80 roundId, */
            int256 answer,
            , /* uint256 startedAt, */
            uint256 updatedAt,
            /* uint80 answeredInRound */
        ) = pd.feed.latestRoundData();

        if (updatedAt < block.timestamp - pd.staleAfter) {
            revert StalePrice(pd.feed, updatedAt);
        }
        if (answer < 0) {
            revert NegativePrice(pd.feed, answer);
        }

        uint256 quoteAmount;
        uint8 answerDecimals = pd.feed.decimals();
        bool pairInverted = (cqp.cBase != scqp.cToken0);
        bool invertFeed = pd.inverted != pairInverted;
        if (invertFeed) {
            quoteAmount = uint256(quoteParams_.baseAmount) * 10 ** uint256(answerDecimals) / uint256(answer);
        } else {
            quoteAmount = uint256(quoteParams_.baseAmount) * uint256(answer) / 10 ** uint256(answerDecimals);
        }
        return _adjustQuoteDecimals(quoteAmount, quoteParams_);
    }

    /// adjust quoteAmount_ based on decimals of base & quote
    function _adjustQuoteDecimals(uint256 quoteAmount_, QuoteParams calldata quoteParams_)
        internal
        view
        returns (uint256)
    {
        uint8 baseDecimals = quoteParams_.quotePair.base._decimals();
        uint8 quoteDecimals = quoteParams_.quotePair.quote._decimals();

        int256 decimalAdjustment = int256(uint256(quoteDecimals)) - int256(uint256(baseDecimals));
        if (decimalAdjustment > 0) {
            return quoteAmount_ * 10 ** uint256(decimalAdjustment);
        }
        return quoteAmount_ / 10 ** uint256(-decimalAdjustment);
    }

    /// if set, convert token to override
    function _convert(address token_) internal view returns (address tokenOverride) {
        tokenOverride = $_tokenOverrides[token_];
        if (tokenOverride._isEmpty() && token_._isNotEmpty()) {
            tokenOverride = token_;
        }
    }
}
