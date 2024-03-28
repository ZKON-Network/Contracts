// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Zkon} from "../Zkon.sol";
import {IZkonRequestsCoordinator} from "./IZkonRequestsCoordinator.sol";
import "../utils/TransferHelper.sol";
import "../utils/GrothVerifier.sol";
import "openzeppelin/access/AccessControl.sol";

contract ZkonRequestsCoordinator is IZkonRequestsCoordinator, AccessControl, GrothVerifier {
    
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
        emit Requested(requestId, encodeRequest(req));
        TransferHelper.safeTransferFrom(zkonToken, msg.sender, treasury, feePrice);
        requestCount += 1;

        return requestId;
    }

    function encodeRequest(Zkon.Request memory _req) private view returns (bytes memory) {
        uint256 version = 1;
        return abi.encode(
            _req.id,
            _req.callbackAddress,
            _req.callbackFunctionId,
            _req.nonce,
            version,
            _req.buf.buf
        );
    }

    function recordRequestFulfillment(bytes32 requestId, bytes memory proof, uint256 signature) external {
        require(msg.sender == pendingRequests[requestId], "Source must be the contract of the request");
        require(tx.origin == address(0x116d59E20c770CB87405814e702C5f170CC42609), "Invalid oracle address"); // ToDo
        
        uint256[] memory zkArgs = new uint256[](1);
        zkArgs[0] = signature;
        // require(verifyProof(proof, zkArgs), "Invalid ZK proof"); // ToDo Uncomment

        delete pendingRequests[requestId];
        emit Fulfilled(requestId);
    }

    function verifyingKey() internal override pure returns (VerifyingKey memory vk) {
        // ToDo: Not final keys
        vk.alfa1 = Pairing.G1Point(uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724), uint256(77246667709895178699614031713260878285402552769126818938669989071815220783895));
        vk.beta2 = Pairing.G2Point([uint256(77246667709895178699614031713260878285402552769126818938669989071815220783895), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724)], [uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724)]);
        vk.gamma2 = Pairing.G2Point([uint256(77246667709895178699614031713260878285402552769126818938669989071815220783895), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724)], [uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724)]);
        vk.delta2 = Pairing.G2Point([uint256(77246667709895178699614031713260878285402552769126818938669989071815220783895), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724)], [uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724)]);
        vk.IC[0] = Pairing.G1Point(uint256(77246667709895178699614031713260878285402552769126818938669989071815220783895), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724));
        vk.IC[1] = Pairing.G1Point(uint256(77246667709895178699614031713260878285402552769126818938669989071815220783895), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724));
        vk.IC[2] = Pairing.G1Point(uint256(77246667709895178699614031713260878285402552769126818938669989071815220783895), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724));
        vk.IC[3] = Pairing.G1Point(uint256(77246667709895178699614031713260878285402552769126818938669989071815220783895), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724));
        vk.IC[4] = Pairing.G1Point(uint256(77246667709895178699614031713260878285402552769126818938669989071815220783895), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724));
        vk.IC[5] = Pairing.G1Point(uint256(77246667709895178699614031713260878285402552769126818938669989071815220783895), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724));
        vk.IC[6] = Pairing.G1Point(uint256(77246667709895178699614031713260878285402552769126818938669989071815220783895), uint256(85901616286622876259745130968697875287639105406807869578098182913297981371724));
    }
}
