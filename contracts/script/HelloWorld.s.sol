// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

import {RaveShareMintOA} from "src/RaveShareMintOA.sol";

contract HelloWorldScript is Script {
    function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address lensHubProxyAddress = 0xC1E77eE73403B8a7478884915aA599932A677870;
        address moduleGlobals = 0x8834aE494ADD3C56d274Fe88243526DBAB15dEF8;
        address RAVESHARE = 0x77fAD8D0FcfD481dAf98D0D156970A281e66761b;
        address maticFeed = 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada;

        new RaveShareMintOA(lensHubProxyAddress, moduleGlobals, RAVESHARE,maticFeed);

        vm.stopBroadcast();
    }
}
