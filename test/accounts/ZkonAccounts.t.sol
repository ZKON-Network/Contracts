// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../../src/accounts/ZkonAccounts.sol";
import "../../src/token/ZKONTestnet.sol";

contract CounterTest is Test {
    ZkonAccounts public accounts;
    ZKONTestnet public zkon;
    address public client;

    function setUp() public {
        zkon = new ZKONTestnet();
        accounts = new ZkonAccounts(address(zkon), 100 ether, address(7));
        client = address(3);
        accounts.registerClient(client);
    }

    function testDeposit() public {
        assertEq(accounts.amounts[client], 0 ether);
        accounts.depositTokens(client, 200 ether);
        accounts.depositTokens(client, 300 ether);
        assertEq(accounts.amounts[client], 500 ether);
    }

}
