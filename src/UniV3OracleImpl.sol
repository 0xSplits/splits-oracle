// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ConvertedQuotePair, QuotePair, QuoteParams, SortedConvertedQuotePair} from "splits-utils/LibQuotes.sol";
import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {OracleLibrary} from "v3-periphery/libraries/OracleLibrary.sol";
import {QuoteParams} from "splits-utils/LibQuotes.sol";
import {TokenUtils} from "splits-utils/TokenUtils.sol";

import {OracleImpl} from "./OracleImpl.sol";
import {PairDetails} from "./libraries/PairDetails.sol";

/// @title UniV3 Oracle Implementation
/// @author 0xSplits
/// @notice A clone-implementation of an oracle using UniswapV3 TWAP
/// @dev This contract uses token = address(0) to refer to ETH.
contract UniV3OracleImpl is OracleImpl {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using TokenUtils for address;
    using PairDetails for mapping(address => mapping(address => PairDetail));

    /// -----------------------------------------------------------------------
    /// errors
    /// -----------------------------------------------------------------------

    error InvalidPair_PoolNotSet();

    /// -----------------------------------------------------------------------
    /// structs
    /// -----------------------------------------------------------------------

    struct InitParams {
        address owner;
        bool paused;
        uint32 defaultPeriod;
        SetPairDetailParams[] pairDetails;
    }

    struct SetPairDetailParams {
        QuotePair quotePair;
        PairDetail pairDetail;
    }

    struct PairDetail {
        address pool;
        uint32 period;
    }

    /// -----------------------------------------------------------------------
    /// events
    /// -----------------------------------------------------------------------

    event SetDefaultPeriod(uint32 defaultPeriod);
    event SetPairDetails(SetPairDetailParams[] params);

    /// -----------------------------------------------------------------------
    /// storage
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    address public immutable weth9;
    address public immutable uniV3OracleFactory;

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

    /// default twap period
    /// @dev unless overriden, getQuoteAmounts will revert if zero
    /// 4 bytes
    uint32 internal $defaultPeriod;

    /// slot 1 - 0 bytes free

    /// details for specific quote pairs
    /// 32 bytes
    mapping(address => mapping(address => PairDetail)) internal $_pairDetails;

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    constructor(address weth9_) {
        weth9 = weth9_;
        uniV3OracleFactory = msg.sender;
    }

    function initializer(InitParams calldata params_) external {
        // only uniV3OracleFactory may call `initializer`
        if (msg.sender != uniV3OracleFactory) revert Unauthorized();

        __initOwnable(params_.owner);
        $paused = params_.paused;
        $defaultPeriod = params_.defaultPeriod;

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

    /// set defaultPeriod
    function setDefaultPeriod(uint32 defaultPeriod_) external onlyOwner {
        $defaultPeriod = defaultPeriod_;
        emit SetDefaultPeriod(defaultPeriod_);
    }

    /// set pair details
    function setPairDetails(SetPairDetailParams[] calldata params_) external onlyOwner {
        _setPairDetails(params_);
        emit SetPairDetails(params_);
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external - view
    /// -----------------------------------------------------------------------

    function defaultPeriod() external view returns (uint32) {
        return $defaultPeriod;
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

        PairDetail memory po = $_pairDetails._get(cqp._sort());
        if (po.pool == address(0)) {
            revert InvalidPair_PoolNotSet();
        }
        if (po.period == 0) {
            po.period = $defaultPeriod;
        }

        // reverts if period is zero or > oldest observation
        (int24 arithmeticMeanTick,) = OracleLibrary.consult({pool: po.pool, secondsAgo: po.period});

        return OracleLibrary.getQuoteAtTick({
            tick: arithmeticMeanTick + 1, // adjust for OracleLibrary always rounding down
            baseAmount: quoteParams_.baseAmount,
            baseToken: cqp.cBase,
            quoteToken: cqp.cQuote
        });
    }

    /// convert ETH (0x0) to WETH
    function _convert(address token_) internal view returns (address) {
        return token_._isETH() ? weth9 : token_;
    }
}
