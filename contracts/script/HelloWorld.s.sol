// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

import {RaveShareMintOA} from "src/RaveShareMintOA.sol";
import {IRaveShare} from "src/interfaces/IRaveShare.sol";

contract HelloWorldScript is Script {
    function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address lensHubProxyAddress = 0xC1E77eE73403B8a7478884915aA599932A677870;
        address moduleGlobals = 0x8834aE494ADD3C56d274Fe88243526DBAB15dEF8;
        address RAVESHARE = 0x2745fBdfAe3A665856EF7191785F6a7BEA85aDDF;

        new RaveShareMintOA(lensHubProxyAddress, moduleGlobals, RAVESHARE);

        vm.stopBroadcast();
    }
}
