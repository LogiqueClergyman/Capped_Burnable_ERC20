// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Capped_Burnable_ERC20} from "../src/Capped_Burnable_ERC20.sol";

contract TokenTest is Test {
    Capped_Burnable_ERC20 public token;

    function setUp() public {
        token = new Capped_Burnable_ERC20("WeekT", "WKTT", 1000000, 18);
        testMint();
        testApprove();
    }

    function testDeploy() public view {
        assertEq(token.name(), "WeekT");
        assertEq(token.symbol(), "WKTT");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 100);
        assertEq(token.cap(), 1000000);
    }

    function testTransfer() public {
        uint256 senderBalanceBefore = token.balanceOf(address(this));
        uint256 receiverBalanceBefore = token.balanceOf(address(0x1));
        token.transfer(address(0x1), 100);
        uint256 senderBalanceAfter = token.balanceOf(address(this));
        uint256 receiverBalanceAfter = token.balanceOf(address(0x1));
        assertEq(senderBalanceBefore - 100, senderBalanceAfter);
        assertEq(receiverBalanceBefore + 100, receiverBalanceAfter);
    }

    function testMint() public {
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 receiverBalanceBefore = token.balanceOf(address(this));
        token.mint(address(this), 100);
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 receiverBalanceAfter = token.balanceOf(address(this));
        assertEq(totalSupplyBefore + 100, totalSupplyAfter);
        assertEq(receiverBalanceBefore + 100, receiverBalanceAfter);
    }

    function testBurn() public {
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 senderBalanceBefore = token.balanceOf(address(this));
        token.burn(100);
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 senderBalanceAfter = token.balanceOf(address(this));
        assertEq(totalSupplyBefore - 100, totalSupplyAfter);
        assertEq(senderBalanceBefore - 100, senderBalanceAfter);
    }

    function testApprove() public {
        token.approve(address(0x1), 100);
        assertEq(token.allowance(address(this), address(0x1)), 100);
    }

    function testTransferFrom() public {
        uint256 senderBalanceBefore = token.balanceOf(address(this));
        uint256 receiverBalanceBefore = token.balanceOf(address(0x1));
        console.log(
            "callerAllowance",
            token.allowance(address(this), address(0x1))
        );
        console.log("senderBalanceBefore", senderBalanceBefore);
        vm.prank(address(0x1));
        token.transferFrom(address(this), address(0x1), 100);
        uint256 senderBalanceAfter = token.balanceOf(address(this));
        uint256 receiverBalanceAfter = token.balanceOf(address(0x1));
        assertEq(senderBalanceBefore - 100, senderBalanceAfter);
        assertEq(receiverBalanceBefore + 100, receiverBalanceAfter);
    }
}
