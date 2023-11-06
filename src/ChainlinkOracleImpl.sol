// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {AddressUtils} from "splits-utils/AddressUtils.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {ConvertedQuotePair, QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";
import {QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";
import {TokenUtils} from "splits-utils/TokenUtils.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
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
    using FixedPointMathLib for uint256;

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
        SetPairDetailParams[] pairDetails;
    }

    struct SetPairDetailParams {
        QuotePair quotePair;
        PairDetail pairDetail;
    }

    struct PairDetail {
        // encoded feed[]
        bytes path;
        bool inverted;
    }

    struct Feed {
        AggregatorV3Interface feed;
        /// @dev staleAfter > 1 hours
        uint32 staleAfter;
        /// @dev decimals should be same as feed.decimals()
        uint8 decimals;
        /// @dev mul should be true for the first feed in the path
        bool mul;
    }

    /// -----------------------------------------------------------------------
    /// events
    /// -----------------------------------------------------------------------

    event SetPairDetails(SetPairDetailParams[] params);

    /// -----------------------------------------------------------------------
    /// storage
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    address public immutable weth9;
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

    /// slot 1 - 0 bytes free

    /// slot 2 - 0 bytes free

    /// details for specific quote pairs
    /// 32 bytes
    mapping(address => mapping(address => PairDetail)) internal $_pairDetails;

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    constructor(address weth9_) {
        weth9 = weth9_;
        chainlinkOracleFactory = msg.sender;
    }

    function initializer(InitParams calldata params_) external {
        // only chainlinkOracleFactory may call `initializer`
        if (msg.sender != chainlinkOracleFactory) revert Unauthorized();

        __initOwnable(params_.owner);
        $paused = params_.paused;

        _setPairDetails(params_.pairDetails);
        emit SetPairDetails(params_.pairDetails);
    }

    /// -----------------------------------------------------------------------
    /// functions
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// functions - public & external - onlyOwner
    /// -----------------------------------------------------------------------

    /// set pair details
    function setPairDetails(SetPairDetailParams[] calldata params_) external onlyOwner {
        _setPairDetails(params_);
        emit SetPairDetails(params_);
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external - view
    /// -----------------------------------------------------------------------

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
        public
        view
        virtual
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

        if (cqp.cBase == cqp.cQuote) {
            return quoteParams_.baseAmount;
        }

        PairDetail memory pd = $_pairDetails._get(cqp);
        if (pd.path.length == 0) {
            revert InvalidPair_FeedNotSet(quoteParams_.quotePair);
        }

        Feed[] memory feeds = abi.decode(pd.path, (Feed[]));
        uint256 feedLength = feeds.length;

        uint256 finalAnswer = 1e18;
        for (uint256 i; i < feedLength;) {
            uint256 answer = _getFeedAnswer(feeds[i]);
            if (feeds[i].mul) {
                finalAnswer = finalAnswer.mulWadDown(answer);
            } else {
                finalAnswer = finalAnswer.divWadDown(answer);
            }
            unchecked {
                ++i;
            }
        }
        if (pd.inverted) finalAnswer = uint256(1e18).divWadDown(finalAnswer);
        return _adjustQuoteDecimals(finalAnswer, quoteParams_);
    }

    function _getFeedAnswer(Feed memory feed_) internal view returns (uint256) {
        (
            , /* uint80 roundId, */
            int256 answer,
            , /* uint256 startedAt, */
            uint256 updatedAt,
            /* uint80 answeredInRound */
        ) = feed_.feed.latestRoundData();

        if (updatedAt < block.timestamp - feed_.staleAfter) {
            revert StalePrice(feed_.feed, updatedAt);
        }
        if (answer < 0) {
            revert NegativePrice(feed_.feed, answer);
        }

        if (feed_.decimals <= 18) {
            return uint256(answer) * 10 ** (18 - feed_.decimals);
        } else {
            return uint256(answer) / 10 ** (feed_.decimals - 18);
        }
    }

    /// adjust quoteAmount_ based on decimals of base & quote
    function _adjustQuoteDecimals(uint256 quoteAmount_, QuoteParams calldata quoteParams_)
        internal
        view
        returns (uint256 finalAmount)
    {
        uint8 baseDecimals = quoteParams_.quotePair.base._decimals();
        uint8 quoteDecimals = quoteParams_.quotePair.quote._decimals();

        if (18 > quoteDecimals) {
            finalAmount = quoteAmount_ / (10 ** (18 - quoteDecimals));
        } else if (18 < quoteDecimals) {
            finalAmount = quoteAmount_ * (10 ** (quoteDecimals - 18));
        } else {
            finalAmount = quoteAmount_;
        }
        return finalAmount * quoteParams_.baseAmount / 10 ** baseDecimals;
    }

    function _convert(address token_) internal view returns (address) {
        return token_._isETH() ? weth9 : token_;
    }
}
