// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/Base.t.sol";
import {IUniswapV3Factory} from "v3-core/interfaces/IUniswapV3Factory.sol";
import {QuotePair} from "splits-utils/LibQuotes.sol";

import {UniV3OracleFactory} from "../src/UniV3OracleFactory.sol";
import {UniV3OracleImpl} from "../src/UniV3OracleImpl.sol";

contract UniV3OracleFactoryTest is BaseTest {
    event CreateUniV3Oracle(UniV3OracleImpl indexed oracle, UniV3OracleImpl.InitParams params);

    UniV3OracleFactory $oracleFactory;
    UniV3OracleImpl $oracleImpl;

    address $owner;
    bool $paused;
    uint32 $defaultPeriod;

    QuotePair $wethETH;
    QuotePair $usdcETH;

    UniV3OracleImpl.SetPairDetailParams[] $pairDetails;

    function setUp() public virtual override {
        BaseTest.setUp();

        $oracleFactory = new UniV3OracleFactory({
            weth9_: WETH9
        });
        $oracleImpl = $oracleFactory.uniV3OracleImpl();

        $owner = users.alice;
        $paused = false;
        $defaultPeriod = 30 minutes;

        $wethETH = QuotePair({base: WETH9, quote: ETH_ADDRESS});
        $usdcETH = QuotePair({base: USDC, quote: ETH_ADDRESS});

        $pairDetails.push(
            UniV3OracleImpl.SetPairDetailParams({
                quotePair: $wethETH,
                pairDetail: UniV3OracleImpl.PairDetail({
                    pool: address(0), // no override
                    period: 0 // no override
                })
            })
        );
        $pairDetails.push(
            UniV3OracleImpl.SetPairDetailParams({
                quotePair: $usdcETH,
                pairDetail: UniV3OracleImpl.PairDetail({
                    pool: users.eve, // fake pool fine here
                    period: 0 // no override
                })
            })
        );
    }

    function _initOracleParams() internal view returns (UniV3OracleImpl.InitParams memory) {
        return UniV3OracleImpl.InitParams({
            owner: $owner,
            paused: $paused,
            defaultPeriod: $defaultPeriod,
            pairDetails: $pairDetails
        });
    }

    /// -----------------------------------------------------------------------
    /// createUniV3Oracle
    /// -----------------------------------------------------------------------

    function test_createUniV3Oracle_callsInitializer() public {
        UniV3OracleImpl.InitParams memory params = _initOracleParams();

        vm.expectCall({
            callee: address($oracleImpl),
            msgValue: 0 ether,
            data: abi.encodeCall(UniV3OracleImpl.initializer, (params))
        });
        $oracleFactory.createUniV3Oracle(params);
    }

    function testFuzz_createUniV3Oracle_callsInitializer(UniV3OracleImpl.InitParams calldata params_) public {
        vm.expectCall({
            callee: address($oracleImpl),
            msgValue: 0 ether,
            data: abi.encodeCall(UniV3OracleImpl.initializer, (params_))
        });
        $oracleFactory.createUniV3Oracle(params_);
    }

    function test_createUniV3Oracle_emitsCreateUniV3Oracle() public {
        UniV3OracleImpl.InitParams memory params = _initOracleParams();

        UniV3OracleImpl expectedOracle = UniV3OracleImpl(_predictNextAddressFrom(address($oracleFactory)));
        _expectEmit();
        emit CreateUniV3Oracle(expectedOracle, params);
        $oracleFactory.createUniV3Oracle(params);
    }

    function testFuzz_createUniV3Oracle_emitsCreateUniV3Oracle(UniV3OracleImpl.InitParams calldata params_) public {
        UniV3OracleImpl expectedOracle = UniV3OracleImpl(_predictNextAddressFrom(address($oracleFactory)));
        _expectEmit();
        emit CreateUniV3Oracle(expectedOracle, params_);
        $oracleFactory.createUniV3Oracle(params_);
    }

    /// -----------------------------------------------------------------------
    /// createOracle
    /// -----------------------------------------------------------------------

    function test_createOracle_callsInitializer() public {
        UniV3OracleImpl.InitParams memory params = _initOracleParams();

        vm.expectCall({
            callee: address($oracleImpl),
            msgValue: 0 ether,
            data: abi.encodeCall(UniV3OracleImpl.initializer, (params))
        });
        $oracleFactory.createOracle(abi.encode(params));
    }

    function test_createOracle_emitsCreateUniV3Oracle() public {
        UniV3OracleImpl.InitParams memory params = _initOracleParams();

        UniV3OracleImpl expectedOracle = UniV3OracleImpl(_predictNextAddressFrom(address($oracleFactory)));
        _expectEmit();
        emit CreateUniV3Oracle(expectedOracle, params);
        $oracleFactory.createOracle(abi.encode(params));
    }

    function testFuzz_createOracle_callsInitializer(UniV3OracleImpl.InitParams calldata params_) public {
        vm.expectCall({
            callee: address($oracleImpl),
            msgValue: 0 ether,
            data: abi.encodeCall(UniV3OracleImpl.initializer, (params_))
        });
        $oracleFactory.createOracle(abi.encode(params_));
    }

    function testFuzz_createOracle_emitsCreateUniV3Oracle(UniV3OracleImpl.InitParams calldata params_) public {
        UniV3OracleImpl expectedOracle = UniV3OracleImpl(_predictNextAddressFrom(address($oracleFactory)));
        _expectEmit();
        emit CreateUniV3Oracle(expectedOracle, params_);
        $oracleFactory.createOracle(abi.encode(params_));
    }
}
