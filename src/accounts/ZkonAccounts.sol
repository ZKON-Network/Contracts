// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IZkonAccounts.sol";
import "openzeppelin/access/AccessControl.sol";
import "../utils/TransferHelper.sol";

contract ZkonAccounts is IZkonAccounts, AccessControl {

    // Client => isEnabled
    mapping(address => bool) public clients;

    // Client => Amount
    mapping(address => uint256) public amounts;

    // Client => User Id => Encrypted Shards
    mapping(address => mapping(uint256 => bytes)) private shards;

    address public zkonToken;

    address public treasury;

    uint256 public signPrice;

    // Client -> Signature Hashes
    mapping(address => bytes[]) public signs;

    event ProofsSubmited(address indexed client, uint256 amount);

    constructor(address _zkonToken, uint256 _signPrice, address _treasury) {
        zkonToken = _zkonToken;
        signPrice = _signPrice;
        treasury = _treasury;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setSignPrice(uint256 price) external onlyRole(DEFAULT_ADMIN_ROLE) {
        signPrice = price;
    }

    function setTreasury(address _treasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        treasury = _treasury;
    }

    function registerClient(address clientAddress) external override onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        clients[clientAddress] = true;
        return true;
    }

    function depositTokens(address client, uint256 amount) external override returns (bool) {
        TransferHelper.safeTransferFrom(zkonToken, msg.sender, address(this), amount);
        amounts[client] += amount;
        return true;
    }

    function withdrawTokens(address client, uint256 amount) external override onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        require(amount <= amounts[client], "Not enough amount");
        amounts[client] -= amount;
        TransferHelper.safeTransfer(zkonToken, msg.sender, amount);
        return true;
    }

    function getTokens(address client) external view override returns (uint256) {
        return amounts[client];
    }

    function pause(address client) external override {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || msg.sender == client, "Invalid auth");
        clients[client] = false;
    }

    function verifyProofs(address client, bytes[] calldata proofs) external override returns (bool) {
        for (uint256 i = 0; i < proofs.length; i++) {
            signs[client].push(proofs[i]);
        }
        TransferHelper.safeTransfer(zkonToken, treasury, proofs.length * signPrice);
        emit ProofsSubmited(client, proofs.length);
        return true;
    }

    function getProofs(address client, uint256 limit, uint256 offset) public view returns (bytes[] memory) {
        bytes[] memory proofs = new bytes[](limit);
        for (uint256 i = 0; i < limit; i++) {
            proofs[i] = signs[client][offset + i];
        }
        return proofs;
    }

    function storeShards(address client, uint256 user, bytes calldata encryptedShards) external override {
        require(amounts[client] > 0, "Not enough balance");
        require(clients[client], "Client disabled");
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || msg.sender == client, "Invalid auth");
        shards[client][user] = encryptedShards;
    }

    function getShards(address client, uint256 user) external view override returns (bytes memory encryptedShards) {
        require(clients[client], "Client disabled");
        return shards[client][user];
    }
}
