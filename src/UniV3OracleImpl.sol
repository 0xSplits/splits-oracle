// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {OracleLibrary} from "v3-periphery/libraries/OracleLibrary.sol";
import {OwnableImpl} from "splits-utils/OwnableImpl.sol";
import {TokenUtils} from "splits-utils/TokenUtils.sol";

import {IOracle} from "./interfaces/IOracle.sol";
import {QuotePair, ConvertedQuotePair, SortedConvertedQuotePair} from "./utils/QuotePair.sol";

// TODO: add pausable ?

/// @title UniV3 Oracle Implementation
/// @author 0xSplits
/// @notice A clone-implementation of an oracle using UniswapV3 TWAP
contract UniV3OracleImpl is OwnableImpl, IOracle {
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
        uint24 defaultFee;
        uint32 defaultPeriod;
        uint32 defaultScaledOfferFactor;
        SetPairOverrideParams[] pairOverrides;
    }

    struct SetPairOverrideParams {
        QuotePair quotePair;
        PairOverride pairOverride;
    }

    struct PairOverride {
        uint24 fee;
        uint32 period;
        uint32 scaledOfferFactor;
    }

    /// -----------------------------------------------------------------------
    /// events
    /// -----------------------------------------------------------------------

    event SetDefaultFee(uint24 defaultFee);
    event SetDefaultPeriod(uint32 defaultPeriod);
    event SetDefaultScaledOfferFactor(uint32 defaultScaledOfferFactor);
    event SetPairOverride(SetPairOverrideParams[] params);

    /// -----------------------------------------------------------------------
    /// storage
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    /// @dev percentages measured in hundredths of basis points
    uint32 internal constant PERCENTAGE_SCALE = 100_00_00; // = 100%

    address public immutable uniV3OracleFactory;
    IUniswapV3Factory public immutable uniswapV3Factory;
    address public immutable weth9;

    /// -----------------------------------------------------------------------
    /// storage - mutables
    /// -----------------------------------------------------------------------

    /// slot 0 - 1 byte free

    /// OwnableImpl storage
    /// address public $owner;
    /// 20 bytes

    /// default uniswap pool fee
    /// @dev PERCENTAGE_SCALE = 1e6 = 100_00_00 = 100%;
    /// fee = 30_00 = 0.3% is the uniswap default
    /// unless overriden, getQuoteAmounts will revert if a non-permitted pool fee is used
    /// 3 bytes
    uint24 public $defaultFee;

    /// default twap period
    /// @dev unless overriden, getQuoteAmounts will revert if zero
    /// 4 bytes
    uint32 public $defaultPeriod;

    /// default price scaling factor
    /// @dev PERCENTAGE_SCALE = 1e6 = 100_00_00 = 100% = no discount or premium
    /// 99_00_00 = 99% = 1% discount to oracle; 101_00_00 = 101% = 1% premium to oracle
    /// 4 bytes
    uint32 public $defaultScaledOfferFactor;

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
        $defaultFee = params_.defaultFee;
        $defaultPeriod = params_.defaultPeriod;
        $defaultScaledOfferFactor = params_.defaultScaledOfferFactor;

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

    /// set defaultScaledOfferFactor
    function setDefaultScaledOfferFactor(uint32 defaultScaledOfferFactor_) external onlyOwner {
        $defaultScaledOfferFactor = defaultScaledOfferFactor_;
        emit SetDefaultScaledOfferFactor(defaultScaledOfferFactor_);
    }

    /// set pair overrides
    function setPairOverrides(SetPairOverrideParams[] calldata params_) external onlyOwner {
        _setPairOverrides(params_);
        emit SetPairOverride(params_);
    }

    /// -----------------------------------------------------------------------
    /// functions - public & external - views
    /// -----------------------------------------------------------------------

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
        SortedConvertedQuotePair memory scqp = _convertAndSortQuotePair(params_.quotePair);
        $_pairOverrides[scqp.cToken0][scqp.cToken1] = params_.pairOverride;
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal - views
    /// -----------------------------------------------------------------------

    /// get quote amount for a trade
    function _getQuoteAmount(QuoteParams calldata quoteParams_) internal view returns (uint256) {
        ConvertedQuotePair memory cqp = quoteParams_.quotePair._convert(_convertToken);
        SortedConvertedQuotePair memory scqp = cqp._sort();

        PairOverride memory po = _getPairOverride(scqp);
        if (po.scaledOfferFactor == 0) {
            po.scaledOfferFactor = $defaultScaledOfferFactor;
        }

        // skip oracle if converted tokens are equal
        if (cqp.cBase == cqp.cQuote) {
            return quoteParams_.baseAmount * po.scaledOfferFactor / PERCENTAGE_SCALE;
        }

        if (po.fee == 0) {
            po.fee = $defaultFee;
        }
        if (po.period == 0) {
            po.period = $defaultPeriod;
        }

        address pool = uniswapV3Factory.getPool(scqp.cToken0, scqp.cToken1, po.fee);
        if (pool == address(0)) {
            revert Pool_DoesNotExist();
        }

        // reverts if period is zero or > oldest observation
        (int24 arithmeticMeanTick,) = OracleLibrary.consult({pool: pool, secondsAgo: po.period});

        uint256 unscaledAmountToBeneficiary = OracleLibrary.getQuoteAtTick({
            tick: arithmeticMeanTick,
            baseAmount: quoteParams_.baseAmount,
            baseToken: cqp.cBase,
            quoteToken: cqp.cQuote
        });

        return unscaledAmountToBeneficiary * po.scaledOfferFactor / PERCENTAGE_SCALE;
    }

    /// get pair override
    function _getPairOverride(QuotePair calldata quotePair_) internal view returns (PairOverride memory) {
        return _getPairOverride(_convertAndSortQuotePair(quotePair_));
    }

    /// get pair overrides
    function _getPairOverride(SortedConvertedQuotePair memory scqp_) internal view returns (PairOverride memory) {
        return $_pairOverrides[scqp_.cToken0][scqp_.cToken1];
    }

    /// convert & sort tokens into canonical order
    function _convertAndSortQuotePair(QuotePair calldata quotePair_)
        internal
        view
        returns (SortedConvertedQuotePair memory)
    {
        return quotePair_._convert(_convertToken)._sort();
    }

    /// convert eth (0x0) to weth
    function _convertToken(address token_) internal view returns (address) {
        return token_._isETH() ? weth9 : token_;
    }
}
