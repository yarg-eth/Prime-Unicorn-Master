// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract PrimeUnicorn is ERC721, Ownable, ReentrancyGuard {
    //@dev Using Counters to reduce cost of gas in comparison to ERC721Enumerable
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenSupply;

    uint256 public constant MAX_SUPPLY = 5555;
    uint256 public maxWhitelistMint = 1;
    uint256 public maxMint = 5;

    string public baseURI;
    //@dev set whiteList mint as active and public mint as active.
    bool public isActive = false;
    bool public wlIsActive = false;

    uint256 public mintPrice = 0.15 ether;

    mapping(address => uint256) private _alreadyWLMinted;
    mapping(address => uint256) private _alreadyMinted;
    //@dev Addresses set to split payments. This may be removed prior to launch(Gnosis Vault)
    address public t1 = 0x6d6257976bd82720A63fb1022cC68B6eE7c1c2B0;
    bytes32 public merkleRoot =
        0xacfb928651bb0ca9be7cdc730d00ca6a51e5b0db2fe019cecc5c521a565fb7f4;

    constructor(string memory _initialBaseURI) ERC721("PrimeUnicorn", "PUNI") {
        baseURI = _initialBaseURI;
    }

    // Accessors

    function setActive(bool _isActive) public onlyOwner {
        isActive = _isActive;
    }

    function setWlActive(bool _wlIsActive) public onlyOwner {
        wlIsActive = _wlIsActive;
    }

    function setPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setRoot(bytes32 _merkleRoot) public onlyOwner {
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

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    // Minting

    function whitelistMint(uint256 amount, bytes32[] calldata merkleProof)
        public
        payable
    {
        address sender = _msgSender();

        require(wlIsActive, "Whitelist sale is not open");
        require(_verify(merkleProof, sender), "You are not whitelisted");
        require(
            amount <= maxWhitelistMint - _alreadyWLMinted[sender],
            "Insufficient mints left"
        );
        require(msg.value == mintPrice * amount, "Incorrect payable amount");

        _alreadyWLMinted[sender] += amount;
        _internalMint(sender, amount);
    }

    function ownerMint(address to, uint256 amount) public onlyOwner {
        _internalMint(to, amount);
    }

    function mint(uint256 amount) public payable {
        address sender = _msgSender();

        require(isActive, "Public sale is not open");
        require(
            amount <= maxMint - _alreadyMinted[sender],
            "Insufficient mints left"
        );
        require(msg.value == mintPrice * amount, "Incorrect payable amount");

        _alreadyMinted[sender] += amount;
        _internalMint(sender, amount);
    }

    // Payment Split
    function withdrawAll() public payable onlyOwner {
        uint256 _each = address(this).balance;
        require(payable(t1).send(_each), "Account is being paid out");
    }

    // Private

    function _internalMint(address to, uint256 amount) public {
        require(
            _tokenSupply.current() + amount <= MAX_SUPPLY,
            "Will exceed maximum supply"
        );

        for (uint256 i = 1; i <= amount; i++) {
            _tokenSupply.increment();
            _safeMint(to, _tokenSupply.current());
        }
    }

    // Merkle Proof verify
    function _verify(bytes32[] calldata merkleProof, address sender)
        private
        view
        returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(sender));
        return MerkleProof.verify(merkleProof, merkleRoot, leaf);
    }
}
