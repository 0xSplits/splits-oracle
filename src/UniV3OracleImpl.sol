// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ConvertedQuotePair, QuotePair, QuoteParams, SortedConvertedQuotePair} from "splits-utils/LibQuotes.sol";
import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {OracleLibrary} from "v3-periphery/libraries/OracleLibrary.sol";
import {TokenUtils} from "splits-utils/TokenUtils.sol";

import {OracleImpl} from "./OracleImpl.sol";

/// @title UniV3 Oracle Implementation
/// @author 0xSplits
/// @notice A clone-implementation of an oracle using UniswapV3 TWAP
contract UniV3OracleImpl is OracleImpl {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using TokenUtils for address;

    /// -----------------------------------------------------------------------
    /// errors
    /// -----------------------------------------------------------------------

    error Pool_DoesNotExist();

    /// -----------------------------------------------------------------------
    /// structs
    /// -----------------------------------------------------------------------

    struct InitParams {
        address owner;
        bool paused;
        uint24 defaultFee;
        uint32 defaultPeriod;
        SetPairOverrideParams[] pairOverrides;
    }

    struct SetPairOverrideParams {
        QuotePair quotePair;
        PairOverride pairOverride;
    }

    struct PairOverride {
        uint24 fee;
        uint32 period;
    }

    /// -----------------------------------------------------------------------
    /// events
    /// -----------------------------------------------------------------------

    event SetDefaultFee(uint24 defaultFee);
    event SetDefaultPeriod(uint32 defaultPeriod);
    event SetPairOverrides(SetPairOverrideParams[] params);

    /// -----------------------------------------------------------------------
    /// storage
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    address public immutable uniV3OracleFactory;
    IUniswapV3Factory public immutable uniswapV3Factory;
    address public immutable weth9;

    /// -----------------------------------------------------------------------
    /// storage - mutables
    /// -----------------------------------------------------------------------

    /// slot 0 - 4 byte free

    /// OwnableImpl storage
    /// address internal $owner;
    /// 20 bytes

    /// PausableImpl storage
    /// bool internal $paused;
    /// 1 byte

    /// default uniswap pool fee
    /// @dev PERCENTAGE_SCALE = 1e6 = 100_00_00 = 100%;
    /// fee = 30_00 = 0.3% is the uniswap default
    /// unless overriden, getQuoteAmounts will revert if a non-permitted pool fee is used
    /// 3 bytes
    uint24 internal $defaultFee;

    /// default twap period
    /// @dev unless overriden, getQuoteAmounts will revert if zero
    /// 4 bytes
    uint32 internal $defaultPeriod;

    /// slot 1 - 0 bytes free

    /// overrides for specific quote pairs
    /// 32 bytes
    mapping(address => mapping(address => PairOverride)) internal $_pairOverrides;

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    constructor(IUniswapV3Factory uniswapV3Factory_, address weth9_) {
        uniV3OracleFactory = msg.sender;
        uniswapV3Factory = uniswapV3Factory_;
        weth9 = weth9_;
    }

    function initializer(InitParams calldata params_) external {
        // only uniV3OracleFactory may call `initializer`
        if (msg.sender != uniV3OracleFactory) revert Unauthorized();

        __initOwnable(params_.owner);
        $paused = params_.paused;
        $defaultFee = params_.defaultFee;
        $defaultPeriod = params_.defaultPeriod;

        _setPairOverrides(params_.pairOverrides);
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

    /// set defaultFee
    function setDefaultFee(uint24 defaultFee_) external onlyOwner {
        $defaultFee = defaultFee_;
        emit SetDefaultFee(defaultFee_);
    }

    /// set defaultPeriod
    function setDefaultPeriod(uint32 defaultPeriod_) external onlyOwner {
        $defaultPeriod = defaultPeriod_;
        emit SetDefaultPeriod(defaultPeriod_);
    }

    /// set pair overrides
    function setPairOverrides(SetPairOverrideParams[] calldata params_) external onlyOwner {
        _setPairOverrides(params_);
        emit SetPairOverrides(params_);
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external - view
    /// -----------------------------------------------------------------------

    function defaultFee() external view returns (uint24) {
        return $defaultFee;
    }

    function defaultPeriod() external view returns (uint32) {
        return $defaultPeriod;
    }

    /// get pair override for an array of quote pairs
    function getPairOverrides(QuotePair[] calldata quotePairs_)
        external
        view
        returns (PairOverride[] memory pairOverrides)
    {
        uint256 length = quotePairs_.length;
        pairOverrides = new PairOverride[](length);
        for (uint256 i; i < length;) {
            pairOverrides[i] = _getPairOverride(quotePairs_[i]);
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

    /// set pair overrides
    function _setPairOverrides(SetPairOverrideParams[] calldata params_) internal {
        uint256 length = params_.length;
        for (uint256 i; i < length;) {
            _setPairOverride(params_[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// set pair override
    function _setPairOverride(SetPairOverrideParams calldata params_) internal {
        SortedConvertedQuotePair memory scqp = _convertAndSort(params_.quotePair);
        $_pairOverrides[scqp.cToken0][scqp.cToken1] = params_.pairOverride;
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal - views
    /// -----------------------------------------------------------------------

    /// get quote amount for a trade
    function _getQuoteAmount(QuoteParams calldata quoteParams_) internal view returns (uint256) {
        ConvertedQuotePair memory cqp = quoteParams_.quotePair._convert(_convertToken);

        // skip oracle if converted tokens are equal
        if (cqp.cBase == cqp.cQuote) {
            return quoteParams_.baseAmount;
        }

        PairOverride memory po = _getPairOverride(cqp._sort());
        if (po.fee == 0) {
            po.fee = $defaultFee;
        }
        if (po.period == 0) {
            po.period = $defaultPeriod;
        }

        address pool = uniswapV3Factory.getPool(cqp.cBase, cqp.cQuote, po.fee);
        if (pool == address(0)) {
            revert Pool_DoesNotExist();
        }

        // reverts if period is zero or > oldest observation
        (int24 arithmeticMeanTick,) = OracleLibrary.consult({pool: pool, secondsAgo: po.period});

        return OracleLibrary.getQuoteAtTick({
            tick: arithmeticMeanTick + 1, // adjust for OracleLibrary always rounding down
            baseAmount: quoteParams_.baseAmount,
            baseToken: cqp.cBase,
            quoteToken: cqp.cQuote
        });
    }

    /// get pair override
    function _getPairOverride(QuotePair calldata quotePair_) internal view returns (PairOverride memory) {
        return _getPairOverride(_convertAndSort(quotePair_));
    }

    /// get pair overrides
    function _getPairOverride(SortedConvertedQuotePair memory scqp_) internal view returns (PairOverride memory) {
        return $_pairOverrides[scqp_.cToken0][scqp_.cToken1];
    }

    /// convert & sort tokens into canonical order
    function _convertAndSort(QuotePair calldata quotePair_)
        internal
        view
        returns (SortedConvertedQuotePair memory)
    {
        return quotePair_._convertAndSort(_convertToken);
    }

    /// convert eth (0x0) to weth
    function _convertToken(address token_) internal view returns (address) {
        return token_._isETH() ? weth9 : token_;
    }
}
