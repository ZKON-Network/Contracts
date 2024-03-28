// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ZkonRequests} from "./ZkonRequests.sol";
import {IZkonRequestsCoordinator} from "./IZkonRequestsCoordinator.sol";
import {Zkon} from "../Zkon.sol";

contract RequestExample is ZkonRequests {
    using Zkon for Zkon.Request;

    uint256 public volume;
    bytes32 private jobId;

    event RequestVolume(bytes32 indexed requestId, uint256 volume);

    constructor(IZkonRequestsCoordinator _coordinator, address _token) ZkonRequests(_coordinator, _token) {
    }
    /**
     * Create a Zkon request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
     function requestVolumeData() public returns (bytes32 requestId) {
        Zkon.Request memory req = buildRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // Set the URL to perform the GET request on
        req.add(
            "get",
            "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD"
        );

        // Set the path to find the desired data in the API response, where the response format is:
        // {"RAW":
        //   {"ETH":
        //    {"USD":
        //     {
        //      "VOLUME24HOUR": xxx.xxx,
        //     }
        //    }
        //   }
        //  }
        // request.add("path", "RAW.ETH.USD.VOLUME24HOUR");
        req.add("path", "RAW,ETH,USD,VOLUME24HOUR"); 

        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 10 ** 18;
        req.addInt("times", timesAmount);

        // Sends the request
        return sendRequest(req);
    }

    /**
     * Receive the response
     */
    function fulfill(
        bytes32 _requestId,
        uint256 signature,
        uint256 _volume,
        uint[2] memory a, uint[2] memory b1, uint[2] memory b2, uint[2] memory c
    ) public recordRequestFulfillment(_requestId, a, b1, b2, c, signature) {
        volume = _volume;
        emit RequestVolume(_requestId, _volume);
    }
}
