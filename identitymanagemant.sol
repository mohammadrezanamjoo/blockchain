
pragma solidity ^0.8.0;

contract IdentityManagement {
    struct Identity {
        string username;
        address owner;
        bool isVerified;
    }

    mapping(address => Identity) public identities;

    event IdentityCreated(address indexed owner, string username);
    event IdentityVerified(address indexed owner);

    modifier onlyOwner() {
        require(msg.sender == identities[msg.sender].owner, " Only the identity owner can call this function ");
        _;
    }

    function createIdentity(string memory _username) external {
        require(bytes(_username).length > 0,  " Username cannot be empty " );
        require(identities[msg.sender].owner == address(0), " Identity already exists ");

        identities[msg.sender] = Identity(_username, msg.sender, false);
        emit IdentityCreated(msg.sender, _username);
    }

    function verifyIdentity(address _identity) external onlyOwner {
        require(identities[_identity].owner != address(0), "Identity does not exist");
        require(msg.sender != _identity, " Cannot verify own identity ");

        identities[_identity].isVerified = true;
        emit IdentityVerified(_identity);
    }
}
