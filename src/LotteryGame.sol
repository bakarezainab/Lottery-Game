// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title LotteryGame
 * @dev A simple number guessing game where players can win ETH prizes
 */
contract LotteryGame {
    struct Player {
        uint256 attempts;
        bool active;
    }

    // TODO: Declare state variables
    // - Mapping for player information
    mapping(address => Player) public players;
    // - Array to track player addresses
    address[] public playerAddresses;
    // - Total prize pool
    uint256 public totalPrize;
    // - Array for winners
    address[] public winners;
    // - Array for previous winners
    address[] public previousWinners;
    // - Constants for game configuration
    uint256 public constant ENTRY_FEE = 0.02 ether;
    uint256 public constant MAX_ATTEMPTS = 2;
    uint256 public constant MIN_GUESS = 1;
    uint256 public constant MAX_GUESS = 9;

    // TODO: Declare events
    // - PlayerRegistered
    event PlayerRegistered(address indexed player, uint256 timestamp);
    // - GuessResult
    event GuessResult(address indexed player, uint256 guess, uint256 randomNumber, bool won);
    // - PrizesDistributed
    event PrizesDistributed(uint256 totalAmount, uint256 winnersCount);

    /**
     * @dev Register to play the game
     * Players must stake exactly 0.02 ETH to participate
     */
    function register() public payable {
        // TODO: Implement registration logic
        // - Verify correct payment amount
        require(msg.value == ENTRY_FEE, "Please stake 0.02 ETH");
        require(!players[msg.sender].active, "Already registered");
        // - Add player to mapping
        players[msg.sender] = Player({
            attempts: 0,
            active: true
        });
        // - Add player address to array
        playerAddresses.push(msg.sender);
        // - Update total prize
        totalPrize += msg.value;
        // - Emit registration event
        emit PlayerRegistered(msg.sender, block.timestamp);
    }

    /**
     * @dev Make a guess between 1 and 9
     * @param guess The player's guess
     */
    function guessNumber(uint256 guess) public {
        // TODO: Implement guessing logic
        // - Validate guess is between 1 and 9
        require(guess >= MIN_GUESS && guess <= MAX_GUESS, "Number must be between 1 and 9");
        // - Check player is registered and has attempts left
        require(players[msg.sender].active, "Player not registered");
        require(players[msg.sender].attempts < MAX_ATTEMPTS, "No attempts left");
        // - Generate "random" number
        uint256 randomNumber = _generateRandomNumber();
        // - Compare guess with random number
        bool won = guess == randomNumber;
        // - Update player attempts
        players[msg.sender].attempts++;
        if (won) {
            // - Add to winners array
            winners.push(msg.sender);
        }
        // - Emit guess result event
        emit GuessResult(msg.sender, guess, randomNumber, won);
    }

    /**
     * @dev Distribute prizes to winners
     */
    function distributePrizes() public {
        // TODO: Implement prize distribution logic
        require(winners.length > 0, "No winners");
        require(totalPrize > 0, "No prize pool");
        // - Calculate prize amount per winner
        uint256 prizeAmount = totalPrize / winners.length;
        uint256 distributedAmount = 0;
        // - Transfer prizes to winners
        for (uint256 i = 0; i < winners.length; i++) {
            payable(winners[i]).transfer(prizeAmount);
            distributedAmount += prizeAmount;
        }
        // - Update previous winners list
        previousWinners = winners;
        // - Reset game state
        totalPrize = 0;
        delete winners;
        // - Emit event
        emit PrizesDistributed(distributedAmount, winners.length);
    }

    /**
     * @dev View function to get previous winners
     * @return Array of previous winner addresses
     */
    function getPrevWinners() public view returns (address[] memory) {
        // TODO: Return previous winners array
        return previousWinners;
    }

    /**
     * @dev Helper function to generate a "random" number
     * @return A uint between 1 and 9
     * NOTE: This is not secure for production use!
     */
    function _generateRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            msg.sender,
            block.number
        ))) % MAX_GUESS + MIN_GUESS;
    }
}