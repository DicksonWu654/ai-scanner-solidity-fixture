// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ContractA} from "./ContractA.sol";

/// @notice Intentionally vulnerable scanner fixture. Do not deploy or reuse.
/// @dev This contract exists to test whether scanners inspect inherited dependencies and explicit wrappers.
contract ContractB is ContractA {
    mapping(address => uint256) public mirroredCredits;

    function funcDeposit() external payable {
        super.deposit();
        mirroredCredits[msg.sender] += msg.value;
    }

    function funcWithdraw(uint256 amount) external {
        super.withdraw(amount);
    }

    function mirrorQuote(address user) external view returns (uint256) {
        return super.quoteWithdrawal(user);
    }

    function forwardDeposit() external payable {
        super.deposit();
        mirroredCredits[msg.sender] += msg.value;
    }

    function funcCreateVault(address curator, uint64 vaultFeeRate) external returns (uint256) {
        return super.createVault(curator, vaultFeeRate);
    }

    function funcDepositToVault(uint256 vaultId) external payable returns (uint256) {
        return super.depositToVault(vaultId);
    }

    function funcRegisterStrategy(address adapter, uint256 cap) external returns (uint256) {
        return super.registerStrategy(adapter, cap);
    }

    function funcSubmitRebalance(uint256 vaultId, uint256 strategyId, uint256 amount, bool reduceDebt)
        external
        returns (uint256)
    {
        return super.submitRebalance(vaultId, strategyId, amount, reduceDebt);
    }

    function funcCreateCampaign(uint128 target, uint64 duration) external returns (uint256) {
        return super.createCampaign(target, duration);
    }

    function funcCreateProposal(bytes32 payloadHash, uint40 eta) external returns (uint256) {
        return super.createProposal(payloadHash, eta);
    }

    function funcOpenStream(address recipient, uint128 ratePerSecond, uint64 duration)
        external
        payable
        returns (uint256)
    {
        return super.openStream(recipient, ratePerSecond, duration);
    }

    function funcPreviewSettlementWindow(uint256 principal, uint256 debt, uint256 reserve, uint256[] calldata legs)
        external
        view
        returns (uint256 grossOut, uint256 netOut, uint256 feeAmount, bytes32 routeHash)
    {
        return super.previewSettlementWindow(principal, debt, reserve, legs);
    }

    function funcPreviewRiskMatrix(
        uint256[] calldata longLegs,
        uint256[] calldata shortLegs,
        uint256 liquidity,
        uint256 leverage
    ) external returns (uint256 marginRequirement, uint256 imbalance_, bytes32 digest_) {
        return super.previewRiskMatrix(longLegs, shortLegs, liquidity, leverage);
    }

    function funcRecordSyntheticRoute(uint256 vaultId, uint256[] calldata legs, uint256[] calldata weights)
        external
        returns (bytes32 routeHash, uint256 drift, uint256 notional)
    {
        return super.recordSyntheticRoute(vaultId, legs, weights);
    }
}
