// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract DecentralizedExchange {
    address public owner;

    mapping(address => mapping(address => uint256)) public tokenBalances;

    event TradeExecuted(address indexed buyer, address indexed seller, uint256 amount, address indexed token);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function depositToken(address _token, uint256 _amount) external {
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Failed to transfer tokens");
        tokenBalances[msg.sender][_token] += _amount;
    }

    function withdrawToken(address _token, uint256 _amount) external {
        require(tokenBalances[msg.sender][_token] >= _amount, "Insufficient balance");
        require(IERC20(_token).transfer(msg.sender, _amount), "Failed to transfer tokens");
        tokenBalances[msg.sender][_token] -= _amount;
    }

    function executeTrade(address _token, address _seller, uint256 _amount) external {
        require(tokenBalances[_seller][_token] >= _amount, "Insufficient seller balance");

        // Transfer tokens from the buyer to the seller
        require(IERC20(_token).transferFrom(msg.sender, _seller, _amount), "Failed to transfer tokens");

        // Update token balances
        tokenBalances[msg.sender][_token] += _amount;
        tokenBalances[_seller][_token] -= _amount;

        // Emit trade event
        emit TradeExecuted(msg.sender, _seller, _amount, _token);
    }
}
