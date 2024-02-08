// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Zkon} from "../Zkon.sol";

interface IZkonRequestsCoordinator {

    event Requested(bytes32 indexed id);
    event Fulfilled(bytes32 indexed id);
    event Cancelled(bytes32 indexed id);

    /**
    * @notice Creates a request to the stored oracle address
    * @param req The initialized Zkon Request
    * @return requestId The request ID
    */
    function sendRequest(Zkon.Request memory req) external returns (bytes32);

    /**
    * @notice Checks if the request is valid
    * @param requestId The request ID
    * @param proof The ZK proof
    * @param signature The signature used as a public arg on the zk circuit
    */
    function recordRequestFulfillment(bytes32 requestId, bytes memory proof, uint256 signature) external;
}