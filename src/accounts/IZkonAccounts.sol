// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IZkonAccounts {

    function registerClient(address clientAddress) external returns (bool);

    function depositTokens(address client, uint256 amount) external returns (bool);

    function withdrawTokens(address client, uint256 amount) external returns (bool);

    function pause(address client) external;

    function verifyProofs(address client, bytes[] calldata proofs) external returns (bool);

    function storeShards(address client, uint256 user, bytes calldata encryptedShards) external;

    function getShards(address client, uint256 user) external returns (bytes memory encryptedShards);
}
