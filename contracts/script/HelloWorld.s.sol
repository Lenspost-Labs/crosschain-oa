// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

import {RaveShareMintOA} from "src/RaveShareMintOA.sol";

contract HelloWorldScript is Script {
    function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address lensHubProxyAddress = 0x4fbffF20302F3326B20052ab9C217C44F6480900;
        address moduleGlobals = 0x4BeB63842BB800A1Da77a62F2c74dE3CA39AF7C0;
        
        address RAVESHARE = 0x77fAD8D0FcfD481dAf98D0D156970A281e66761b;
        address maticUSDFeed = 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada;
        address ethUSDFeed = 0x0715A7794a1dc8e42615F059dD6e406A6594651A;

        address moduleOwner = 0x0CF97e9C28C5b45C9Dc20Dd8c9d683E0265190CB;

        new RaveShareMintOA(lensHubProxyAddress, moduleGlobals, RAVESHARE,maticUSDFeed,ethUSDFeed, moduleOwner);

        vm.stopBroadcast();
    }
}
