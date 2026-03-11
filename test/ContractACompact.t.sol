// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ContractACompact} from "../src/ContractACompact.sol";

contract ContractACompactTest is Test {
    ContractACompact internal compact;
    address internal recipient = address(0xCAFE);

    receive() external payable {}

    function setUp() public {
        vm.deal(address(this), 50 ether);
        compact = new ContractACompact();
    }

    function testCompactDepositVaultAndQuote() public {
        compact.deposit{value: 2 ether}();
        uint256 vaultId = compact.createVault(address(this), 200);
        uint256 shares = compact.depositToVault{value: 3 ether}(vaultId);

        assertEq(shares, 3 ether);
        assertEq(compact.vaultShares(vaultId, address(this)), 3 ether);
        assertEq(compact.quoteWithdrawal(address(this)), 2 ether - ((2 ether * compact.feeBps()) / 10_000));
    }

    function testCompactProposalStreamAndDigest() public {
        uint256 proposalId = compact.createProposal(keccak256("compact"));
        compact.voteProposal(proposalId, true, 7);
        compact.queueProposal(proposalId);

        uint256 streamId = compact.openStream{value: 2 ether}(recipient, 0.5 ether, 4);
        vm.warp(block.timestamp + 2);

        uint256 beforeBalance = recipient.balance;
        compact.claimStream(streamId);
        assertEq(recipient.balance, beforeBalance + 1 ether);

        uint256[] memory longs = new uint256[](3);
        longs[0] = 2 ether;
        longs[1] = 1 ether;
        longs[2] = 0.5 ether;
        uint256[] memory shorts = new uint256[](2);
        shorts[0] = 0.4 ether;
        shorts[1] = 0.1 ether;

        (bytes32 digest, uint256 gross, uint256 skew) = compact.riskDigest(longs, shorts);
        assertTrue(digest != bytes32(0));
        assertGt(gross, 0);
        assertGt(skew, 0);
    }
}
