// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "openzeppelin/token/ERC20/ERC20.sol";

contract ZKON is ERC20 {
    constructor () ERC20("ZKON", "ZKON") {        
        _mint(msg.sender, 1000000000 ether); //1B
    }

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }
}
