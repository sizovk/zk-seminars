// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract MerkleTornado {
    uint256 public constant DENOMINATION = 1 ether;
    uint32 public constant LEVELS = 20;
    uint32 public constant ROOT_HISTORY_SIZE = 30;

    bytes32[LEVELS] public filledSubtrees;
    mapping(uint256 => bytes32) public roots;
    uint32 public currentRootIndex = 0;
    uint32 public nextIndex = 0;

    mapping(bytes32 => bool) public commitments;
    mapping(bytes32 => bool) public nullifierHashes;

    event Deposit(bytes32 indexed commitment, uint32 leafIndex, uint256 timestamp);
    event Withdrawal(address to, bytes32 nullifierHash);

    constructor() {
        for (uint32 i = 0; i < LEVELS; i++) {
            filledSubtrees[i] = zeros(i);
        }
        roots[0] = zeros(LEVELS);
    }

    function hashLeftRight(bytes32 _left, bytes32 _right) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_left, _right));
    }

    function deposit(bytes32 _commitment) external payable {
        require(msg.value == DENOMINATION, "Send exactly 1 ETH");
        require(!commitments[_commitment], "Commitment already exists");
        require(nextIndex < uint32(2)**LEVELS, "Merkle tree is full");

        uint32 currentIndex = nextIndex;
        bytes32 currentLevelHash = _commitment;

        for (uint32 i = 0; i < LEVELS; i++) {
            if (currentIndex % 2 == 0) {
                filledSubtrees[i] = currentLevelHash;
                currentLevelHash = hashLeftRight(currentLevelHash, zeros(i));
            } else {
                currentLevelHash = hashLeftRight(filledSubtrees[i], currentLevelHash);
            }
            currentIndex /= 2;
        }

        uint32 newRootIndex = (currentRootIndex + 1) % ROOT_HISTORY_SIZE;
        currentRootIndex = newRootIndex;
        roots[newRootIndex] = currentLevelHash;

        commitments[_commitment] = true;
        uint32 insertedIndex = nextIndex;
        nextIndex += 1;

        emit Deposit(_commitment, insertedIndex, block.timestamp);
    }

    function withdraw(
        address payable _recipient,
        bytes32 _nullifier,
        bytes32 _secret,
        bytes32 _root,
        bytes32[LEVELS] calldata _siblings,
        uint32[LEVELS] calldata _pathIndices
    ) external {
        // Problems:
        // 1. recipient cannot be changed!!
        // 2. we would love to be secret: secret, nullifier, _pathIndices, _siblings

        require(!nullifierHashes[nullifierHash], "Already withdrawn");
        require(isKnownRoot(_root), "Unknown root");
    

        bytes32 nullifierHash = keccak256(abi.encodePacked(_nullifier));
        bytes32 commitment = keccak256(abi.encodePacked(_nullifier, _secret));

        bytes32 currentHash = commitment;
        for (uint32 i = 0; i < LEVELS; i++) {
            if (_pathIndices[i] == 0) {
                currentHash = hashLeftRight(currentHash, _siblings[i]);
            } else {
                currentHash = hashLeftRight(_siblings[i], currentHash);
            }
        }
        require(currentHash == _root, "Invalid merkle proof");

        nullifierHashes[nullifierHash] = true;

        (bool success, ) = _recipient.call{value: DENOMINATION}("");
        require(success, "Transfer failed");

        emit Withdrawal(_recipient, nullifierHash);
    }

    function isKnownRoot(bytes32 _root) public view returns (bool) {
        if (_root == 0) return false;
        uint32 i = currentRootIndex;
        do {
            if (_root == roots[i]) return true;
            if (i == 0) i = ROOT_HISTORY_SIZE;
            i--;
        } while (i != currentRootIndex);
        return false;
    }

    function getLastRoot() public view returns (bytes32) {
        return roots[currentRootIndex];
    }

    function zeros(uint256 i) public pure returns (bytes32) {
        if (i == 0) return keccak256(abi.encodePacked(bytes32(0)));
        bytes32 result = keccak256(abi.encodePacked(bytes32(0)));
        for (uint256 j = 0; j < i; j++) {
            result = keccak256(abi.encodePacked(result, result));
        }
        return result;
    }
}

