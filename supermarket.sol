
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DailySupermarketProducts {
    // Owner of the contract (supermarket admin)
    address public owner;

    // Struct to represent a product
    struct Product {
        string name;
        uint256 price; // Price in wei
        uint256 stock; // Available stock
        uint256 lastUpdated; // Timestamp of last stock update
    }

    // Mapping from product ID to Product
    mapping(uint256 => Product) public products;

    // Counter for product IDs
    uint256 public nextProductId;

    // Event for when a product is added
    event ProductAdded(uint256 indexed productId, string name, uint256 price, uint256 stock);

    // Event for when stock is updated
    event StockUpdated(uint256 indexed productId, uint256 newStock);

    // Event for when a product is purchased
    event ProductPurchased(uint256 indexed productId, address buyer, uint256 quantity, uint256 totalPrice);

    // Modifier to restrict access to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
        nextProductId = 1;
    }

    // Function to add a new product (only owner)
    function addProduct(string memory _name, uint256 _price, uint256 _stock) public onlyOwner {
        uint256 productId = nextProductId;
        products[productId] = Product({
            name: _name,
            price: _price,
            stock: _stock,
            lastUpdated: block.timestamp
        });
        nextProductId++;
        emit ProductAdded(productId, _name, _price, _stock);
    }

    // Function to update stock for a product (only owner)
    // Could be used for daily restocking
    function updateStock(uint256 _productId, uint256 _newStock) public onlyOwner {
        require(_productId < nextProductId && _productId > 0, "Invalid product ID");
        products[_productId].stock = _newStock;
        products[_productId].lastUpdated = block.timestamp;
        emit StockUpdated(_productId, _newStock);
    }

    // Function to purchase a product
    function purchaseProduct(uint256 _productId, uint256 _quantity) public payable {
        require(_productId < nextProductId && _productId > 0, "Invalid product ID");
        Product storage product = products[_productId];
        require(product.stock >= _quantity, "Insufficient stock");
        uint256 totalPrice = product.price * _quantity;
        require(msg.value >= totalPrice, "Insufficient payment");

        // Update stock
        product.stock -= _quantity;

        // Transfer payment to owner
        payable(owner).transfer(totalPrice);

        // Refund excess payment if any
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }

        emit ProductPurchased(_productId, msg.sender, _quantity, totalPrice);
    }

    // Function to get product details
    function getProduct(uint256 _productId) public view returns (string memory name, uint256 price, uint256 stock, uint256 lastUpdated) {
        require(_productId < nextProductId && _productId > 0, "Invalid product ID");
        Product memory product = products[_productId];
        return (product.name, product.price, product.stock, product.lastUpdated);
    }

    // Function to check if a day has passed since last update (for daily checks)
    function isNewDay(uint256 _productId) public view returns (bool) {
        require(_productId < nextProductId && _productId > 0, "Invalid product ID");
        uint256 lastUpdate = products[_productId].lastUpdated;
        return (block.timestamp >= lastUpdate + 1 days);
    }
}
