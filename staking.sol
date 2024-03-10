// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import the ERC20.sol file from the OpenZeppelin library
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Create a new contract named MyToken that extends the ERC20 token standard
contract MyToken is ERC20 {

    // Public mapping to track the amount staked by each address
    mapping(address => uint) public staked;

    // Private mapping to track the timestamp when staking occurred for each address
    mapping(address => uint) private stakedFromTS;

    // Constructor function executed only once during contract deployment
    constructor() ERC20("MyToken", "MTK") {
        // Mint 1000 tokens to the contract deployer (msg.sender)
        _mint(msg.sender, 10 ** 18);
    }

    // External function allowing users to stake a specified amount of tokens
    function stake(uint amount) external {
        // Check if the amount to be staked is greater than 0
        require(amount > 0, "amount is <=0");
        // Check if the user has enough balance to stake the specified amount
        require(balanceOf(msg.sender) >= amount, "balance is <= amount");
        // Transfer the specified amount of tokens from the user to the contract
        _transfer(msg.sender, address(this), amount);

        // If the user has previously staked, call the claim function
        if (staked[msg.sender] > 0) {
            claim();
        }

        // Record the current timestamp and update the staked amount for the user
        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

    // External function allowing users to unstake a specified amount of tokens
    function unstake(uint amount) external {
        // Check if the amount to be unstaked is greater than 0
        require(amount > 0, "amount is <=0");
        // Check if the user has staked before
        require(staked[msg.sender] > 0, "You did not stake with us");
        // Update the staking timestamp and reduce the staked amount for the user
        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] -= amount;
        // Transfer the specified amount of tokens from the contract to the user
        _transfer(address(this), msg.sender, amount);
    }

    // Public function allowing users to claim rewards based on their staked amount and time
    function claim() public {
        // Check if the user has staked tokens
        require(staked[msg.sender] > 0, "Staked is <= 0");
        // Calculate the time duration since the last stake
        uint secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        // Calculate the rewards based on staked amount and time, and mint the rewards to the user
        uint rewards = staked[msg.sender] * secondsStaked / 3.154e7; // 3.154e7 is the number of seconds in a year
        _mint(msg.sender, rewards);
        // Update the staking timestamp to the current time
        stakedFromTS[msg.sender] = block.timestamp;
    }
}