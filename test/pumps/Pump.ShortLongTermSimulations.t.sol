// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "test/TestHelper.sol";
import "src/pumps/GeoEmaAndCumSmaPump.sol";

import {from18, to18} from "test/pumps/PumpHelpers.sol";
import {log2, powu, UD60x18, wrap, unwrap} from "prb/math/UD60x18.sol";
import {exp2, log2, powu, UD60x18, wrap, unwrap, uUNIT} from "prb/math/UD60x18.sol";
contract PumpShortLongTermSimulationTest is TestHelper {
     GeoEmaAndCumSmaPump pump;
     uint[] b = new uint[](2);
     
     function setUp() public {
         initUser();
         pump = new GeoEmaAndCumSmaPump(from18(0.5e18), 12, from18(0.9e18));
     }

    function testLongTermSimulation() public {
        uint8 n = 2;
        uint256 blockTime = 15;
        bytes16 a = 0x3fff0000000000000000000000000000; // 0.5 in quad precision
        bytes16 maxIncrease = from18(0.01e18); // 0.01 in quad precision
        bytes16 maxDecrease = from18(0.01e18); // 0.01 in quad precision
        // GeoEmaAndCumSmaPump pump = new GeoEmaAndCumSmaPump(maxIncrease, maxDecrease, blockTime);
        uint256 startTime = block.timestamp;

        for (uint i = 0; i < 100000; i++) {
            uint256[] memory reserves = new uint256[](n);
            reserves[0] = i;
            reserves[1] = i * 2;
            bytes memory data;
            pump.update(reserves, data);
        }

        // Test cumulative reserves
        bytes memory cumulativeReserves = pump.readCumulativeReserves(address(this));
        bytes16[] memory cumulativeReserves16 = abi.decode(cumulativeReserves, (bytes16[]));
        assertEq(cumulativeReserves16.length, n, "Should have reserves for n tokens");
        // for (uint i = 0; i < n; i++) {
        //     assertEq(cumulativeReserves16[i] != 0, "Cumulative reserve should not be 0");
        // }

        // Test instantaneous reserves
        bytes memory lastInstantaneousReserves;
        // assembly {
        //     lastInstantaneousReserves := mload(0x40)
        //     let result := call(
        //         sub(gas(), 5000),
        //         pump,
        //         // 0,
        //         keccak256(abi.encodeWithSignature(bytes4(0x02), "readLastInstantaneousReserves(address)")),
        //         add(0x20, lastInstantaneousReserves),
        //         32,
        //         lastInstantaneousReserves,
        //         32
        //     )
        //     if iszero(result) {
        //         revert(add(0x20, lastInstantaneousReserves), returndatasize())
        //     }
        // }
        bytes16[] memory lastInstantaneousReserves16 = abi.decode(lastInstantaneousReserves, (bytes16[]));
        assertEq(lastInstantaneousReserves16.length, n, "Should have reserves for n tokens");
        // for (uint i = 0; i < n; i++) {
        //     assertEq(lastInstantaneousReserves16[i], 0, "Last instantaneous reserve should not be 0");
        // }

        // Test instantaneous reserves after some time
        uint256 timePassed = 60 * 60 * 24 * 30; // 30 days
        uint256[] memory reserves = new uint256[](n);
        reserves[0] = 1000;
        reserves[1] = 2000;
        bytes memory data;
        pump.update(reserves, data);
        // bytes memory instantaneousReserves = pump.readInstantaneousReserves(address(this));
        // bytes16[] memory instantaneousReserves16 = abi.decode(instantaneousReserves, (bytes16[]));
        // for (uint i = 0; i < n; i++) {
        //     assertEq(instantaneousReserves16[i], 0, "Instantaneous reserve should not be 0");
        // }
    }
        function testShortTermSimulation() public {
            uint8 n = 2;
            uint256 blockTime = 15;
            bytes16 a = 0x3fff0000000000000000000000000000; // 0.5 in quad precision
            bytes16 maxIncrease = 0x00010000000000000000000000000000; // 0.01 in quad precision
            bytes16 maxDecrease = 0x00010000000000000000000000000000; // 0.01 in quad precision
            // GeoEmaAndCumSmaPump pump = new GeoEmaAndCumSmaPump(maxIncrease, maxDecrease, blockTime, a);
            uint256 startTime = block.timestamp;

            for (uint i = 0; i < 10; i++) { // run for 10 blocks
                uint256[] memory reserves = new uint256[](n);
                reserves[0] = i;
                reserves[1] = i * 2;
                bytes memory data;
                pump.update(reserves, data);
            }

            // Test cumulative reserves
            bytes memory cumulativeReserves = pump.readCumulativeReserves(address(this));
            bytes16[] memory cumulativeReserves16 = abi.decode(cumulativeReserves, (bytes16[]));
            assertEq(cumulativeReserves16.length, n, "Should have reserves for n tokens");
            for (uint i = 0; i < n; i++) {
            assertEq(cumulativeReserves16[i], 0, "Cumulative reserve should not be 0");
            }

            // Test instantaneous reserves
            // bytes memory lastInstantaneousReserves = pump.readLastInstantaneousReserves(address(this));
            // bytes16[] memory lastInstantaneousReserves16 = abi.decode(lastInstantaneousReserves, (bytes16[]));
            // assertEq(lastInstantaneousReserves16.length, n, "Should have reserves for n tokens");
            for (uint i = 0; i < n; i++) {
            // assertEq(lastInstantaneousReserves16[i] != 0, "Last instantaneous reserve should not be 0");
            }

            // Test instantaneous reserves after some time
            uint256 timePassed = 60 * 60 * 24 * 30; // 30 days
            uint256[] memory reserves = new uint256[](n);
            reserves[0] = 1000;
            reserves[1] = 2000;
            bytes memory data;
            pump.update(reserves, data);
            // bytes memory instantaneousReserves = pump.readInstantaneousReserves(address(this));
            // bytes16[] memory instantaneousReserves16 = abi.decode(instantaneousReserves, (bytes16[]));
            for (uint i = 0; i < n; i++) {
            // assertEq(instantaneousReserves16[i] != 0, "Instantaneous reserve should not be 0");
        }
    }
}