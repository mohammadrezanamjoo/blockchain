pragma solidity ^0.8.0;

contract FoodProductTracker {

    struct Product {

        uint256 id;

        string name;
        string origin;
        uint256 productionDate;
        string currentLocation;
        string status;

    }

    mapping(uint256 => Product) public products;
    uint256 public nextProductId;

    event ProductAdded(uint256 id, string name, string origin, uint256 productionDate);
    event ProductLocationUpdated(uint256 id, string newLocation);
    event ProductStatusUpdated(uint256 id, string newStatus);

    function addProduct(string memory _name, string memory _origin, uint256 _productionDate) public {
        products[nextProductId] = Product(nextProductId, _name, _origin, _productionDate, _origin, "Produced");
        emit ProductAdded(nextProductId, _name, _origin, _productionDate);
        nextProductId++;
    }

    function updateProductLocation(uint256 _id, string memory _newLocation) public {
        require(_id < nextProductId, "Product not found");
        products[_id].currentLocation = _newLocation;
        emit ProductLocationUpdated(_id, _newLocation);
    }

    function updateProductStatus(uint256 _id, string memory _newStatus) public {
        require(_id < nextProductId, "Product not found");
        products[_id].status = _newStatus;
        emit ProductStatusUpdated(_id, _newStatus);
    }

    function getProduct(uint256 _id) public view returns (Product memory) {
        require(_id < nextProductId, "Product not found");
        return products[_id];
    }
}
