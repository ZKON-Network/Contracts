// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Zkon} from "../Zkon.sol";
import {IZkonRequestsCoordinator} from "./IZkonRequestsCoordinator.sol";
import "../utils/TransferHelper.sol";
import "openzeppelin/access/AccessControl.sol";

contract ZkonRequestsCoordinator is IZkonRequestsCoordinator, AccessControl {
    
    mapping(bytes32 => address) private pendingRequests;
    uint256 private requestCount = 1;

    address public zkonToken;
    address public treasury;
    uint256 public feePrice;

    constructor(address _zkonToken, uint256 _feePrice, address _treasury) {
        zkonToken = _zkonToken;
        feePrice = _feePrice;
        treasury = _treasury;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setFeeprice(uint256 price) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feePrice = price;
    }

    function setTreasury(address _treasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        treasury = _treasury;
    }

    function sendRequest(Zkon.Request memory req) external returns (bytes32) {
        bytes32 requestId = keccak256(abi.encodePacked(this, requestCount));
        req.nonce = requestCount;
        pendingRequests[requestId] = msg.sender;
        emit Requested(requestId);
        TransferHelper.safeTransferFrom(zkonToken, msg.sender, treasury, feePrice);
        requestCount += 1;

        return requestId;
    }

    function recordRequestFulfillment(bytes32 requestId) external {
        require(msg.sender == pendingRequests[requestId], "Source must be the contract of the request");
        delete pendingRequests[requestId];
        emit Fulfilled(requestId);
    }
}
