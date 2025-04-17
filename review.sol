pragma solidity ^0.8.0;

contract ReviewSystem {

    struct Review {
        address reviewer;
        uint8 rating; // Rating
        string comment;
        uint256 timestamp;
    }

    mapping(uint256 => Review[]) public productReviews;

    mapping(address => mapping(uint256 => bool)) public hasReviewed;

    event NewReview(
        uint256 indexed productId,
        address indexed reviewer,
        uint8 rating,
        string comment,
        uint256 timestamp
    );

    // Modifier to check if the rating is valid (between 1 and 5)
    modifier validRating(uint8 _rating) {
        require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5");
        _;
    }

    // Function to submit a review
    function submitReview(uint256 _productId, uint8 _rating, string calldata _comment)

        external
        validRating(_rating)
    {
        require(!hasReviewed[msg.sender][_productId], "You have already reviewed this product");

        // Create the review
        Review memory newReview = Review({
            reviewer: msg.sender,
            rating: _rating,
            comment: _comment,
            timestamp: block.timestamp
        });

        // Add the review to the product's review array
        productReviews[_productId].push(newReview);

        // Mark that this user has reviewed the product
        hasReviewed[msg.sender][_productId] = true;

        // Emit the event for the new review
        emit NewReview(_productId, msg.sender, _rating, _comment, block.timestamp);
    }

    // Function to get the number of reviews for a product
    function getReviewCount(uint256 _productId) external view returns (uint256) {
        return productReviews[_productId].length;
    }

    function getReview(uint256 _productId, uint256 _index)
        external
        view
        returns (address reviewer, uint8 rating, string memory comment, uint256 timestamp)
    {
        require(_index < productReviews[_productId].length, "Review does not exist");

        Review memory review = productReviews[_productId][_index];
        return (review.reviewer, review.rating, review.comment, review.timestamp);
    }

    function getAverageRating(uint256 _productId) external view returns (uint8) {
        uint256 totalRating = 0;
        uint256 reviewCount = productReviews[_productId].length;

        for (uint256 i = 0; i < reviewCount; i++) {

            totalRating += productReviews[_productId][i].rating;
        }

        return reviewCount > 0 ? uint8(totalRating / reviewCount) : 0;
    }
}
