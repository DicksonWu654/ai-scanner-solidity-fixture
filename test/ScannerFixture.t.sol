// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ContractB} from "../src/ContractB.sol";

contract ScannerFixtureTest is Test {
    ContractB internal contractB;
    address internal recipient = address(0xBEEF);

    receive() external payable {}

    function setUp() public {
        vm.deal(address(this), 100 ether);
        contractB = new ContractB();
    }

    function testDirectDepositAndQuote() public {
        contractB.funcDeposit{value: 2 ether}();

        uint256 expectedFee = (2 ether * contractB.feeBps()) / 10_000;
        assertEq(contractB.mirrorQuote(address(this)), 2 ether - expectedFee);
    }

    function testForwardDepositCreditsContractB() public {
        contractB.forwardDeposit{value: 1 ether}();

        assertEq(contractB.balances(address(this)), 1 ether);
        assertEq(contractB.mirroredCredits(address(this)), 1 ether);
    }

    function testVaultStrategyAndWithdrawalFlow() public {
        uint256 vaultId = contractB.funcCreateVault(address(this), 150);
        uint256 mintedShares = contractB.funcDepositToVault{value: 3 ether}(vaultId);
        assertEq(mintedShares, 3 ether);
        assertEq(contractB.vaultShares(vaultId, address(this)), 3 ether);

        contractB.accrueVaultYield{value: 1 ether}(vaultId);
        contractB.harvestVaultYield(vaultId);

        uint256 strategyId = contractB.funcRegisterStrategy(address(0xCAFE), 10 ether);
        contractB.attachStrategy(vaultId, strategyId);

        uint256 jobId = contractB.funcSubmitRebalance(vaultId, strategyId, 1 ether, false);
        contractB.executeRebalance(jobId);

        uint256 ticketId = contractB.requestVaultWithdrawal(vaultId, 1 ether);
        contractB.processVaultWithdrawal(ticketId);

        assertEq(contractB.vaultShares(vaultId, address(this)), 2 ether);
    }

    function testCampaignProposalAndStreamFlow() public {
        uint256 campaignId = contractB.funcCreateCampaign(2 ether, 1 days);
        contractB.pledgeCampaign{value: 1 ether}(campaignId);

        bytes32 payloadHash = keccak256("rebalance");
        uint40 eta = uint40(block.timestamp + 1 days);
        uint256 proposalId = contractB.funcCreateProposal(payloadHash, eta);
        contractB.activateProposal(proposalId);
        contractB.voteProposal(proposalId, true, 5);
        contractB.queueProposal(proposalId);

        uint256 streamId = contractB.funcOpenStream{value: 2 ether}(recipient, 0.5 ether, 4);
        vm.warp(block.timestamp + 2);
        assertEq(contractB.previewStreamClaimable(streamId), 1 ether);

        uint256 recipientBalanceBefore = recipient.balance;
        contractB.claimStream(streamId);
        assertEq(recipient.balance, recipientBalanceBefore + 1 ether);
    }

    function testImportedMathWrappers() public {
        uint256 vaultId = contractB.funcCreateVault(address(this), 90);

        uint256[] memory previewLegs = new uint256[](3);
        previewLegs[0] = 2 ether;
        previewLegs[1] = 1 ether;
        previewLegs[2] = 0.5 ether;

        (uint256 grossOut, uint256 netOut, uint256 feeAmount, bytes32 routeHash) =
            contractB.funcPreviewSettlementWindow(5 ether, 1 ether, 2 ether, previewLegs);
        assertGt(grossOut, netOut);
        assertGt(feeAmount, 0);
        assertTrue(routeHash != bytes32(0));

        uint256[] memory weights = new uint256[](3);
        weights[0] = 3;
        weights[1] = 2;
        weights[2] = 1;
        (, uint256 drift, uint256 notional) = contractB.funcRecordSyntheticRoute(vaultId, previewLegs, weights);
        assertGt(drift, 0);
        assertGt(notional, 0);

        uint256[] memory shortLegs = new uint256[](2);
        shortLegs[0] = 0.5 ether;
        shortLegs[1] = 0.25 ether;
        (uint256 marginRequirement, uint256 imbalance_, bytes32 digest_) =
            contractB.funcPreviewRiskMatrix(previewLegs, shortLegs, 10 ether, 2);
        assertGt(marginRequirement, 0);
        assertGt(imbalance_, 0);
        assertTrue(digest_ != bytes32(0));
    }
}
