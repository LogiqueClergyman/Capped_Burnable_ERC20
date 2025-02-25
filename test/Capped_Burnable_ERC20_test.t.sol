// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Capped_Burnable_ERC20} from "../src/Capped_Burnable_ERC20.sol";

contract TokenTest is Test {
    Capped_Burnable_ERC20 public token;

    function setUp() public {
        token = new Capped_Burnable_ERC20("WeekT", "WKTT", 1000000, 18);
    }

    function mintToken() public {
        token.mint(address(this), 100);
    }

    function approve() public {
        token.approve(address(0x1), 100);
    }

    function beforeTestSetup(bytes4 testSelector) public pure returns (bytes[] memory beforeTestCalldata) {
        if (testSelector != this.testMint.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodeWithSignature("mintToken()");
        }
        if (testSelector == this.testTransferFrom.selector) {
            beforeTestCalldata = new bytes[](2);
            beforeTestCalldata[0] = abi.encodeWithSignature("mintToken()");
            beforeTestCalldata[1] = abi.encodeWithSignature("approve()");
        }
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

        vm.expectRevert("Balance insufficient");
        token.transfer(address(0x1), 1000000);
    }

    function testMint() public {
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 receiverBalanceBefore = token.balanceOf(address(this));
        token.mint(address(this), 100);
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 receiverBalanceAfter = token.balanceOf(address(this));
        assertEq(totalSupplyBefore + 100, totalSupplyAfter);
        assertEq(receiverBalanceBefore + 100, receiverBalanceAfter);

        vm.expectRevert();
        token.mint(address(this), 1000000);
    }

    function testMintCap() public {
        token.mint(address(this), 100);
        assertEq(token.totalSupply(), 200);
        vm.expectRevert();
        token.mint(address(this), 1000000);
    }

    // function testMintOnlyOwner() public {
    //     vm.prank(address(0x1));
    //     vm.expectRevert();
    //     token.mint(address(0x1), 100);
    // }

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
        vm.expectRevert("invalid address");
        token.approve(address(0), 100);
    }

    function testTransferFrom() public {
        uint256 senderBalanceBefore = token.balanceOf(address(this));
        uint256 receiverBalanceBefore = token.balanceOf(address(0x1));
        vm.prank(address(0x1));
        token.transferFrom(address(this), address(0x1), 100);
        uint256 senderBalanceAfter = token.balanceOf(address(this));
        uint256 receiverBalanceAfter = token.balanceOf(address(0x1));
        assertEq(senderBalanceBefore - 100, senderBalanceAfter);
        assertEq(receiverBalanceBefore + 100, receiverBalanceAfter);
        assertEq(token.allowance(address(this), address(0x1)), 0);
    }
}
