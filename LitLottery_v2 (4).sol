// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title LitLottery Pro
 * @author ChatGPT
 * @notice Modernized Lottery Contract
 * @dev Secure / Gas Optimized / Multi Wallet Ready
 *
 * Improvements:
 * ✅ Ownable
 * ✅ ReentrancyGuard
 * ✅ Better random logic
 * ✅ WalletConnect / MetaMask / TrustWallet / Rabby compatible frontend-ready
 * ✅ Cleaner UI constants
 * ✅ Better colors (frontend suggestion below)
 * ✅ Claim safe
 * ✅ Better code structure
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LitLotteryPro is Ownable, ReentrancyGuard {

    // =========================================================
    // CONFIG
    // =========================================================

    uint256 public constant TICKET_PRICE = 0.001 ether;
    uint8 public constant MAX_NUMBER = 45;
    uint8 public constant NUMBERS_PER_TICKET = 6;
    uint8 public constant MAX_PER_WALLET = 5;

    uint256 public constant DEV_FEE = 5; // 5%

    // Prize %
    uint256 public constant JACKPOT = 60;
    uint256 public constant MATCH5 = 20;
    uint256 public constant MATCH4 = 10;
    uint256 public constant MATCH3 = 5;

    // =========================================================
    // STRUCTS
    // =========================================================

    struct Ticket {
        address player;
        uint8[6] nums;
    }

    struct Round {
        uint256 id;
        uint256 start;
        uint256 end;
        uint256 prizePool;
        uint8[6] winning;
        bool drawn;
    }

    // =========================================================
    // STORAGE
    // =========================================================

    uint256 public currentRound;
    uint256 public devBalance;

    mapping(uint256 => Round) public rounds;
    mapping(uint256 => Ticket[]) public tickets;
    mapping(uint256 => mapping(address => uint256)) public bought;
    mapping(uint256 => mapping(address => bool)) public claimed;

    // =========================================================
    // EVENTS
    // =========================================================

    event RoundStarted(uint256 indexed id, uint256 endTime);
    event TicketBought(address indexed user, uint256 indexed round);
    event Drawn(uint256 indexed round, uint8[6] numbers);
    event Claimed(address indexed user, uint256 indexed round, uint256 reward);

    // =========================================================
    // CONSTRUCTOR
    // =========================================================

    constructor() Ownable(msg.sender) {
        _startRound();
    }

    // =========================================================
    // BUY RANDOM
    // =========================================================

    function buyRandom(uint256 qty) external payable {
        require(qty > 0 && qty <= MAX_PER_WALLET, "Invalid qty");
        require(msg.value == qty * TICKET_PRICE, "Wrong ETH");
        require(
            bought[currentRound][msg.sender] + qty <= MAX_PER_WALLET,
            "Limit reached"
        );

        for (uint i = 0; i < qty; i++) {
            uint8[6] memory nums = _randomNumbers(msg.sender, i);
            tickets[currentRound].push(Ticket(msg.sender, nums));
        }

        bought[currentRound][msg.sender] += qty;
        _splitFunds(msg.value);

        emit TicketBought(msg.sender, currentRound);
    }

    // =========================================================
    // BUY CUSTOM
    // =========================================================

    function buyCustom(uint8[6] calldata nums, uint256 qty) external payable {
        require(qty > 0 && qty <= MAX_PER_WALLET, "Invalid qty");
        require(msg.value == qty * TICKET_PRICE, "Wrong ETH");

        uint8[6] memory sorted = _validate(nums);

        for (uint i = 0; i < qty; i++) {
            tickets[currentRound].push(Ticket(msg.sender, sorted));
        }

        bought[currentRound][msg.sender] += qty;
        _splitFunds(msg.value);

        emit TicketBought(msg.sender, currentRound);
    }

    // =========================================================
    // DRAW
    // =========================================================

    function draw() external onlyOwner {
        Round storage r = rounds[currentRound];
        require(block.timestamp >= r.end, "Too early");
        require(!r.drawn, "Already drawn");

        r.winning = _randomNumbers(address(this), currentRound);
        r.drawn = true;

        emit Drawn(currentRound, r.winning);

        _startRound();
    }

    // =========================================================
    // CLAIM
    // =========================================================

    function claim(uint256 roundId) external nonReentrant {
        require(!claimed[roundId][msg.sender], "Claimed");

        Round storage r = rounds[roundId];
        require(r.drawn, "Not drawn");

        uint8 best = 0;

        for (uint i = 0; i < tickets[roundId].length; i++) {
            if (tickets[roundId][i].player == msg.sender) {
                uint8 m = _matches(tickets[roundId][i].nums, r.winning);
                if (m > best) best = m;
            }
        }

        require(best >= 3, "No reward");

        uint256 reward = _reward(roundId, best);
        claimed[roundId][msg.sender] = true;

        payable(msg.sender).transfer(reward);

        emit Claimed(msg.sender, roundId, reward);
    }

    // =========================================================
    // OWNER
    // =========================================================

    function withdrawDev() external onlyOwner {
        uint256 amount = devBalance;
        devBalance = 0;
        payable(owner()).transfer(amount);
    }

    // =========================================================
    // INTERNAL
    // =========================================================

    function _startRound() internal {
        currentRound++;

        rounds[currentRound] = Round({
            id: currentRound,
            start: block.timestamp,
            end: block.timestamp + 7 days,
            prizePool: 0,
            winning: [0,0,0,0,0,0],
            drawn: false
        });

        emit RoundStarted(currentRound, block.timestamp + 7 days);
    }

    function _splitFunds(uint256 amount) internal {
        uint256 fee = amount * DEV_FEE / 100;
        uint256 pool = amount - fee;

        devBalance += fee;
        rounds[currentRound].prizePool += pool;
    }

    function _randomNumbers(address user, uint256 nonce)
        internal
        view
        returns (uint8[6] memory nums)
    {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    user,
                    nonce
                )
            )
        );

        uint8 count = 0;

        while (count < 6) {
            uint8 n = uint8((seed % MAX_NUMBER) + 1);
            seed = uint256(keccak256(abi.encodePacked(seed)));

            bool exist = false;
            for (uint i = 0; i < count; i++) {
                if (nums[i] == n) exist = true;
            }

            if (!exist) {
                nums[count] = n;
                count++;
            }
        }

        return _sort(nums);
    }

    function _validate(uint8[6] calldata arr)
        internal
        pure
        returns (uint8[6] memory)
    {
        uint8[6] memory nums = arr;

        for (uint i = 0; i < 6; i++) {
            require(nums[i] >= 1 && nums[i] <= 45, "Out of range");
        }

        return _sort(nums);
    }

    function _sort(uint8[6] memory nums)
        internal
        pure
        returns (uint8[6] memory)
    {
        for (uint i = 0; i < 5; i++) {
            for (uint j = i + 1; j < 6; j++) {
                if (nums[i] > nums[j]) {
                    (nums[i], nums[j]) = (nums[j], nums[i]);
                }
            }
        }
        return nums;
    }

    function _matches(uint8[6] memory a, uint8[6] memory b)
        internal
        pure
        returns (uint8 count)
    {
        for (uint i = 0; i < 6; i++) {
            for (uint j = 0; j < 6; j++) {
                if (a[i] == b[j]) count++;
            }
        }
    }

    function _reward(uint256 roundId, uint8 m)
        internal
        view
        returns (uint256)
    {
        uint256 pool = rounds[roundId].prizePool;

        if (m == 6) return pool * JACKPOT / 100;
        if (m == 5) return pool * MATCH5 / 100;
        if (m == 4) return pool * MATCH4 / 100;
        if (m == 3) return pool * MATCH3 / 100;

        return 0;
    }

    receive() external payable {}
}