// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract SimpleTornado {
    uint256 public constant DENOMINATION = 1 ether;

    mapping(bytes32 => bool) public commitments;
    mapping(bytes32 => bool) public nullifierHashes;

    event Deposit(bytes32 indexed commitment, uint256 timestamp);
    event Withdrawal(address to, bytes32 nullifierHash);

    function deposit(bytes32 _commitment) external payable {
        require(msg.value == DENOMINATION, "Send exactly 1 ETH");
        require(!commitments[_commitment], "Commitment already exists");

        commitments[_commitment] = true;

        emit Deposit(_commitment, block.timestamp);
    }

    function withdraw(
        address payable _recipient,
        bytes32 _nullifier,
        bytes32 _secret
    ) external {
        bytes32 _nullifierHash = keccak256(abi.encodePacked(_nullifier));
        bytes32 _commitment = keccak256(abi.encodePacked(_nullifier, _secret));

        require(commitments[_commitment], "Unknown commitment");
        require(!nullifierHashes[_nullifierHash], "Already withdrawn");

        nullifierHashes[_nullifierHash] = true;

        (bool success, ) = _recipient.call{value: DENOMINATION}("");
        require(success, "Transfer failed");

        emit Withdrawal(_recipient, _nullifierHash);
    }
}

