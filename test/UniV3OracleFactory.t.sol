// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "splits-tests/Base.t.sol";

import {UniV3OracleFactory} from "../src/UniV3OracleFactory.sol";
import {UniV3OracleImpl} from "../src/UniV3OracleImpl.sol";

// TODO: add fuzz tests

contract UniV3OracleFactoryTest is BaseTest {
    event CreateUniV3Oracle(UniV3OracleImpl indexed oracle, UniV3OracleImpl.InitParams params);

    UniV3OracleFactory oracleFactory;
    UniV3OracleImpl oracleImpl;

    UniV3OracleImpl.SetPairOverrideParams[] pairOverrides;

    function setUp() public virtual override {
        super.setUp();

        oracleFactory = new UniV3OracleFactory({
            weth9_: WETH9
        });
        oracleImpl = oracleFactory.uniV3OracleImpl();

        // TODO: add pair override?
    }

    function _initOracleParams() internal view returns (UniV3OracleImpl.InitParams memory) {
        return UniV3OracleImpl.InitParams({
            owner: users.alice,
            paused: false,
            defaultPeriod: 30 minutes,
            pairOverrides: pairOverrides
        });
    }

    /// -----------------------------------------------------------------------
    /// tests - basic
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// tests - basic - createUniV3Oracle
    /// -----------------------------------------------------------------------

    function test_createUniV3Oracle_callsInitializer() public {
        UniV3OracleImpl.InitParams memory params = _initOracleParams();

        vm.expectCall({
            callee: address(oracleImpl),
            msgValue: 0 ether,
            data: abi.encodeCall(UniV3OracleImpl.initializer, (params))
        });
        oracleFactory.createUniV3Oracle(params);
    }

    function test_createUniV3Oracle_emitsCreateUniV3Oracle() public {
        UniV3OracleImpl.InitParams memory params = _initOracleParams();

        UniV3OracleImpl expectedOracle = UniV3OracleImpl(_predictNextAddressFrom(address(oracleFactory)));
        _expectEmit();
        emit CreateUniV3Oracle(expectedOracle, params);
        oracleFactory.createUniV3Oracle(params);
    }

    /// -----------------------------------------------------------------------
    /// tests - basic - createOracle
    /// -----------------------------------------------------------------------

    function test_createOracle_callsInitializer() public {
        UniV3OracleImpl.InitParams memory params = _initOracleParams();

        vm.expectCall({
            callee: address(oracleImpl),
            msgValue: 0 ether,
            data: abi.encodeCall(UniV3OracleImpl.initializer, (params))
        });
        oracleFactory.createOracle(abi.encode(params));
    }

    function test_createOracle_emitsCreateUniV3Oracle() public {
        UniV3OracleImpl.InitParams memory params = _initOracleParams();

        UniV3OracleImpl expectedOracle = UniV3OracleImpl(_predictNextAddressFrom(address(oracleFactory)));
        _expectEmit();
        emit CreateUniV3Oracle(expectedOracle, params);
        oracleFactory.createOracle(abi.encode(params));
    }
}
