    //SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Faucet {
    //variables
    IERC20 public token;
    address public owner;
    uint256 public amountAllowed;
    mapping(address => bool) public requested;

    constructor(address _token, uint256 _amountAllowed) {
        token = IERC20(_token);
        amountAllowed = _amountAllowed;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not the contract owner");
        _;
    }

    function setAmountAllowed(uint256 _amountAllowed) external onlyOwner {
        amountAllowed = _amountAllowed;
    }

    function requestTokens() external {
        require(requested[msg.sender] == false, "Tokens already requested");
        require(token.balanceOf(address(this)) >= amountAllowed, "Insufficient amount");

        token.transfer(msg.sender, amountAllowed);
        requested[msg.sender] = true;
    }

    function Refill(uint256 _amount) external onlyOwner {
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer Failed");
    }
}
