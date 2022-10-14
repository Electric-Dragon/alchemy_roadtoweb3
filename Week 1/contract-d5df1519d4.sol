// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.3/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.7.3/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.7.3/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.7.3/utils/Counters.sol";

contract ElectricDragon is ERC721, ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 MAX_SUPPLY = 69;
    uint MAX_PER_ADDRESS = 2;

    constructor() ERC721("Electric Dragon", "ELD") {}

    mapping(address => uint) public balances;

    function safeMint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter.current();
        uint currentNum = balances[to];
        require(currentNum < MAX_PER_ADDRESS, "You have reached the maximum number of tokens you can mint!");
        require(_tokenIdCounter.current() <= MAX_SUPPLY, "I'm sorry we reached the cap");
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        balances[to] = currentNum + 1;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function getNum (address person) public returns (uint) {
        return balances[person];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
