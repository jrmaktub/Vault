// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/OceanToken.sol";

contract DeployOceanToken is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy the OceanToken contract
        OceanToken token = new OceanToken();
        console.log("OceanToken deployed at:", address(token));

        vm.stopBroadcast();
    }
}
