pragma solidity ^0.8.0;

interface IERC20 {
   
function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract LendingPlatform {
    address public owner;
    IERC20 public daiToken;
    
    mapping(address => uint256) public collateralBalances;

    event CollateralDeposited (address indexed borrower, uint256 amount);
    event LoanGranted(address indexed borrower, uint256 loanAmount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor(address _daiTokenAddress) {
        owner = msg.sender;
        daiToken = IERC20(_daiTokenAddress);
    }

    function depositCollateral() external payable {
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    function requestLoan(uint256 _loanAmount) external {
        require(_loanAmount > 0, "Loan amount must be greater than 0");

        require(collateralBalances[msg.sender] >= _loanAmount, " Insufficient collateral ");


        require(daiToken.transferFrom(owner, msg.sender, _loanAmount), " Failed to transfer DAI");

        collateralBalances[msg.sender] -= _loanAmount;

        emit LoanGranted(msg.sender, _loanAmount);
    }

    function repayLoan (uint256 _repaymentAmount) external {
        require(_repaymentAmount > 0, "Repayment amount must be greater than 0");
        
        require(daiToken.transferFrom(msg.sender, owner, _repaymentAmount), "Failed to repay loan");

        collateralBalances[msg.sender] += _repaymentAmount;
    }
}
