// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ContractA} from "../src/ContractA.sol";
import {ContractB} from "../src/ContractB.sol";

contract ScannerFixtureTest is Test {
    ContractA internal contractA;
    ContractB internal contractB;
    address internal recipient = address(0xBEEF);

    receive() external payable {}

    function setUp() public {
        vm.deal(address(this), 100 ether);
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

    function testVaultStrategyAndWithdrawalFlow() public {
        uint256 vaultId = contractA.createVault(address(this), 150);
        uint256 mintedShares = contractA.depositToVault{value: 3 ether}(vaultId);
        assertEq(mintedShares, 3 ether);
        assertEq(contractA.vaultShares(vaultId, address(this)), 3 ether);

        contractA.accrueVaultYield{value: 1 ether}(vaultId);
        contractA.harvestVaultYield(vaultId);

        uint256 strategyId = contractA.registerStrategy(address(0xCAFE), 10 ether);
        contractA.attachStrategy(vaultId, strategyId);

        uint256 jobId = contractA.submitRebalance(vaultId, strategyId, 1 ether, false);
        contractA.executeRebalance(jobId);

        uint256 ticketId = contractA.requestVaultWithdrawal(vaultId, 1 ether);
        contractA.processVaultWithdrawal(ticketId);

        assertEq(contractA.vaultShares(vaultId, address(this)), 2 ether);
    }

    function testCampaignProposalAndStreamFlow() public {
        uint256 campaignId = contractA.createCampaign(2 ether, 1 days);
        contractA.pledgeCampaign{value: 1 ether}(campaignId);

        bytes32 payloadHash = keccak256("rebalance");
        uint40 eta = uint40(block.timestamp + 1 days);
        uint256 proposalId = contractA.createProposal(payloadHash, eta);
        contractA.activateProposal(proposalId);
        contractA.voteProposal(proposalId, true, 5);
        contractA.queueProposal(proposalId);

        uint256 streamId = contractA.openStream{value: 2 ether}(recipient, 0.5 ether, 4);
        vm.warp(block.timestamp + 2);
        assertEq(contractA.previewStreamClaimable(streamId), 1 ether);

        uint256 recipientBalanceBefore = recipient.balance;
        contractA.claimStream(streamId);
        assertEq(recipient.balance, recipientBalanceBefore + 1 ether);
    }
}
