// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {ChainlinkOracleImpl} from "./ChainlinkOracleImpl.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {QuoteParams} from "splits-utils/LibQuotes.sol";

/// @title Chainlink Oracle Implementation
/// @author 0xSplits
/// @notice A clone-implementation of an oracle using Chainlink
/// @dev This contract uses token = address(0) to refer to ETH.
contract ChainlinkOracleL2Impl is ChainlinkOracleImpl {
    /// -----------------------------------------------------------------------
    /// errors
    /// -----------------------------------------------------------------------

    error SequencerDown();
    error GracePeriodNotOver();

    /// -----------------------------------------------------------------------
    /// storage
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    AggregatorV3Interface public immutable sequencerFeed;
    uint256 constant GRACE_PERIOD_TIME = 1 hours;

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

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    constructor(address weth9_, AggregatorV3Interface sequencerFeed_) ChainlinkOracleImpl(weth9_) {
        sequencerFeed = sequencerFeed_;
    }

    /// -----------------------------------------------------------------------
    /// functions
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// functions - public & external
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// functions - public & external - view
    /// -----------------------------------------------------------------------

    /// get amounts for an array of quotes
    function getQuoteAmounts(QuoteParams[] calldata quoteParams_)
        public
        view
        override
        pausable
        returns (uint256[] memory quoteAmounts)
    {
        _checkSequencerFeed();
        return super.getQuoteAmounts(quoteParams_);
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal - views
    /// -----------------------------------------------------------------------

    /// check sequencer feed
    function _checkSequencerFeed() private view {
        (
            /*uint80 roundID*/
            ,
            int256 answer,
            uint256 startedAt,
            /*uint256 updatedAt*/
            ,
            /*uint80 answeredInRound*/
        ) = sequencerFeed.latestRoundData();

        // Answer == 0: Sequencer is up
        // Answer == 1: Sequencer is down
        if (answer == 1) {
            revert SequencerDown();
        }

        if (block.timestamp - startedAt <= GRACE_PERIOD_TIME) {
            revert GracePeriodNotOver();
        }
    }
}
