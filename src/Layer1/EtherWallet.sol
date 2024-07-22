//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title this is example of a simple ether wallet but with a cool functionality
/// @author Serpent0x
contract EtherWallet {
    //Variables
    address payable public owner;
    bool private _paused;

    //Events
    event Deposit(address indexed from, uint256 indexed amount);
    event Withdrawal(address indexed to, uint256 indexed amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event paused();
    event unpaused();

    //Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "only the Owner should call this function");
        _;
    }

    modifier notPaused() {
        require(!_paused, "contract is paused");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable notPaused {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external onlyOwner notPaused {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(msg.sender).transfer(_amount);
        emit Withdrawal(msg.sender, _amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function pause() external onlyOwner {
        _paused = true;
        emit paused();
    }

    function unPause() external onlyOwner {
        _paused = false;
        emit unpaused();
    }

    function transferOwnership(address payable newOwner) external onlyOwner {
        require(newOwner != address(0), "new owner is the zero address");

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;
    }
}
