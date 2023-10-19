// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ZKON.sol";

// This contract is for testing purposes only. Not suitable for mainnet.
contract ZKONTestnet is ZKON {

    function mint() public {
        _mint(msg.sender, 100000 ether); // 100k
    }
    
}
