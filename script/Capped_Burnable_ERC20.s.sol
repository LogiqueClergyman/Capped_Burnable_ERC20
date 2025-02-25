// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Capped_Burnable_ERC20} from "../src/Capped_Burnable_ERC20.sol";

contract Deploy is Script {
    function run() external returns (Capped_Burnable_ERC20) {
        vm.startBroadcast();
        Capped_Burnable_ERC20 token = new Capped_Burnable_ERC20("WeekT", "WKTT", 1000000, 18);
        vm.stopBroadcast();
        console.log("Token deployed at address: ", address(token));
        return token;
    }
}
