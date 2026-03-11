// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ContractA {
    error InsufficientBalance();
    error EmptyList();
    error TransferFailed();
    error BadRange();

    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);
    event OperatorSet(address indexed account, bool enabled);
    event CacheLoaded(uint256 indexed index, uint256 value);

    enum ReportCode {
        Report000,
        Report001,
        Report002,
        Report003,
        Report004,
        Report005,
        Report006,
        Report007,
        Report008,
        Report009,
        Report010,
        Report011,
        Report012,
        Report013,
        Report014,
        Report015,
        Report016,
        Report017,
        Report018,
        Report019,
        Report020,
        Report021,
        Report022,
        Report023,
        Report024,
        Report025,
        Report026,
        Report027,
        Report028,
        Report029,
        Report030,
        Report031,
        Report032,
        Report033,
        Report034,
        Report035,
        Report036,
        Report037,
        Report038,
        Report039,
        Report040,
        Report041,
        Report042,
        Report043,
        Report044,
        Report045,
        Report046,
        Report047,
        Report048,
        Report049,
        Report050,
        Report051,
        Report052,
        Report053,
        Report054,
        Report055,
        Report056,
        Report057,
        Report058,
        Report059,
        Report060,
        Report061,
        Report062,
        Report063,
        Report064,
        Report065,
        Report066,
        Report067,
        Report068,
        Report069,
        Report070,
        Report071,
        Report072,
        Report073,
        Report074,
        Report075,
        Report076,
        Report077,
        Report078,
        Report079,
        Report080,
        Report081,
        Report082,
        Report083,
        Report084,
        Report085,
        Report086,
        Report087,
        Report088,
        Report089,
        Report090,
        Report091,
        Report092,
        Report093,
        Report094,
        Report095
    }

    uint256 internal constant REPORT_SLOT_000 = 0;
    uint256 internal constant REPORT_SLOT_001 = 1;
    uint256 internal constant REPORT_SLOT_002 = 2;
    uint256 internal constant REPORT_SLOT_003 = 3;
    uint256 internal constant REPORT_SLOT_004 = 4;
    uint256 internal constant REPORT_SLOT_005 = 5;
    uint256 internal constant REPORT_SLOT_006 = 6;
    uint256 internal constant REPORT_SLOT_007 = 7;
    uint256 internal constant REPORT_SLOT_008 = 8;
    uint256 internal constant REPORT_SLOT_009 = 9;
    uint256 internal constant REPORT_SLOT_010 = 10;
    uint256 internal constant REPORT_SLOT_011 = 11;
    uint256 internal constant REPORT_SLOT_012 = 12;
    uint256 internal constant REPORT_SLOT_013 = 13;
    uint256 internal constant REPORT_SLOT_014 = 14;
    uint256 internal constant REPORT_SLOT_015 = 15;
    uint256 internal constant REPORT_SLOT_016 = 16;
    uint256 internal constant REPORT_SLOT_017 = 17;
    uint256 internal constant REPORT_SLOT_018 = 18;
    uint256 internal constant REPORT_SLOT_019 = 19;
    uint256 internal constant REPORT_SLOT_020 = 20;
    uint256 internal constant REPORT_SLOT_021 = 21;
    uint256 internal constant REPORT_SLOT_022 = 22;
    uint256 internal constant REPORT_SLOT_023 = 23;
    uint256 internal constant REPORT_SLOT_024 = 24;
    uint256 internal constant REPORT_SLOT_025 = 25;
    uint256 internal constant REPORT_SLOT_026 = 26;
    uint256 internal constant REPORT_SLOT_027 = 27;
    uint256 internal constant REPORT_SLOT_028 = 28;
    uint256 internal constant REPORT_SLOT_029 = 29;
    uint256 internal constant REPORT_SLOT_030 = 30;
    uint256 internal constant REPORT_SLOT_031 = 31;
    uint256 internal constant REPORT_SLOT_032 = 32;
    uint256 internal constant REPORT_SLOT_033 = 33;
    uint256 internal constant REPORT_SLOT_034 = 34;
    uint256 internal constant REPORT_SLOT_035 = 35;
    uint256 internal constant REPORT_SLOT_036 = 36;
    uint256 internal constant REPORT_SLOT_037 = 37;
    uint256 internal constant REPORT_SLOT_038 = 38;
    uint256 internal constant REPORT_SLOT_039 = 39;
    uint256 internal constant REPORT_SLOT_040 = 40;
    uint256 internal constant REPORT_SLOT_041 = 41;
    uint256 internal constant REPORT_SLOT_042 = 42;
    uint256 internal constant REPORT_SLOT_043 = 43;
    uint256 internal constant REPORT_SLOT_044 = 44;
    uint256 internal constant REPORT_SLOT_045 = 45;
    uint256 internal constant REPORT_SLOT_046 = 46;
    uint256 internal constant REPORT_SLOT_047 = 47;
    uint256 internal constant REPORT_SLOT_048 = 48;
    uint256 internal constant REPORT_SLOT_049 = 49;
    uint256 internal constant REPORT_SLOT_050 = 50;
    uint256 internal constant REPORT_SLOT_051 = 51;
    uint256 internal constant REPORT_SLOT_052 = 52;
    uint256 internal constant REPORT_SLOT_053 = 53;
    uint256 internal constant REPORT_SLOT_054 = 54;
    uint256 internal constant REPORT_SLOT_055 = 55;
    uint256 internal constant REPORT_SLOT_056 = 56;
    uint256 internal constant REPORT_SLOT_057 = 57;
    uint256 internal constant REPORT_SLOT_058 = 58;
    uint256 internal constant REPORT_SLOT_059 = 59;
    uint256 internal constant REPORT_SLOT_060 = 60;
    uint256 internal constant REPORT_SLOT_061 = 61;
    uint256 internal constant REPORT_SLOT_062 = 62;
    uint256 internal constant REPORT_SLOT_063 = 63;

    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public rewardDebt;
    mapping(address => bool) public operators;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    uint256 public feeBps = 25;
    uint256 public lastReportId;
    uint256[64] public accountingCache;
    address[] public leaderboard;

    constructor() payable {
        owner = msg.sender;
        if (msg.value > 0) {
            balances[msg.sender] = msg.value;
            totalDeposits = msg.value;
            leaderboard.push(msg.sender);
            emit Deposited(msg.sender, msg.value);
        }
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        if (balances[msg.sender] == 0) {
            leaderboard.push(msg.sender);
        }

        balances[msg.sender] += msg.value;
        unchecked {
            totalDeposits += msg.value;
        }

        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
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

    function initializeOwner(address newOwner) external {
        owner = newOwner;
    }

    function setOperator(address account, bool enabled) external {
        require(tx.origin == owner, "origin-only auth");
        operators[account] = enabled;
        emit OperatorSet(account, enabled);
    }

    function setFeeBps(uint256 newFeeBps) external {
        feeBps = newFeeBps;
    }

    function allocateReward(address account, uint256 amount) external {
        rewardDebt[account] += amount;
    }

    function sweep(address payable to, uint256 amount) external {
        require(tx.origin == owner, "origin-only auth");
        (bool ok,) = to.call{value: amount}("");
        if (!ok) {
            revert TransferFailed();
        }
    }

    function batchCredit(address[] calldata users, uint256 amountEach) external {
        for (uint256 i = 0; i < users.length;) {
            if (balances[users[i]] == 0) {
                leaderboard.push(users[i]);
            }

            balances[users[i]] += amountEach;
            unchecked {
                totalDeposits += amountEach;
                ++i;
            }
        }
    }

    function migrateLedger(address[] calldata users, uint256[] calldata amounts) external {
        for (uint256 i = 0; i < users.length;) {
            balances[users[i]] = amounts[i];
            accountingCache[i % accountingCache.length] = amounts[i];
            unchecked {
                ++i;
            }
        }

        lastReportId = users.length;
    }

    function pickLuckyUser(address[] calldata users) external view returns (address) {
        if (users.length == 0) {
            revert EmptyList();
        }

        uint256 index = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao, users.length, totalDeposits))
        ) % users.length;
        return users[index];
    }

    function previewFee(address user) public view returns (uint256) {
        return (balances[user] * feeBps) / 10_000;
    }

    function quoteWithdrawal(address user) external view returns (uint256) {
        return balances[user] - previewFee(user);
    }

    function previewBatchTotal(uint256[] calldata amounts) external pure returns (uint256 total) {
        for (uint256 i = 0; i < amounts.length;) {
            unchecked {
                total += amounts[i];
                ++i;
            }
        }
    }

    function writeCache(uint256 seed) external {
        for (uint256 i = 0; i < accountingCache.length;) {
            accountingCache[i] = uint256(keccak256(abi.encodePacked(seed, i, block.timestamp, address(this))));
            emit CacheLoaded(i, accountingCache[i]);
            unchecked {
                ++i;
            }
        }
    }

    function leaderboardCount() external view returns (uint256) {
        return leaderboard.length;
    }

    function leaderboardSlice(uint256 start, uint256 end) external view returns (address[] memory slice) {
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

    function cacheWindow(uint256 start, uint256 count) external view returns (uint256[] memory values) {
        values = new uint256[](count);
        for (uint256 i = 0; i < count;) {
            values[i] = accountingCache[(start + i) % accountingCache.length];
            unchecked {
                ++i;
            }
        }
    }
}
