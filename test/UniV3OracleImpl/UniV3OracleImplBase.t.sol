// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/Base.t.sol";

import {
    Initialized_PausableImplBase,
    PausableImplHarness,
    Uninitialized_PausableImplBase
} from "splits-tests/PausableImpl/PausableImplBase.t.sol";
import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {OwnableImplHarness} from "splits-tests/OwnableImpl/OwnableImplBase.t.sol";
import {QuotePair, QuoteParams} from "splits-utils/LibQuotes.sol";

import {UniV3OracleFactory} from "../../src/UniV3OracleFactory.sol";
import {UniV3OracleImpl} from "../../src/UniV3OracleImpl.sol";

// State tree
//  Uninitialized
//  Initialized
//   Paused
//   Unpaused

abstract contract Uninitialized_UniV3OracleImplBase is Uninitialized_PausableImplBase {
    error InvalidPair_PoolNotSet();

    event SetDefaultPeriod(uint32 defaultPeriod);
    event SetPairDetails(UniV3OracleImpl.SetPairDetailParams[] params);

    UniV3OracleFactory $oracleFactory;
    UniV3OracleImpl $oracle;

    uint32 $defaultPeriod;
    uint32 $nextDefaultPeriod;
    address $notFactory;

    QuotePair $wethETH;
    QuotePair $usdcETH;
    QuotePair $daiETH;
    QuotePair $mockERC20ETH;

    UniV3OracleImpl.SetPairDetailParams[] $pairDetails;
    UniV3OracleImpl.SetPairDetailParams[] $nextPairDetails;

    QuoteParams[] $wethQuoteParams;
    QuoteParams[] $usdcQuoteParams;
    QuoteParams[] $daiQuoteParams;
    QuoteParams[] $mockERC20QuoteParams;

    function setUp() public virtual override {
        Uninitialized_PausableImplBase.setUp();

        vm.createSelectFork(vm.rpcUrl("mainnet"), BLOCK_NUMBER);

        $oracleFactory = new UniV3OracleFactory({
            weth9_: WETH9
        });

        $wethETH = QuotePair({base: WETH9, quote: ETH_ADDRESS});
        $usdcETH = QuotePair({base: USDC, quote: ETH_ADDRESS});
        $daiETH = QuotePair({base: DAI, quote: ETH_ADDRESS});
        $mockERC20ETH = QuotePair({base: address(mockERC20), quote: ETH_ADDRESS});

        $pairDetails.push(
            UniV3OracleImpl.SetPairDetailParams({
                quotePair: $usdcETH,
                pairDetail: UniV3OracleImpl.PairDetail({
                    pool: IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(USDC, WETH9, 5_00),
                    period: 0 // no override
                })
            })
        );
        $pairDetails.push(
            UniV3OracleImpl.SetPairDetailParams({
                quotePair: $daiETH,
                pairDetail: UniV3OracleImpl.PairDetail({
                    pool: IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(DAI, WETH9, 5_00),
                    period: 60 minutes
                })
            })
        );

        $nextPairDetails.push(
            UniV3OracleImpl.SetPairDetailParams({
                quotePair: $usdcETH,
                pairDetail: UniV3OracleImpl.PairDetail({
                    pool: IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(USDC, WETH9, 30_00),
                    period: 0 // no override
                })
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

        _setUpUniV3OracleImplState({
            oracle_: address($oracleFactory.uniV3OracleImpl()),
            owner_: users.alice,
            paused_: false,
            defaultPeriod_: 30 minutes,
            nextDefaultPeriod_: 60 minutes,
            notFactory_: users.eve,
            pairDetails_: $pairDetails,
            nextPairDetails_: $nextPairDetails,
            wethQuoteParams_: $wethQuoteParams,
            usdcQuoteParams_: $usdcQuoteParams,
            daiQuoteParams_: $daiQuoteParams,
            mockERC20QuoteParams_: $mockERC20QuoteParams
        });
    }

    function _setUpUniV3OracleImplState(
        address oracle_,
        address owner_,
        bool paused_,
        uint32 defaultPeriod_,
        uint32 nextDefaultPeriod_,
        address notFactory_,
        UniV3OracleImpl.SetPairDetailParams[] memory pairDetails_,
        UniV3OracleImpl.SetPairDetailParams[] memory nextPairDetails_,
        QuoteParams[] memory wethQuoteParams_,
        QuoteParams[] memory usdcQuoteParams_,
        QuoteParams[] memory daiQuoteParams_,
        QuoteParams[] memory mockERC20QuoteParams_
    ) internal virtual {
        _setUpPausableImplState({pausable_: oracle_, paused_: paused_});

        $oracle = UniV3OracleImpl(oracle_);
        $owner = owner_;
        $paused = paused_;
        $defaultPeriod = defaultPeriod_;
        $nextDefaultPeriod = nextDefaultPeriod_;
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

    function _setUpUniV3OracleParams(UniV3OracleImpl.InitParams memory params_) internal virtual {
        $owner = params_.owner;
        $paused = params_.paused;
        $defaultPeriod = params_.defaultPeriod;

        delete $pairDetails;
        for (uint256 i = 0; i < params_.pairDetails.length; i++) {
            $pairDetails.push(params_.pairDetails[i]);
        }
    }

    function _initParams() internal view returns (UniV3OracleImpl.InitParams memory) {
        return UniV3OracleImpl.InitParams({
            owner: $owner,
            paused: $paused,
            defaultPeriod: $defaultPeriod,
            pairDetails: $pairDetails
        });
    }

    function _initialize() internal virtual override {
        $oracle = $oracleFactory.createUniV3Oracle(_initParams());
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

    function assertEq(UniV3OracleImpl.PairDetail[] memory a, UniV3OracleImpl.PairDetail[] memory b) internal {
        assertEq(a.length, b.length);
        for (uint256 i; i < a.length; i++) {
            assertEq(a[i], b[i]);
        }
    }

    function assertEq(UniV3OracleImpl.PairDetail memory a, UniV3OracleImpl.PairDetail memory b) internal {
        assertEq(a.pool, b.pool);
        assertEq(a.period, b.period);
    }
}

abstract contract Initialized_UniV3OracleImplBase is Uninitialized_UniV3OracleImplBase, Initialized_PausableImplBase {
    function setUp() public virtual override(Uninitialized_UniV3OracleImplBase, Initialized_PausableImplBase) {
        Uninitialized_UniV3OracleImplBase.setUp();
        _initialize();
    }

    function _initialize() internal virtual override(Uninitialized_UniV3OracleImplBase, Initialized_PausableImplBase) {
        Uninitialized_UniV3OracleImplBase._initialize();
    }
}

abstract contract Paused_Initialized_UniV3OracleImplBase is Initialized_UniV3OracleImplBase {
    function setUp() public virtual override {
        Uninitialized_UniV3OracleImplBase.setUp();
        $paused = true;
        _initialize();
    }
}

abstract contract Unpaused_Initialized_UniV3OracleImplBase is Initialized_UniV3OracleImplBase {}
