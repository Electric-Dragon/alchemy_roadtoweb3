pragma solidity >=0.8.0 <0.9.0;

//SPDX-License-Identifier: MIT
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTixBooth is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private currentId;

    bool public saleIsActive = false;
    uint256 public totalTickets = 10;
    uint256 public availableTickets = 10;
    uint256 public mintPrice = 80000000000000000;

    mapping(address => uint256[]) public holderTokenIDs;
    mapping(address => bool) public checkIns;

    constructor() ERC721("NFTix", "NFTX") {
        currentId.increment();
        console.log(currentId.current());
    }

    function checkIn(address addy) public {
        checkIns[addy] = true;
        uint256 tokenId = holderTokenIDs[addy][0];

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "NFTix #',
                        Strings.toString(tokenId),
                        '", "description": "A NFT-powered ticketing system", ',
                        '"traits": [{ "trait_type": "Checked In", "value": "true" }, { "trait_type": "Purchased", "value": "true" }], ',
                        '"image": "ipfs://QmTHNkB3VwuAd7cLF1vVzumX18osfwLLHiLg6QS36kgXPc" }'
                    )
                )
            )
        );

        string memory tokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        _setTokenURI(tokenId, tokenURI);
    }

    function mint() public payable {
        require(availableTickets > 0, "Not enough tickets");
        require(msg.value >= mintPrice, "Not enough ETH!");
        require(saleIsActive, "Tickets are not on sale!");

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "NFTix #',
                        Strings.toString(currentId.current()),
                        '", "description": "A NFT-powered ticketing system", ',
                        '"traits": [{ "trait_type": "Checked In", "value": "false" }, { "trait_type": "Purchased", "value": "true" }], ',
                        '"image": "ipfs://QmPwUPQHFKFvZjmyt3samCQTPyb2mr6mNouMc84xWdyFHj" }'
                    )
                )
            )
        );

        string memory tokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        _safeMint(msg.sender, currentId.current());
        _setTokenURI(currentId.current(), tokenURI);

        holderTokenIDs[msg.sender].push(currentId.current());
        currentId.increment();
        availableTickets = availableTickets - 1;
    }

    function availableTicketCount() public view returns (uint256) {
        return availableTickets;
    }

    function totalTicketCount() public view returns (uint256) {
        return totalTickets;
    }

    function openSale() public onlyOwner {
        saleIsActive = true;
    }

    function closeSale() public onlyOwner {
        saleIsActive = false;
    }

    function confirmOwnership(address addy) public view returns (bool) {
        return holderTokenIDs[addy].length > 0;
    }
}