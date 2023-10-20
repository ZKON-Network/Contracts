// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../../src/accounts/ZkonAccounts.sol";
import "../../src/token/ZKONTestnet.sol";

contract ZkonAccountsTest is Test {
    ZkonAccounts public accounts;
    ZKONTestnet public zkon;
    address public client;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    function setUp() public {
        zkon = new ZKONTestnet();
        accounts = new ZkonAccounts(address(zkon), 100 ether, address(7));
        client = address(3);
        accounts.registerClient(client);
        zkon.transfer(address(1), 1000 ether);
        vm.prank(address(1));
        zkon.approve(address(accounts), 1000 ether);
    }

    function testDepositAndWithdrawTokens() public {
        assertEq(zkon.balanceOf(address(1)), 1000 ether);
        assertEq(accounts.getTokens(client), 0 ether);

        vm.prank(address(1));
        accounts.depositTokens(client, 200 ether);
        vm.prank(address(1));
        accounts.depositTokens(client, 300 ether);

        assertEq(accounts.getTokens(client), 500 ether);
        assertEq(zkon.balanceOf(address(accounts)), 500 ether);
        assertEq(zkon.balanceOf(address(1)), 1000 ether - 500 ether);

        vm.prank(address(1));
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000001 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000");
        accounts.withdrawTokens(client, 100);
        assertEq(zkon.balanceOf(address(1)), 1000 ether - 500 ether);

        accounts.grantRole(DEFAULT_ADMIN_ROLE, address(1));
        vm.prank(address(1));
        accounts.withdrawTokens(client, 100 ether);
        assertEq(zkon.balanceOf(address(1)), 1000 ether - 400 ether);
    }

    function testShardStorage() public {
        uint256 user = 42;

        uint256 num = 27;
        bytes memory shards = abi.encodePacked(num);

        vm.prank(address(1));
        vm.expectRevert("Invalid auth");
        accounts.pause(client);


        vm.prank(address(1));
        vm.expectRevert("Not enough balance");
        accounts.storeShards(client, user, shards);

        vm.prank(address(1));
        accounts.depositTokens(client, 200 ether);
        vm.prank(address(1));
        vm.expectRevert("Invalid auth");
        accounts.storeShards(client, user, shards);

        accounts.grantRole(DEFAULT_ADMIN_ROLE, address(1));
        vm.prank(address(1));
        accounts.storeShards(client, user, shards);

        assertEq(accounts.getShards(client, user), shards);

        vm.prank(address(1));
        accounts.pause(client);

        vm.expectRevert("Client disabled");
        accounts.getShards(client, user);

        accounts.registerClient(client);
        assertEq(accounts.getShards(client, user), shards);
    }


}
