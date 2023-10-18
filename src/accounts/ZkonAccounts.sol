// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IZkonAccounts.sol";

contract ZkonAccounts is IZkonAccounts {
    function registerClient(address clientAddress) external override returns (bool) {
        return true;
    }

    function depositTokens(address client, uint256 amount) external override returns (bool) {
        return true;
    }

    function withdrawTokens(address client, uint256 amount) external override returns (bool) {
        return true;
    }

    function pause(address client) external override {
    }

    function verifyProofs(address client, bytes[] calldata proofs) external override returns (bool) {
        return true;
    }

    function storeShards(address client, uint256 user, bytes calldata encryptedShards) external override {

    }

    function getShards(address client, uint256 user) external override returns (bytes memory encryptedShards) {

    }
}
