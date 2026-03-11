// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ContractA} from "./ContractA.sol";

contract ContractB {
    ContractA public immutable TARGET;
    mapping(address => uint256) public mirroredCredits;

    constructor(ContractA target_) {
        TARGET = target_;
    }

    function mirrorQuote(address user) external view returns (uint256) {
        return TARGET.quoteWithdrawal(user);
    }

    function forwardDeposit() external payable {
        (bool ok,) = address(TARGET).call{value: msg.value}(abi.encodeWithSelector(ContractA.deposit.selector));
        ok;
        mirroredCredits[msg.sender] += msg.value;
    }
}
