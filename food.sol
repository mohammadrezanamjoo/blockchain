pragma solidity ^0.8.0;

contract FoodAuthenticity {
    struct FoodProduct {
        string name;
        string origin;
        string manufacturer;
        uint256 productionDate;
        bool isAuthentic;
    }

    mapping(string => FoodProduct) public products;
    mapping(address => bool) public authorizedProducers;
    address public owner;

    event ProductRegistered(string indexed productId, string name, string manufacturer);
    event ProducerAuthorized(address indexed producer, bool status);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    modifier onlyAuthorizedProducer() {
        require(authorizedProducers[msg.sender], "Not an authorized producer");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function authorizeProducer(address _producer, bool _status) public onlyOwner {
        authorizedProducers[_producer] = _status;
        emit ProducerAuthorized(_producer, _status);
    }

    function registerProduct(
        string memory _productId,
        string memory _name,
        string memory _origin,
        string memory _manufacturer,
        uint256 _productionDate
    ) public onlyAuthorizedProducer {
        require(products[_productId].productionDate == 0, "Product ID already exists");
        
        products[_productId] = FoodProduct(_name, _origin, _manufacturer, _productionDate, true);
        emit ProductRegistered(_productId, _name, _manufacturer);
    }

    function verifyProduct(string memory _productId) public view returns (FoodProduct memory) {
        require(products[_productId].productionDate != 0, "Product not found");
        return products[_productId];
    }
}
