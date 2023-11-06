// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/Base.t.sol";
import {AggregatorV3Interface} from "chainlink/interfaces/AggregatorV3Interface.sol";
import {
    Initialized_PausableImplBase,
    PausableImplHarness,
    Uninitialized_PausableImplBase
} from "splits-tests/PausableImpl/PausableImplBase.t.sol";
import {OwnableImplHarness} from "splits-tests/OwnableImpl/OwnableImplBase.t.sol";
import {QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";
import {ChainlinkOracleFactory} from "../../src/ChainlinkOracleFactory.sol";
import {ChainlinkOracleImpl} from "../../src/ChainlinkOracleImpl.sol";
import {IChainlinkOracleFactory} from "../../src/interfaces/IChainlinkOracleFactory.sol";
import {IOracle} from "../../src/interfaces/IOracle.sol";

interface IChainlinkOracle is IOracle {
    function initializer(ChainlinkOracleImpl.InitParams calldata params_) external;
    function setPairDetails(ChainlinkOracleImpl.SetPairDetailParams[] calldata params_) external;
    function getPairDetails(QuotePair[] calldata quotePairs_)
        external
        view
        returns (ChainlinkOracleImpl.PairDetail[] memory pairDetails);
}

abstract contract Uninitialized_ChainlinkOracleImplBase is Uninitialized_PausableImplBase {
    error InvalidPair_PoolNotSet();

    event SetPairDetails(ChainlinkOracleImpl.SetPairDetailParams[] params);

    IChainlinkOracleFactory $oracleFactory;
    IChainlinkOracle $oracle;

    address $notFactory;

    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    QuotePair $wethETH;
    QuotePair $usdcETH;
    QuotePair $daiETH;
    QuotePair $ethUSDT;
    QuotePair $daiUSDC;
    QuotePair $mockERC20ETH;

    ChainlinkOracleImpl.SetPairDetailParams[] $pairDetails;
    ChainlinkOracleImpl.SetPairDetailParams[] $nextPairDetails;

    QuoteParams[] $wethQuoteParams;
    QuoteParams[] $usdcQuoteParams;
    QuoteParams[] $daiQuoteParams;
    QuoteParams[] $ethUSDTQuoteParams;
    QuoteParams[] $mockERC20QuoteParams;

    address constant USDC_ETH_AGG = 0x986b5E1e1755e3C2440e960477f25201B0a8bbD4;
    address constant DAI_ETH_AGG = 0x773616E4d11A78F511299002da57A0a94577F1f4;
    address constant ETH_USD_AGG = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address constant USDT_USD_FEED = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;

    address $testing_agg;

    function setUp() public virtual override {
        Uninitialized_PausableImplBase.setUp();

        vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER);

        $oracleFactory = IChainlinkOracleFactory(address(new ChainlinkOracleFactory(WETH9)));

        /// setup feeds
        ChainlinkOracleImpl.Feed memory USDC_ETH_FEED = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface(USDC_ETH_AGG),
            staleAfter: 86400,
            decimals: 18,
            mul: true
        });

        ChainlinkOracleImpl.Feed memory USDC_ETH_FEED_DIV = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface(USDC_ETH_AGG),
            staleAfter: 86400,
            decimals: 18,
            mul: false
        });

        ChainlinkOracleImpl.Feed memory DAI_ETH_FEED = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface(DAI_ETH_AGG),
            staleAfter: 86400,
            decimals: 18,
            mul: true
        });

        ChainlinkOracleImpl.Feed memory ETH_USD_FEED = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface(ETH_USD_AGG),
            staleAfter: 86400,
            decimals: 8,
            mul: true
        });

        ChainlinkOracleImpl.Feed memory USDT_USD_FEED = ChainlinkOracleImpl.Feed({
            feed: AggregatorV3Interface(USDT_USD_FEED),
            staleAfter: 86400,
            decimals: 8,
            mul: false
        });

        $testing_agg = USDC_ETH_AGG;

        /// setup quotepairs
        $wethETH = QuotePair({base: WETH9, quote: ETH_ADDRESS});
        $usdcETH = QuotePair({base: USDC, quote: ETH_ADDRESS});
        $daiETH = QuotePair({base: DAI, quote: ETH_ADDRESS});
        $ethUSDT = QuotePair({base: ETH_ADDRESS, quote: USDT});
        $daiUSDC = QuotePair({base: DAI, quote: USDC});
        $mockERC20ETH = QuotePair({base: address(mockERC20), quote: ETH_ADDRESS});

        /// setup paths
        ChainlinkOracleImpl.Feed[] memory usdcETHPath = new ChainlinkOracleImpl.Feed[](1);
        usdcETHPath[0] = USDC_ETH_FEED;
        ChainlinkOracleImpl.Feed[] memory daiETHPath = new ChainlinkOracleImpl.Feed[](1);
        daiETHPath[0] = DAI_ETH_FEED;

        ChainlinkOracleImpl.Feed[] memory ethUSDTPath = new ChainlinkOracleImpl.Feed[](2);
        ethUSDTPath[0] = ETH_USD_FEED;
        ethUSDTPath[1] = USDT_USD_FEED;

        ChainlinkOracleImpl.Feed[] memory daiUSDCPath = new ChainlinkOracleImpl.Feed[](2);
        daiUSDCPath[0] = DAI_ETH_FEED;
        daiUSDCPath[1] = USDC_ETH_FEED_DIV;

        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: $usdcETH,
                pairDetail: ChainlinkOracleImpl.PairDetail({path: abi.encode(usdcETHPath), inverted: false})
            })
        );

        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: $daiETH,
                pairDetail: ChainlinkOracleImpl.PairDetail({path: abi.encode(daiETHPath), inverted: false})
            })
        );

        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: $ethUSDT,
                pairDetail: ChainlinkOracleImpl.PairDetail({path: abi.encode(ethUSDTPath), inverted: false})
            })
        );

        $pairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: $daiUSDC,
                pairDetail: ChainlinkOracleImpl.PairDetail({path: abi.encode(daiUSDCPath), inverted: false})
            })
        );

        $nextPairDetails.push(
            ChainlinkOracleImpl.SetPairDetailParams({
                quotePair: $usdcETH,
                pairDetail: ChainlinkOracleImpl.PairDetail({path: abi.encode(usdcETHPath), inverted: false})
            })
        );

        $wethQuoteParams.push(QuoteParams({quotePair: $wethETH, baseAmount: 1 ether, data: ""}));

        $usdcQuoteParams.push(
            QuoteParams({
                quotePair: $usdcETH,
                baseAmount: 10 ** 9, // $1,000 usc ~= 0.5 eth
                data: ""
            })
        );

        $ethUSDTQuoteParams.push(
            QuoteParams({
                quotePair: $ethUSDT,
                baseAmount: 10 ** 18, // $1,000 usc ~= 0.5 eth
                data: ""
            })
        );

        $daiQuoteParams.push(
            QuoteParams({
                quotePair: $daiETH,
                baseAmount: 10 ** 21, // $1,000 dai ~= 0.5 eth
                data: ""
            })
        );

        $mockERC20QuoteParams.push(
            QuoteParams({
                quotePair: $mockERC20ETH,
                baseAmount: uint128((10 ** 3) * (10 ** MOCK_ERC20_DECIMALS)),
                data: ""
            })
        );

        _setUpChainlinkOracleImplState({
            oracle_: address($oracleFactory.chainlinkOracleImpl()),
            owner_: users.alice,
            paused_: false,
            notFactory_: users.eve,
            pairDetails_: $pairDetails,
            nextPairDetails_: $nextPairDetails,
            wethQuoteParams_: $wethQuoteParams,
            usdcQuoteParams_: $usdcQuoteParams,
            daiQuoteParams_: $daiQuoteParams,
            mockERC20QuoteParams_: $mockERC20QuoteParams
        });
    }

    function _setUpChainlinkOracleImplState(
        address oracle_,
        address owner_,
        bool paused_,
        address notFactory_,
        ChainlinkOracleImpl.SetPairDetailParams[] memory pairDetails_,
        ChainlinkOracleImpl.SetPairDetailParams[] memory nextPairDetails_,
        QuoteParams[] memory wethQuoteParams_,
        QuoteParams[] memory usdcQuoteParams_,
        QuoteParams[] memory daiQuoteParams_,
        QuoteParams[] memory mockERC20QuoteParams_
    ) internal virtual {
        _setUpPausableImplState({pausable_: oracle_, paused_: paused_});

        $oracle = IChainlinkOracle(oracle_);
        $owner = owner_;
        $paused = paused_;
        $notFactory = notFactory_;

        delete $pairDetails;
        for (uint256 i = 0; i < pairDetails_.length; i++) {
            $pairDetails.push(pairDetails_[i]);
        }

        delete $nextPairDetails;
        for (uint256 i = 0; i < nextPairDetails_.length; i++) {
            $nextPairDetails.push(nextPairDetails_[i]);
        }

        delete $wethQuoteParams;
        for (uint256 i = 0; i < wethQuoteParams_.length; i++) {
            $wethQuoteParams.push(wethQuoteParams_[i]);
        }

        delete $usdcQuoteParams;
        for (uint256 i = 0; i < usdcQuoteParams_.length; i++) {
            $usdcQuoteParams.push(usdcQuoteParams_[i]);
        }

        delete $daiQuoteParams;
        for (uint256 i = 0; i < daiQuoteParams_.length; i++) {
            $daiQuoteParams.push(daiQuoteParams_[i]);
        }

        delete $mockERC20QuoteParams;
        for (uint256 i = 0; i < mockERC20QuoteParams_.length; i++) {
            $mockERC20QuoteParams.push(mockERC20QuoteParams_[i]);
        }
    }

    function _setUpChainlinkOracleParams(ChainlinkOracleImpl.InitParams memory params_) internal virtual {
        $owner = params_.owner;
        $paused = params_.paused;

        delete $pairDetails;
        for (uint256 i = 0; i < params_.pairDetails.length; i++) {
            $pairDetails.push(params_.pairDetails[i]);
        }
    }

    function _initParams() internal view returns (ChainlinkOracleImpl.InitParams memory) {
        return ChainlinkOracleImpl.InitParams({owner: $owner, paused: $paused, pairDetails: $pairDetails});
    }

    function _initialize() internal virtual override {
        $oracle = IChainlinkOracle(address($oracleFactory.createChainlinkOracle(_initParams())));
        $ownable = OwnableImplHarness(address($oracle));
        $pausable = PausableImplHarness(address($oracle));
    }

    /// -----------------------------------------------------------------------
    /// modifiers
    /// -----------------------------------------------------------------------

    modifier callerNotFactory(address notFactory_) {
        vm.assume(notFactory_ != address($oracleFactory));
        $notFactory = notFactory_;
        vm.startPrank(notFactory_);
        _;
    }

    modifier callerFactory() {
        vm.startPrank(address($oracleFactory));
        _;
    }

    /// -----------------------------------------------------------------------
    /// internal
    /// -----------------------------------------------------------------------

    function assertEq(ChainlinkOracleImpl.PairDetail[] memory a, ChainlinkOracleImpl.PairDetail[] memory b) internal {
        assertEq(a.length, b.length);
        for (uint256 i; i < a.length; i++) {
            assertEq(a[i], b[i]);
        }
    }

    function assertEq(ChainlinkOracleImpl.PairDetail memory a, ChainlinkOracleImpl.PairDetail memory b) internal {
        assertEq(a.path, b.path);
        assertEq(a.inverted, b.inverted);
    }
}

abstract contract Initialized_ChainlinkOracleImplBase is
    Uninitialized_ChainlinkOracleImplBase,
    Initialized_PausableImplBase
{
    function setUp() public virtual override(Uninitialized_ChainlinkOracleImplBase, Initialized_PausableImplBase) {
        Uninitialized_ChainlinkOracleImplBase.setUp();
        _initialize();
    }

    function _initialize()
        internal
        virtual
        override(Uninitialized_ChainlinkOracleImplBase, Initialized_PausableImplBase)
    {
        Uninitialized_ChainlinkOracleImplBase._initialize();
    }
}

abstract contract Paused_Initialized_ChainlinkOracleImplBase is Initialized_ChainlinkOracleImplBase {
    function setUp() public virtual override {
        Uninitialized_ChainlinkOracleImplBase.setUp();
        $paused = true;
        _initialize();
    }
}

abstract contract Unpaused_Initialized_ChainlinkOracleImplBase is Initialized_ChainlinkOracleImplBase {}
