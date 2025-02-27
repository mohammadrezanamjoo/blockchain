pragma solidity ^0.8.0;

contract FoodSupplyChain {
    struct Product {
        uint256 id;
        string name;
        string origin;
        address currentOwner;
        uint256 timestamp;
        string status;
    }

    mapping(uint256 => Product) public products;

    mapping(uint256 => Product[]) public productHistory;

    // Unique product ID counter
    uint256 public productCounter;

    event ProductCreated(uint256 indexed productId, string name, string origin, address owner);

    event ProductTransferred(uint256 indexed productId, address indexed from, address indexed to);

    event ProductStatusUpdated(uint256 indexed productId, string status);

    // Function to create a new product in the supply chain
    function createProduct(string memory _name, string memory _origin) public {
        productCounter++;
        products[productCounter] = Product(productCounter, _name, _origin, msg.sender, block.timestamp, "Created");
        productHistory[productCounter].push(products[productCounter]);
        emit ProductCreated(productCounter, _name, _origin, msg.sender);
    }

    function transferProduct(uint256 _productId, address _newOwner) public {

        require(products[_productId].currentOwner == msg.sender, "You do not own this product.");
        products[_productId].currentOwner = _newOwner;

        products[_productId].timestamp = block.timestamp;
        products[_productId].status = "Transferred";
        productHistory[_productId].push(products[_productId]);

        emit ProductTransferred(_productId, msg.sender, _newOwner);

    }

    function updateProductStatus(uint256 _productId, string memory _status) public {

        require(products[_productId].currentOwner == msg.sender, "You do not own this product.");
        products[_productId].status = _status;
        products[_productId].timestamp = block.timestamp;
        productHistory[_productId].push(products[_productId]);
        emit ProductStatusUpdated(_productId, _status);

    }

    function getProductHistory(uint256 _productId) public view returns (Product[] memory) {
        return productHistory[_productId];
    }
}
