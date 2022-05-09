const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

let whitelistAddresses = [
    "0x16DD346Aa1483264DBb0Dde64235081C867fb3f2",
    "0x72672236A8B47f3d84248890FF48662a6d197833",
    "0x46340b20830761efd32832A74d7169B29FEB9758",
    "0x91bFc391fDD6E07f54283bbd5F1417c58E872BAD",
    "0xb2e7e393E8C6Dfe9c311ce786e1E68459253839c",
    "0x74Fac8b17237e00724E06d20115b7ecFA3389281"
]

// Merkle Tree & Root Hash
const leafNodes = whitelistAddresses.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true});

const merkleRoot = merkleTree.getRoot();

console.log('Whitelist Merkle Tree\n', merkleTree.toString(), 'Root Hash\n', merkleRoot.toString('hex'));

// Server Side / API Implementation
const claimingAddress = leafNodes[6];

const hexProof = merkleTree.getHexProof(claimingAddress);

console.log('Merkle Proof for Address\n', hexProof)

//Smart Contract Integration

/*Use bytes32 public merkleRoot = "Your Root Hash Here" and mapping(address => bool) public whitelistClaimed;
in your contract parameters or create a function that allows for you to set the merkleRoot after deployment.

After you have done this. Create a mint function that looks something like this. Do your own due diligence on your mint function. This is just an example.

    function whitelistMint(bytes32[] calldata _merkleRoot) public {
        require(!whitelistClaimed[msg.sender], "Address has already claimed.");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid Proof.");

        whitelistClaimed[msg.sender] = true;
    }
*/