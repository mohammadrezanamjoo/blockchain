// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    address public owner;
    uint public productCount = 0;

    enum ProductStatus { Created, Shipped, Received }

    struct Product {
        uint id ;
        string name;
        ProductStatus status;
    }

    mapping(uint => Product) public products;

    event ProductCreated(uint id, string name, ProductStatus status);
    event ProductShipped(uint id, ProductStatus status);
    event ProductReceived(uint id, ProductStatus status);

    modifier onlyOwner()  {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    modifier productExists(uint _productId) {
        require(_productId <= productCount,  "Product does not exist");
        _;
    }

    modifier productNotShipped(uint _productId) {
        require(products[_productId].status != ProductStatus.Shipped, "Product already shipped");
        _;
    }

    modifier productNotReceived(uint _productId) {
        require(products[_productId].status != ProductStatus.Received, "Product already received");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createProduct(string memory _name) external onlyOwner {
        productCount++; 
        products[productCount] = Product(productCount, _name, ProductStatus.Created);
        emit ProductCreated(productCount, _name, ProductStatus.Created);
    }

    function shipProduct(uint _productId) external onlyOwner productExists(_productId) productNotShipped(_productId) {
        products[_productId].status = ProductStatus.Shipped;
        emit ProductShipped(_productId, ProductStatus.Shipped);
    }

    function receiveProduct(uint _productId) external onlyOwner productExists(_productId) productNotReceived(_productId) {
        products[_productId].status = ProductStatus.Received;
        emit ProductReceived(_productId, ProductStatus.Received);
    }
}
