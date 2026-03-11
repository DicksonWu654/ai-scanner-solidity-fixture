// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ContractA} from "../src/ContractA.sol";
import {ContractB} from "../src/ContractB.sol";

contract ScannerFixtureTest is Test {
    ContractA internal contractA;
    ContractB internal contractB;

    function setUp() public {
        contractA = new ContractA();
        contractB = new ContractB(contractA);
    }

    function testDirectDepositAndQuote() public {
        contractA.deposit{value: 2 ether}();

        uint256 expectedFee = (2 ether * contractA.feeBps()) / 10_000;
        assertEq(contractB.mirrorQuote(address(this)), 2 ether - expectedFee);
    }

    function testForwardDepositCreditsContractBInTarget() public {
        contractB.forwardDeposit{value: 1 ether}();

        assertEq(contractA.balances(address(contractB)), 1 ether);
        assertEq(contractB.mirroredCredits(address(this)), 1 ether);
    }
}
