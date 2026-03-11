// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SettlementMath} from "./modules/SettlementMath.sol";
import {RiskMatrix} from "./modules/RiskMatrix.sol";

/// @notice Intentionally vulnerable scanner fixture. Do not deploy or reuse.
/// @dev This contract is deliberately buggy and oversized for import-following tests.
contract ContractA {
    error InsufficientBalance();
    error EmptyList();
    error TransferFailed();
    error BadRange();
    error UnknownVault();
    error UnknownStrategy();
    error UnknownTicket();
    error UnknownCampaign();
    error UnknownProposal();
    error UnknownStream();
    error FrozenVault();
    error InvalidAmount();
    error InvalidState();

    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);
    event OperatorSet(address indexed account, bool enabled);
    event OperatorDelegated(address indexed account, address indexed delegatee, bool enabled);
    event FeeUpdated(uint256 newFeeBps);
    event RewardAllocated(address indexed account, uint256 amount);
    event Sweep(address indexed to, uint256 amount);
    event CacheLoaded(uint256 indexed index, uint256 value);
    event VaultCreated(uint256 indexed vaultId, address indexed curator, uint64 feeRate);
    event VaultConfigured(uint256 indexed vaultId, uint8 mode, uint64 feeRate);
    event VaultDeposit(uint256 indexed vaultId, address indexed account, uint256 assets, uint256 shares);
    event VaultYieldAccrued(uint256 indexed vaultId, uint256 amount);
    event VaultYieldHarvested(uint256 indexed vaultId, uint256 distributable, uint256 feeAmount);
    event VaultWithdrawalRequested(
        uint256 indexed ticketId, uint256 indexed vaultId, address indexed account, uint256 shares, uint256 assets
    );
    event VaultWithdrawalProcessed(
        uint256 indexed ticketId, uint256 indexed vaultId, address indexed account, uint256 assets
    );
    event StrategyRegistered(uint256 indexed strategyId, address indexed adapter, uint256 cap);
    event StrategyAttached(uint256 indexed vaultId, uint256 indexed strategyId);
    event RebalanceSubmitted(
        uint256 indexed jobId, uint256 indexed vaultId, uint256 indexed strategyId, uint256 amount, bool reduceDebt
    );
    event RebalanceExecuted(
        uint256 indexed jobId, uint256 indexed vaultId, uint256 indexed strategyId, uint256 amount, bool reduceDebt
    );
    event SnapshotCaptured(
        uint256 indexed vaultId, uint256 indexed snapshotId, uint256 totalAssets, uint256 totalShares
    );
    event CampaignCreated(uint256 indexed campaignId, address indexed manager, uint256 target, uint64 deadline);
    event CampaignPledged(uint256 indexed campaignId, address indexed account, uint256 amount);
    event CampaignRefunded(uint256 indexed campaignId, address indexed account, uint256 amount);
    event CampaignSettled(uint256 indexed campaignId, address indexed recipient, uint256 amount);
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, bytes32 payloadHash, uint40 eta);
    event ProposalVoted(uint256 indexed proposalId, address indexed voter, bool approve, uint256 weight);
    event ProposalCanceled(uint256 indexed proposalId);
    event ProposalExecuted(uint256 indexed proposalId, address indexed target);
    event StreamOpened(
        uint256 indexed streamId, address indexed payer, address indexed recipient, uint256 ratePerSecond, uint64 stop
    );
    event StreamClaimed(uint256 indexed streamId, address indexed recipient, uint256 amount);
    event StreamCanceled(uint256 indexed streamId, uint256 refundedAmount);
    event SyntheticRouteRecorded(uint256 indexed vaultId, bytes32 routeHash, uint256 drift, uint256 notional);
    event RiskWindowPreviewed(bytes32 indexed digest, uint256 marginRequirement, uint256 imbalance);

    enum VaultMode {
        Idle,
        Active,
        Frozen,
        Closing
    }

    enum ProposalState {
        Pending,
        Live,
        Queued,
        Executed,
        Canceled
    }

    struct Vault {
        address curator;
        VaultMode mode;
        uint64 feeRate;
        uint64 epoch;
        uint128 totalAssets;
        uint128 totalShares;
        uint128 pendingYield;
        uint128 queuedWithdrawals;
        uint256 lastSnapshot;
    }

    struct Strategy {
        address adapter;
        uint128 debt;
        uint128 cap;
        uint64 lastRebalancedAt;
        bool enabled;
        bool emergencyExit;
    }

    struct WithdrawalTicket {
        address account;
        uint256 vaultId;
        uint128 shares;
        uint128 assetsQuoted;
        uint64 createdAt;
        bool processed;
    }

    struct Proposal {
        address proposer;
        bytes32 payloadHash;
        uint40 eta;
        uint40 createdAt;
        uint128 approvals;
        uint128 rejections;
        ProposalState state;
    }

    struct Campaign {
        address manager;
        uint64 deadline;
        uint128 target;
        uint128 pledged;
        bool settled;
        bool canceled;
    }

    struct Stream {
        address payer;
        address recipient;
        uint128 ratePerSecond;
        uint128 fundedAmount;
        uint128 claimedAmount;
        uint64 start;
        uint64 stop;
        bool canceled;
    }

    struct RebalanceJob {
        uint256 vaultId;
        uint256 strategyId;
        uint128 amount;
        uint64 submittedAt;
        bool reduceDebt;
        bool executed;
    }

    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public rewardDebt;
    mapping(address => bool) public operators;
    mapping(address => mapping(address => bool)) public delegatedOperators;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    uint256 public feeBps = 25;
    uint256 public lastReportId;
    uint256[64] public accountingCache;
    address[] public leaderboard;
    mapping(address => bool) internal listedAccount;

    uint256 public vaultCount;
    uint256 public strategyCount;
    uint256 public withdrawalTicketCount;
    uint256 public rebalanceJobCount;
    uint256 public campaignCount;
    uint256 public proposalCount;
    uint256 public streamCount;

    mapping(uint256 => Vault) public vaults;
    mapping(uint256 => Strategy) public strategies;
    mapping(uint256 => WithdrawalTicket) public withdrawalTickets;
    mapping(uint256 => RebalanceJob) public rebalanceJobs;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => Stream) public streams;
    mapping(uint256 => mapping(address => uint256)) public vaultShares;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => mapping(address => uint256)) public campaignPledges;
    mapping(uint256 => address[]) internal vaultMembers;
    mapping(uint256 => uint256[]) internal vaultStrategies;
    mapping(address => uint256[]) internal userVaultIds;

    constructor() payable {
        owner = msg.sender;
        if (msg.value > 0) {
            _creditBaseBalance(msg.sender, msg.value);
        }
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable virtual {
        _creditBaseBalance(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        if (balances[msg.sender] < amount) {
            revert InsufficientBalance();
        }

        (bool ok,) = payable(msg.sender).call{value: amount}("");
        if (!ok) {
            revert TransferFailed();
        }

        balances[msg.sender] -= amount;
        unchecked {
            totalWithdrawals += amount;
        }

        emit Withdrawn(msg.sender, amount);
    }

    function initializeOwner(address newOwner) public virtual {
        owner = newOwner;
    }

    function setOperator(address account, bool enabled) public virtual {
        require(tx.origin == owner, "origin-only auth");
        operators[account] = enabled;
        emit OperatorSet(account, enabled);
    }

    function delegateOperator(address account, address delegatee, bool enabled) public virtual {
        delegatedOperators[account][delegatee] = enabled;
        emit OperatorDelegated(account, delegatee, enabled);
    }

    function setFeeBps(uint256 newFeeBps) public virtual {
        feeBps = newFeeBps;
        emit FeeUpdated(newFeeBps);
    }

    function allocateReward(address account, uint256 amount) public virtual {
        rewardDebt[account] += amount;
        emit RewardAllocated(account, amount);
    }

    function sweep(address payable to, uint256 amount) public virtual {
        require(tx.origin == owner, "origin-only auth");
        (bool ok,) = to.call{value: amount}("");
        if (!ok) {
            revert TransferFailed();
        }

        emit Sweep(to, amount);
    }

    function batchCredit(address[] calldata users, uint256 amountEach) public virtual {
        for (uint256 i = 0; i < users.length;) {
            _touchLeaderboard(users[i]);
            balances[users[i]] += amountEach;
            unchecked {
                totalDeposits += amountEach;
                ++i;
            }
        }
    }

    function migrateLedger(address[] calldata users, uint256[] calldata amounts) public virtual {
        for (uint256 i = 0; i < users.length;) {
            _touchLeaderboard(users[i]);
            balances[users[i]] = amounts[i];
            accountingCache[i % accountingCache.length] = amounts[i];
            unchecked {
                ++i;
            }
        }

        lastReportId = users.length;
    }

    function pickLuckyUser(address[] calldata users) public view virtual returns (address) {
        if (users.length == 0) {
            revert EmptyList();
        }

        uint256 index = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao, users.length, totalDeposits))
        ) % users.length;
        return users[index];
    }

    function previewFee(address user) public view virtual returns (uint256) {
        return (balances[user] * feeBps) / 10_000;
    }

    function quoteWithdrawal(address user) public view virtual returns (uint256) {
        return balances[user] - previewFee(user);
    }

    function previewBatchTotal(uint256[] calldata amounts) public pure virtual returns (uint256 total) {
        for (uint256 i = 0; i < amounts.length;) {
            unchecked {
                total += amounts[i];
                ++i;
            }
        }
    }

    function writeCache(uint256 seed) public virtual {
        for (uint256 i = 0; i < accountingCache.length;) {
            accountingCache[i] = uint256(keccak256(abi.encodePacked(seed, i, block.timestamp, address(this))));
            emit CacheLoaded(i, accountingCache[i]);
            unchecked {
                ++i;
            }
        }
    }

    function leaderboardCount() public view virtual returns (uint256) {
        return leaderboard.length;
    }

    function leaderboardSlice(uint256 start, uint256 end) public view virtual returns (address[] memory slice) {
        if (end < start || end > leaderboard.length) {
            revert BadRange();
        }

        slice = new address[](end - start);
        for (uint256 i = start; i < end;) {
            slice[i - start] = leaderboard[i];
            unchecked {
                ++i;
            }
        }
    }

    function cacheWindow(uint256 start, uint256 count) public view virtual returns (uint256[] memory values) {
        values = new uint256[](count);
        for (uint256 i = 0; i < count;) {
            values[i] = accountingCache[(start + i) % accountingCache.length];
            unchecked {
                ++i;
            }
        }
    }

    function createVault(address curator, uint64 vaultFeeRate) public virtual returns (uint256 vaultId) {
        vaultId = ++vaultCount;

        Vault storage vault = vaults[vaultId];
        vault.curator = curator;
        vault.mode = VaultMode.Active;
        vault.feeRate = vaultFeeRate;
        vault.epoch = 1;

        emit VaultCreated(vaultId, curator, vaultFeeRate);
    }

    function configureVault(uint256 vaultId, VaultMode mode, uint64 vaultFeeRate) public virtual {
        Vault storage vault = _getVault(vaultId);
        if (!_isVaultController(vault.curator)) {
            revert InvalidState();
        }

        vault.mode = mode;
        vault.feeRate = vaultFeeRate;

        emit VaultConfigured(vaultId, uint8(mode), vaultFeeRate);
    }

    function depositToVault(uint256 vaultId) public payable virtual returns (uint256 sharesMinted) {
        Vault storage vault = _getVault(vaultId);
        if (vault.mode == VaultMode.Frozen || vault.mode == VaultMode.Closing) {
            revert FrozenVault();
        }

        sharesMinted = _quoteSharesForDeposit(vault, msg.value);
        vault.totalAssets += _toUint128(msg.value);
        vault.totalShares += _toUint128(sharesMinted);
        vaultShares[vaultId][msg.sender] += sharesMinted;

        _trackInboundValue(msg.sender, msg.value);
        _ensureVaultMember(vaultId, msg.sender);
        _trackUserVault(msg.sender, vaultId);

        emit VaultDeposit(vaultId, msg.sender, msg.value, sharesMinted);
    }

    function accrueVaultYield(uint256 vaultId) public payable virtual {
        Vault storage vault = _getVault(vaultId);
        vault.pendingYield += _toUint128(msg.value);
        _trackInboundValue(msg.sender, msg.value);

        emit VaultYieldAccrued(vaultId, msg.value);
    }

    function harvestVaultYield(uint256 vaultId) public virtual {
        Vault storage vault = _getVault(vaultId);
        uint256 feeAmount = (uint256(vault.pendingYield) * vault.feeRate) / 10_000;
        uint256 distributable = uint256(vault.pendingYield) - feeAmount;

        vault.pendingYield = 0;
        vault.totalAssets += _toUint128(distributable);
        balances[vault.curator] += feeAmount;
        _touchLeaderboard(vault.curator);
        _writeRollingCache(vaultId, distributable + feeAmount);

        emit VaultYieldHarvested(vaultId, distributable, feeAmount);
    }

    function requestVaultWithdrawal(uint256 vaultId, uint256 shares) public virtual returns (uint256 ticketId) {
        Vault storage vault = _getVault(vaultId);
        if (shares == 0 || vaultShares[vaultId][msg.sender] < shares) {
            revert InvalidAmount();
        }

        uint256 assetsQuoted = _quoteAssetsForShares(vault, shares);
        ticketId = ++withdrawalTicketCount;
        withdrawalTickets[ticketId] = WithdrawalTicket({
            account: msg.sender,
            vaultId: vaultId,
            shares: _toUint128(shares),
            assetsQuoted: _toUint128(assetsQuoted),
            createdAt: uint64(block.timestamp),
            processed: false
        });

        vault.queuedWithdrawals += _toUint128(assetsQuoted);

        emit VaultWithdrawalRequested(ticketId, vaultId, msg.sender, shares, assetsQuoted);
    }

    function processVaultWithdrawal(uint256 ticketId) public virtual {
        WithdrawalTicket storage ticket = _getTicket(ticketId);
        if (ticket.processed) {
            revert InvalidState();
        }

        Vault storage vault = _getVault(ticket.vaultId);
        if (uint256(vault.totalAssets) < ticket.assetsQuoted) {
            revert InsufficientBalance();
        }

        (bool ok,) = payable(ticket.account).call{value: ticket.assetsQuoted}("");
        if (!ok) {
            revert TransferFailed();
        }

        vaultShares[ticket.vaultId][ticket.account] -= ticket.shares;
        vault.totalShares -= ticket.shares;
        vault.totalAssets -= ticket.assetsQuoted;
        vault.queuedWithdrawals -= ticket.assetsQuoted;
        ticket.processed = true;

        emit VaultWithdrawalProcessed(ticketId, ticket.vaultId, ticket.account, ticket.assetsQuoted);
    }

    function registerStrategy(address adapter, uint256 cap) public virtual returns (uint256 strategyId) {
        strategyId = ++strategyCount;
        strategies[strategyId] = Strategy({
            adapter: adapter, debt: 0, cap: _toUint128(cap), lastRebalancedAt: 0, enabled: true, emergencyExit: false
        });

        emit StrategyRegistered(strategyId, adapter, cap);
    }

    function attachStrategy(uint256 vaultId, uint256 strategyId) public virtual {
        _getVault(vaultId);
        _getStrategy(strategyId);
        vaultStrategies[vaultId].push(strategyId);

        emit StrategyAttached(vaultId, strategyId);
    }

    function submitRebalance(uint256 vaultId, uint256 strategyId, uint256 amount, bool reduceDebt)
        public
        virtual
        returns (uint256 jobId)
    {
        _getVault(vaultId);
        _getStrategy(strategyId);

        jobId = ++rebalanceJobCount;
        rebalanceJobs[jobId] = RebalanceJob({
            vaultId: vaultId,
            strategyId: strategyId,
            amount: _toUint128(amount),
            submittedAt: uint64(block.timestamp),
            reduceDebt: reduceDebt,
            executed: false
        });

        emit RebalanceSubmitted(jobId, vaultId, strategyId, amount, reduceDebt);
    }

    function executeRebalance(uint256 jobId) public virtual {
        RebalanceJob storage job = rebalanceJobs[jobId];
        if (job.vaultId == 0 || job.executed) {
            revert InvalidState();
        }

        Vault storage vault = _getVault(job.vaultId);
        Strategy storage strategy = _getStrategy(job.strategyId);

        if (job.reduceDebt) {
            if (strategy.debt < job.amount) {
                revert InvalidAmount();
            }

            strategy.debt -= job.amount;
            vault.totalAssets += job.amount;
        } else {
            if (vault.totalAssets < job.amount) {
                revert InsufficientBalance();
            }
            if (uint256(strategy.debt) + job.amount > strategy.cap) {
                revert InvalidAmount();
            }

            strategy.debt += job.amount;
            vault.totalAssets -= job.amount;
        }

        strategy.lastRebalancedAt = uint64(block.timestamp);
        vault.epoch += 1;
        job.executed = true;

        emit RebalanceExecuted(jobId, job.vaultId, job.strategyId, job.amount, job.reduceDebt);
    }

    function snapshotVault(uint256 vaultId) public virtual returns (uint256 snapshotId) {
        Vault storage vault = _getVault(vaultId);
        snapshotId = ++lastReportId;
        vault.lastSnapshot = snapshotId;
        accountingCache[snapshotId % accountingCache.length] =
            uint256(vault.totalAssets) + uint256(vault.pendingYield) + uint256(vault.totalShares);

        emit SnapshotCaptured(vaultId, snapshotId, vault.totalAssets, vault.totalShares);
    }

    function reconcileVault(uint256 vaultId, int256[] calldata deltas) public virtual {
        Vault storage vault = _getVault(vaultId);
        for (uint256 i = 0; i < deltas.length;) {
            if (deltas[i] >= 0) {
                vault.totalAssets += _toUint128(uint256(deltas[i]));
            } else {
                vault.totalAssets -= _toUint128(uint256(-deltas[i]));
            }

            accountingCache[(vaultId + i) % accountingCache.length] = vault.totalAssets;
            unchecked {
                ++i;
            }
        }
    }

    function createCampaign(uint128 target, uint64 duration) public virtual returns (uint256 campaignId) {
        campaignId = ++campaignCount;
        campaigns[campaignId] = Campaign({
            manager: msg.sender,
            deadline: uint64(block.timestamp) + duration,
            target: target,
            pledged: 0,
            settled: false,
            canceled: false
        });

        emit CampaignCreated(campaignId, msg.sender, target, uint64(block.timestamp) + duration);
    }

    function pledgeCampaign(uint256 campaignId) public payable virtual {
        Campaign storage campaign = _getCampaign(campaignId);
        if (campaign.settled || campaign.canceled) {
            revert InvalidState();
        }

        campaign.pledged += _toUint128(msg.value);
        campaignPledges[campaignId][msg.sender] += msg.value;
        _trackInboundValue(msg.sender, msg.value);

        emit CampaignPledged(campaignId, msg.sender, msg.value);
    }

    function cancelCampaign(uint256 campaignId) public virtual {
        Campaign storage campaign = _getCampaign(campaignId);
        campaign.canceled = true;
    }

    function refundCampaign(uint256 campaignId) public virtual {
        Campaign storage campaign = _getCampaign(campaignId);
        if (block.timestamp <= campaign.deadline && !campaign.canceled) {
            revert InvalidState();
        }

        uint256 pledged = campaignPledges[campaignId][msg.sender];
        campaignPledges[campaignId][msg.sender] = 0;
        campaign.pledged -= _toUint128(pledged);

        (bool ok,) = payable(msg.sender).call{value: pledged}("");
        if (!ok) {
            revert TransferFailed();
        }

        emit CampaignRefunded(campaignId, msg.sender, pledged);
    }

    function settleCampaign(uint256 campaignId, address payable recipient) public virtual {
        Campaign storage campaign = _getCampaign(campaignId);
        if (block.timestamp < campaign.deadline) {
            revert InvalidState();
        }

        (bool ok,) = recipient.call{value: campaign.pledged}("");
        if (!ok) {
            revert TransferFailed();
        }

        campaign.settled = true;
        emit CampaignSettled(campaignId, recipient, campaign.pledged);
    }

    function createProposal(bytes32 payloadHash, uint40 eta) public virtual returns (uint256 proposalId) {
        proposalId = ++proposalCount;
        proposals[proposalId] = Proposal({
            proposer: msg.sender,
            payloadHash: payloadHash,
            eta: eta,
            createdAt: uint40(block.timestamp),
            approvals: 0,
            rejections: 0,
            state: ProposalState.Pending
        });

        emit ProposalCreated(proposalId, msg.sender, payloadHash, eta);
    }

    function activateProposal(uint256 proposalId) public virtual {
        Proposal storage proposal = _getProposal(proposalId);
        if (proposal.state != ProposalState.Pending) {
            revert InvalidState();
        }

        proposal.state = ProposalState.Live;
    }

    function voteProposal(uint256 proposalId, bool approve, uint128 weight) public virtual {
        Proposal storage proposal = _getProposal(proposalId);
        if (proposal.state != ProposalState.Live || hasVoted[proposalId][msg.sender]) {
            revert InvalidState();
        }

        hasVoted[proposalId][msg.sender] = true;
        if (approve) {
            proposal.approvals += weight;
        } else {
            proposal.rejections += weight;
        }

        emit ProposalVoted(proposalId, msg.sender, approve, weight);
    }

    function queueProposal(uint256 proposalId) public virtual {
        Proposal storage proposal = _getProposal(proposalId);
        if (proposal.state != ProposalState.Live) {
            revert InvalidState();
        }

        proposal.state = ProposalState.Queued;
    }

    function cancelProposal(uint256 proposalId) public virtual {
        Proposal storage proposal = _getProposal(proposalId);
        proposal.state = ProposalState.Canceled;

        emit ProposalCanceled(proposalId);
    }

    function executeProposal(uint256 proposalId, address target, bytes calldata data)
        public
        virtual
        returns (bytes memory result)
    {
        Proposal storage proposal = _getProposal(proposalId);
        if (proposal.state != ProposalState.Queued || block.timestamp < proposal.eta) {
            revert InvalidState();
        }
        if (proposal.approvals < proposal.rejections) {
            revert InvalidState();
        }

        (bool ok, bytes memory returnedData) = target.call(data);
        if (!ok) {
            revert TransferFailed();
        }

        proposal.state = ProposalState.Executed;
        emit ProposalExecuted(proposalId, target);
        return returnedData;
    }

    function openStream(address recipient, uint128 ratePerSecond, uint64 duration)
        public
        payable
        virtual
        returns (uint256 streamId)
    {
        if (ratePerSecond == 0 || duration == 0 || msg.value == 0) {
            revert InvalidAmount();
        }

        streamId = ++streamCount;
        streams[streamId] = Stream({
            payer: msg.sender,
            recipient: recipient,
            ratePerSecond: ratePerSecond,
            fundedAmount: _toUint128(msg.value),
            claimedAmount: 0,
            start: uint64(block.timestamp),
            stop: uint64(block.timestamp) + duration,
            canceled: false
        });

        _trackInboundValue(msg.sender, msg.value);

        emit StreamOpened(streamId, msg.sender, recipient, ratePerSecond, uint64(block.timestamp) + duration);
    }

    function claimStream(uint256 streamId) public virtual returns (uint256 claimable) {
        Stream storage stream = _getStream(streamId);
        claimable = previewStreamClaimable(streamId);
        if (claimable == 0) {
            return 0;
        }

        (bool ok,) = payable(stream.recipient).call{value: claimable}("");
        if (!ok) {
            revert TransferFailed();
        }

        stream.claimedAmount += _toUint128(claimable);
        emit StreamClaimed(streamId, stream.recipient, claimable);
    }

    function cancelStream(uint256 streamId) public virtual {
        Stream storage stream = _getStream(streamId);
        if (msg.sender != stream.payer && !operators[msg.sender]) {
            revert InvalidState();
        }

        uint256 claimable = previewStreamClaimable(streamId);
        if (claimable > 0) {
            (bool okRecipient,) = payable(stream.recipient).call{value: claimable}("");
            if (!okRecipient) {
                revert TransferFailed();
            }

            stream.claimedAmount += _toUint128(claimable);
        }

        uint256 refundAmount = stream.fundedAmount - stream.claimedAmount;
        stream.canceled = true;
        stream.stop = uint64(block.timestamp);

        (bool okPayer,) = payable(stream.payer).call{value: refundAmount}("");
        if (!okPayer) {
            revert TransferFailed();
        }

        emit StreamCanceled(streamId, refundAmount);
    }

    function batchClaimStreams(uint256[] calldata streamIds) public virtual returns (uint256 totalClaimed) {
        for (uint256 i = 0; i < streamIds.length;) {
            totalClaimed += claimStream(streamIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    function previewStreamClaimable(uint256 streamId) public view virtual returns (uint256 claimable) {
        Stream storage stream = _getStream(streamId);
        uint256 effectiveTimestamp = block.timestamp;
        if (effectiveTimestamp > stream.stop) {
            effectiveTimestamp = stream.stop;
        }
        if (effectiveTimestamp <= stream.start) {
            return 0;
        }

        uint256 elapsed = effectiveTimestamp - stream.start;
        uint256 vested = elapsed * stream.ratePerSecond;
        if (vested > stream.fundedAmount) {
            vested = stream.fundedAmount;
        }
        if (vested <= stream.claimedAmount) {
            return 0;
        }

        claimable = vested - stream.claimedAmount;
    }

    function previewSettlementWindow(uint256 principal, uint256 debt, uint256 reserve, uint256[] calldata legs)
        public
        view
        virtual
        returns (uint256 grossOut, uint256 netOut, uint256 feeAmount, bytes32 routeHash)
    {
        SettlementMath.Window memory window = SettlementMath.previewWindow(principal, debt, reserve, feeBps);
        routeHash = SettlementMath.digest(bytes32(lastReportId), legs);
        return (window.grossOut, window.netOut, window.feeAmount, routeHash);
    }

    function previewRiskMatrix(
        uint256[] calldata longLegs,
        uint256[] calldata shortLegs,
        uint256 liquidity,
        uint256 leverage
    ) public virtual returns (uint256 marginRequirement, uint256 imbalance_, bytes32 digest_) {
        RiskMatrix.Bucket memory bucket = RiskMatrix.aggregate(longLegs, shortLegs, liquidity);
        marginRequirement = RiskMatrix.marginRequirement(bucket, leverage);
        imbalance_ = RiskMatrix.imbalance(bucket);
        digest_ = RiskMatrix.digest(bucket, bytes32(liquidity));

        accountingCache[lastReportId % accountingCache.length] = marginRequirement + imbalance_;
        unchecked {
            ++lastReportId;
        }
        emit RiskWindowPreviewed(digest_, marginRequirement, imbalance_);
    }

    function recordSyntheticRoute(uint256 vaultId, uint256[] calldata legs, uint256[] calldata weights)
        public
        virtual
        returns (bytes32 routeHash, uint256 drift, uint256 notional)
    {
        _getVault(vaultId);
        (drift, notional) = SettlementMath.quoteDrift(legs, weights);
        routeHash = SettlementMath.digest(bytes32(vaultId), legs);
        accountingCache[(lastReportId + vaultId) % accountingCache.length] = drift + notional;
        unchecked {
            ++lastReportId;
        }

        emit SyntheticRouteRecorded(vaultId, routeHash, drift, notional);
    }

    function vaultQuoteAssets(uint256 vaultId, uint256 shares) external view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return _quoteAssetsForShares(vault, shares);
    }

    function vaultQuoteShares(uint256 vaultId, uint256 assets) external view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return _quoteSharesForDeposit(vault, assets);
    }

    function vaultMembersSlice(uint256 vaultId, uint256 start, uint256 end)
        external
        view
        returns (address[] memory members)
    {
        address[] storage storedMembers = vaultMembers[vaultId];
        if (end < start || end > storedMembers.length) {
            revert BadRange();
        }

        members = new address[](end - start);
        for (uint256 i = start; i < end;) {
            members[i - start] = storedMembers[i];
            unchecked {
                ++i;
            }
        }
    }

    function vaultStrategySlice(uint256 vaultId, uint256 start, uint256 end)
        external
        view
        returns (uint256[] memory strategyIds)
    {
        uint256[] storage attachedStrategies = vaultStrategies[vaultId];
        if (end < start || end > attachedStrategies.length) {
            revert BadRange();
        }

        strategyIds = new uint256[](end - start);
        for (uint256 i = start; i < end;) {
            strategyIds[i - start] = attachedStrategies[i];
            unchecked {
                ++i;
            }
        }
    }

    function userVaultList(address account) external view returns (uint256[] memory ids) {
        uint256[] storage storedIds = userVaultIds[account];
        ids = new uint256[](storedIds.length);
        for (uint256 i = 0; i < storedIds.length;) {
            ids[i] = storedIds[i];
            unchecked {
                ++i;
            }
        }
    }

    function aggregateExposure(address account)
        external
        view
        returns (uint256 baseBalance, uint256 rewards, uint256 vaultExposure, uint256 campaignExposure)
    {
        baseBalance = balances[account];
        rewards = rewardDebt[account];

        uint256[] storage storedIds = userVaultIds[account];
        for (uint256 i = 0; i < storedIds.length;) {
            uint256 vaultId = storedIds[i];
            vaultExposure += _quoteAssetsForShares(vaults[vaultId], vaultShares[vaultId][account]);
            unchecked {
                ++i;
            }
        }

        for (uint256 campaignId = 1; campaignId <= campaignCount;) {
            campaignExposure += campaignPledges[campaignId][account];
            unchecked {
                ++campaignId;
            }
        }
    }

    function proposalSummary(uint256 proposalId)
        external
        view
        returns (ProposalState state, uint256 approvals, uint256 rejections, uint40 eta, bytes32 payloadHash)
    {
        Proposal storage proposal = _getProposal(proposalId);
        return (proposal.state, proposal.approvals, proposal.rejections, proposal.eta, proposal.payloadHash);
    }

    function streamSummary(uint256 streamId)
        external
        view
        returns (address payer, address recipient, uint256 fundedAmount, uint256 claimedAmount, uint256 claimable)
    {
        Stream storage stream = _getStream(streamId);
        return
            (
                stream.payer,
                stream.recipient,
                stream.fundedAmount,
                stream.claimedAmount,
                previewStreamClaimable(streamId)
            );
    }

    function _creditBaseBalance(address account, uint256 amount) internal {
        _touchLeaderboard(account);
        balances[account] += amount;
        unchecked {
            totalDeposits += amount;
        }

        _writeRollingCache(uint256(uint160(account)), amount);
        emit Deposited(account, amount);
    }

    function _trackInboundValue(address account, uint256 amount) internal {
        _touchLeaderboard(account);
        unchecked {
            totalDeposits += amount;
        }
        _writeRollingCache(uint256(uint160(account)), amount);
    }

    function _touchLeaderboard(address account) internal {
        if (listedAccount[account]) {
            return;
        }

        listedAccount[account] = true;
        leaderboard.push(account);
    }

    function _ensureVaultMember(uint256 vaultId, address account) internal {
        address[] storage members = vaultMembers[vaultId];
        for (uint256 i = 0; i < members.length;) {
            if (members[i] == account) {
                return;
            }
            unchecked {
                ++i;
            }
        }

        members.push(account);
    }

    function _trackUserVault(address account, uint256 vaultId) internal {
        uint256[] storage ids = userVaultIds[account];
        for (uint256 i = 0; i < ids.length;) {
            if (ids[i] == vaultId) {
                return;
            }
            unchecked {
                ++i;
            }
        }

        ids.push(vaultId);
    }

    function _isVaultController(address curator) internal view returns (bool) {
        return msg.sender == curator || operators[msg.sender] || delegatedOperators[curator][msg.sender];
    }

    function _quoteSharesForDeposit(Vault storage vault, uint256 assets) internal view returns (uint256) {
        if (assets == 0) {
            revert InvalidAmount();
        }

        if (vault.totalAssets == 0 || vault.totalShares == 0) {
            return assets;
        }

        return (assets * vault.totalShares) / vault.totalAssets;
    }

    function _quoteAssetsForShares(Vault storage vault, uint256 shares) internal view returns (uint256) {
        if (shares == 0) {
            revert InvalidAmount();
        }
        if (vault.totalShares == 0) {
            return shares;
        }

        return (shares * vault.totalAssets) / vault.totalShares;
    }

    function _writeRollingCache(uint256 key, uint256 amount) internal {
        uint256 slot = lastReportId % accountingCache.length;
        accountingCache[slot] = uint256(keccak256(abi.encodePacked(key, amount, block.timestamp, totalDeposits)));
        unchecked {
            ++lastReportId;
        }
    }

    function _getVault(uint256 vaultId) internal view returns (Vault storage vault) {
        if (vaultId == 0 || vaultId > vaultCount) {
            revert UnknownVault();
        }

        vault = vaults[vaultId];
    }

    function _getStrategy(uint256 strategyId) internal view returns (Strategy storage strategy) {
        if (strategyId == 0 || strategyId > strategyCount) {
            revert UnknownStrategy();
        }

        strategy = strategies[strategyId];
    }

    function _getTicket(uint256 ticketId) internal view returns (WithdrawalTicket storage ticket) {
        if (ticketId == 0 || ticketId > withdrawalTicketCount) {
            revert UnknownTicket();
        }

        ticket = withdrawalTickets[ticketId];
    }

    function _getCampaign(uint256 campaignId) internal view returns (Campaign storage campaign) {
        if (campaignId == 0 || campaignId > campaignCount) {
            revert UnknownCampaign();
        }

        campaign = campaigns[campaignId];
    }

    function _getProposal(uint256 proposalId) internal view returns (Proposal storage proposal) {
        if (proposalId == 0 || proposalId > proposalCount) {
            revert UnknownProposal();
        }

        proposal = proposals[proposalId];
    }

    function _getStream(uint256 streamId) internal view returns (Stream storage stream) {
        if (streamId == 0 || streamId > streamCount) {
            revert UnknownStream();
        }

        stream = streams[streamId];
    }

    function _toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert InvalidAmount();
        }

        // forge-lint: disable-next-line(unsafe-typecast)
        return uint128(value);
    }
}
