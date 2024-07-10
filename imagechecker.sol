// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BitmapVerifier {
    bytes32 public originalImageHash;
    address public owner;

    constructor(bytes32 _originalImageHash) {
        originalImageHash = _originalImageHash;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function setOriginalImageHash(bytes32 _originalImageHash) public onlyOwner {
        originalImageHash = _originalImageHash;
    }

    function verifyImage(bytes32 _imageHash) public view returns (bool) {
        return _imageHash == originalImageHash;
    }

    // Utility function to compute hash of the image
    function computeImageHash(bytes memory image) public pure returns (bytes32) {
        return keccak256(image);
    }
}

