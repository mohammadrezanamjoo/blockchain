pragma solidity ^0.8.0;

import  "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract NFTMarketplace is ERC721, Ownable {
    using SafeMath for uint256;

    uint256 public tokenIdCounter;
    uint256 public listingPrice = 0.01 ether;

    enum ListingStatus { Open, Sold }

    struct NFTListing {

        uint256 tokenId;
        address seller;
        uint256 price;
        ListingStatus status;
    }

    mapping(uint256 => NFTListing) public listings;



    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed buyer, uint256 price);

    constructor() ERC721("NFTMarketplace",  "NFTM") {
        tokenIdCounter = 1;
    }

    function listNFT(uint256 _price) external {
        require(_price >= listingPrice, "Listing price must be at least the listing fee");

        _safeMint(msg.sender, tokenIdCounter);

        listings[tokenIdCounter] = NFTListing({
            tokenId: tokenIdCounter,
            seller: msg.sender,
            price: _price,
            status: ListingStatus.Open
        });

        emit NFTListed(tokenIdCounter, msg.sender, _price);

        tokenIdCounter++;
    }

    function buyNFT(uint256 _tokenId) external payable {

        NFTListing storage listing = listings[_tokenId];
        require(listing.status == ListingStatus.Open, "NFT not available for purchase");
        require(msg.value == listing.price, "Incorrect payment amount");
        _transfer(listing.seller, msg.sender, _tokenId);
        listing.status = ListingStatus.Sold;
        payable(listing.seller).transfer(msg.value);
        emit NFTSold(_tokenId, msg.sender, msg.value);
    }



    function setListingPrice(uint256 _price) external onlyOwner {

        listingPrice = _price;
    }
}

