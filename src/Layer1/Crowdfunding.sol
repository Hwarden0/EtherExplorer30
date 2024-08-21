//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract crowdfunding {
    // Variables
    address public owner;
    uint256 public goal;
    uint256 public deadline;
    uint256 public totalContributed;

    mapping(address => uint256) public contributions;

    //Events
    event contributionReceived(address indexed contributor, uint256 amount);
    event GoalReached(uint256 totalAmountRaised);

    //Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner can perform this action");
        _;
    }

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Deadline has passed");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Campaign is still ongoing");
        _;
    }

    constructor(uint256 _goal, uint256 _durationInDays) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _durationInDays * 1 days;
    }

    function contribute() external payable beforeDeadline {
        require(msg.value > 0, "Amount must be greater than 0");
        contributions[msg.sender] += msg.value;
        totalContributed += msg.value;
        emit contributionReceived(msg.sender, msg.value);

        //Emit event when the goal is reached
        if (totalContributed >= goal) {
            emit GoalReached(totalContributed);
        }
    }

    function withdrawFunds() external onlyOwner afterDeadline {
        require(totalContributed >= goal, "goal not reached");
        uint256 amount = totalContributed;
        totalContributed = 0;

        (bool success,) = owner.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function refund() external afterDeadline {
        require(totalContributed < goal, "goal reached but no funds");

        uint256 contributedAmount = contributions[msg.sender];
        require(contributedAmount > 0, "No Contributions to refund");

        contributions[msg.sender] = 0;

        (bool success,) = owner.call{value: contributedAmount}("");
        require(success, "refund is shit function");
    }
}
