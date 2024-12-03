// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EventPOAP is ERC721, Ownable {
    uint256 private _tokenIds;
    mapping(uint256 => uint256) public eventToTokenId;
    
    constructor() ERC721("Event POAP", "POAP") {}
    
    function mintPOAP(address recipient, uint256 eventId) public onlyOwner {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        _mint(recipient, newTokenId);
        eventToTokenId[eventId] = newTokenId;
    }
}