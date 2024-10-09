pragma solidity ^0.8.0;

contract InvestmentPlatform {

    address public owner;
    uint256 public minimumInvestment;
    
    struct Investor {

        uint256 amountInvested;
        uint256 investmentTime;
    }
    
    mapping(address => Investor) public investors;

    event InvestmentMade(address indexed investor, uint256 amount);

    event Withdrawal(address indexed investor, uint256 amount);

    constructor(uint256 _minimumInvestment) {
        owner = msg.sender;
        minimumInvestment = _minimumInvestment;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier hasMinimumInvestment() {
        require(msg.value >= minimumInvestment, "Investment amount too low");
        _;
    }

    function invest() external payable hasMinimumInvestment {
        Investor storage investor = investors[msg.sender];
        investor.amountInvested += msg.value;
        investor.investmentTime = block.timestamp;

        emit InvestmentMade(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        Investor storage investor = investors[msg.sender];
        require(investor.amountInvested >= amount, "Insufficient balance");

        investor.amountInvested -= amount;
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    function getInvestorDetails() external view returns (uint256 amountInvested, uint256 investmentTime) {

        Investor storage investor = investors[msg.sender];

        return (investor.amountInvested, investor.investmentTime);
    }

    function setMinimumInvestment(uint256 _minimumInvestment) external onlyOwner {

        minimumInvestment = _minimumInvestment;
    }

    // Function to withdraw all funds (onlyOwner) for administrative purposes
    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
