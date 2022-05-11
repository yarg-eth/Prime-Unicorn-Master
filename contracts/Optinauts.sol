// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract Optinauts is ERC721, Ownable, ReentrancyGuard {
  
  using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenSupply;

  uint256 public constant MAX_SUPPLY = 10000;
  uint256 public maxWhitelistMint = 2;
  uint256 public maxMint = 10;

  string public baseURI;

  bool public isActive = false;

  uint256 public mintPrice = 0.15 ether;

  bytes32 public merkleRoot;
  mapping(address => bool) public whitelistClaimed;
  mapping(address => uint256) private _alreadyMinted;

  address public t1 = 0x6d6257976bd82720A63fb1022cC68B6eE7c1c2B0;
  address public t2 = 0x74Fac8b17237e00724E06d20115b7ecFA3389281;
  address public t3 = 0xb2e7e393E8C6Dfe9c311ce786e1E68459253839c;
  address public t4 = 0xCaA8aEd2B9765461d6318f01223Da08964f955C3;

  constructor(
    string memory _initialBaseURI
  ) ERC721("Optinauts", "OPTI") {
    baseURI = _initialBaseURI;
  }

  // Accessors

  function setActive(bool _isActive) public onlyOwner {
    isActive = _isActive;
  }

  function setPrice(uint256 _mintPrice) public onlyOwner() {
        mintPrice = _mintPrice;
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

    require(isActive, "Whitelist sale is not open");
    require(_verify(merkleProof, sender, maxWhitelistMint), "You are not whitelisted");
    require(amount <= maxWhitelistMint - _alreadyMinted[sender], "Insufficient mints left");
    require(msg.value == mintPrice * amount, "Incorrect payable amount");

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
    require(msg.value == mintPrice * amount, "Incorrect payable amount");
    
    _alreadyMinted[sender] += amount;
    _internalMint(sender, amount);
  }

  function withdrawAll() public payable onlyOwner {
        uint256 _each = address(this).balance / 4;
        require(payable(t1).send(_each), "Account is being paid out");
        require(payable(t2).send(_each), "Account is being paid out");
        require(payable(t3).send(_each), "Account is being paid out");
        require(payable(t4).send(_each), "Account is being paid out");
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
}