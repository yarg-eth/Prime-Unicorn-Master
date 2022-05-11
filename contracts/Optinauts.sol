// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import { IERC2981, IERC165 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract Optinauts is ERC721, IERC2981, Ownable, ReentrancyGuard {
  
  using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenSupply;

  uint256 public constant MAX_SUPPLY = 10000;
  uint256 public maxWhitelistMint = 2;
  uint256 public maxMint = 10;

  string public baseURI;

  bool public isActive = false;
  bool public whitelistIsActive = false;

  uint256 public whitelistPrice = 0.15 ether;
  uint256 public publicPrice = 0.2 ether;

  bytes32 public merkleRoot;
  mapping(address => bool) public whitelistClaimed;
  mapping(address => uint256) private _alreadyMinted;

  address public shareholderAddress;

  constructor(
    address _shareholderAddress,
    string memory _initialBaseURI
  ) ERC721("Optinauts", "OPTI") {
    shareholderAddress = _shareholderAddress;
    baseURI = _initialBaseURI;
  }

  // Accessors

  function setShareholderAddress(address _shareholderAddress) public onlyOwner {
    shareholderAddress = _shareholderAddress;
  }

  function setRoyalties(address _shareholderAddress) public onlyOwner {
    shareholderAddress = _shareholderAddress;
  }

  function setActive(bool _isActive) public onlyOwner {
    isActive = _isActive;
  }

  function setWhitelistActive(bool _whitelistIsActive) public onlyOwner {
    whitelistIsActive = _whitelistIsActive;
  }

  function setMerkleProof(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function remainingSupply() public view returns (uint256) {
    return MAX_SUPPLY - _tokenSupply.current();
  }

  function totalSupply() public view returns (uint256) {
    return _tokenSupply.current();
  }

  // Metadata

  function setBaseURI(string memory uri) public onlyOwner {
    baseURI = uri;
  }

  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }

  // Minting

  function whitelistMint(
    uint256 amount,
    bytes32[] calldata merkleProof
  ) public payable nonReentrant {
    address sender = _msgSender();

    require(whitelistIsActive, "Whitelist sale is not open");
    require(_verify(merkleProof, sender, maxWhitelistMint), "You are not whitelisted");
    require(amount <= maxWhitelistMint - _alreadyMinted[sender], "Insufficient mints left");
    require(msg.value == whitelistPrice * amount, "Incorrect payable amount");

    _alreadyMinted[sender] += amount;
    _internalMint(sender, amount);
  }

  function ownerMint(address to, uint256 amount) public onlyOwner {
    _internalMint(to, amount);
  }

  function publicMint(
    uint256 amount
  ) public payable nonReentrant {
    address sender = _msgSender();

    require(isActive, "Public sale is not open");
    require(amount <= maxMint - _alreadyMinted[sender], "Insufficient mints left");
    require(msg.value == publicPrice * amount, "Incorrect payable amount");
    
    _alreadyMinted[sender] += amount;
    _internalMint(sender, amount);
  }

  function withdraw() public onlyOwner {
    payable(shareholderAddress).transfer(address(this).balance);
  }
  // Private

  function _internalMint(address to, uint256 amount) public onlyOwner {
    require(_tokenSupply.current() + amount<= MAX_SUPPLY, "Will exceed maximum supply");

    for (uint256 i = 1; i <= amount; i++) {
      _tokenSupply.increment();
      _safeMint(to, _tokenSupply.current());
    }
  }

  function _verify(
    bytes32[] calldata merkleProof,
    address sender,
    uint256 maxAmount
  ) private view returns (bool) {
    bytes32 leaf = keccak256(abi.encodePacked(sender, maxAmount.toString()));
    return MerkleProof.verify(merkleProof, merkleRoot, leaf);
  }

  // ERC165

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, IERC165) returns (bool) {
    return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
  }

  // IERC2981

  function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address, uint256 royaltyAmount) {
    _tokenId; // silence solc warning
    royaltyAmount = (_salePrice / 100) * 5;
    return (shareholderAddress, royaltyAmount);
  }
}