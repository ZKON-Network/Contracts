// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Zkon} from "../Zkon.sol";
import {IZkonRequestsCoordinator} from "./IZkonRequestsCoordinator.sol";

abstract contract ZkonRequests {
    
    using Zkon for Zkon.Request;

    mapping(bytes32 => address) private s_pendingRequests;
    IZkonRequestsCoordinator private coordinator;

    constructor(IZkonRequestsCoordinator _coordinator) {
        coordinator = _coordinator;
    }

    /**
    * @notice Creates a request 
    * @param jobId The Job Specification ID that the request will be created for
    * @param callbackAddr address to operate the callback on
    * @param callbackFunctionSignature function signature to use for the callback
    * @return A Zkon Request struct in memory
    */
    function buildRequest(
        bytes32 jobId,
        address callbackAddr,
        bytes4 callbackFunctionSignature
    ) internal pure returns (Zkon.Request memory) {
        Zkon.Request memory req;
        return req.initialize(jobId, callbackAddr, callbackFunctionSignature);
    }

    /**
    * @notice Creates a request to the stored oracle address
    * @param req The initialized Zkon Request
    * @return requestId The request ID
    */
    function sendRequest(Zkon.Request memory req) internal returns (bytes32) {
        return coordinator.sendRequest(req);
    }

    /**
    * @notice Validates the request
    */
    modifier recordRequestFulfillment(bytes32 _requestId, bytes memory proof, uint256 signature) {
        coordinator.recordRequestFulfillment(_requestId, proof, signature);
        _;
    }
}
