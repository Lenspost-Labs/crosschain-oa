// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {HubRestricted} from "lens/HubRestricted.sol";
import {Types} from "lens/Types.sol";
import {IPublicationActionModule} from "./interfaces/IPublicationActionModule.sol";
import {IModuleGlobals} from "./interfaces/IModuleGlobals.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IRaveShare} from "./interfaces/IRaveShare.sol";

contract RaveShareMintOA is HubRestricted, IPublicationActionModule {
    mapping(uint256 profileId => mapping(uint256 pubId => string _initChain))
        internal _initChain;

    error CurrencyNotWhitelisted();

    event ERC20TransactionSuccess(
        address indexed sender,
        address indexed receiver,
        address currency,
        uint256 amount,
        uint256 pubId,
        uint256 profileId
    );

    event Log(string message);

    address public immutable RAVESHARE_ADDRESS;
    IModuleGlobals public immutable MODULE_GLOBALS;

    constructor(address hub, address moduleGlobals, address RECIPIENT) HubRestricted(hub) {
        MODULE_GLOBALS = IModuleGlobals(moduleGlobals);
        RAVESHARE_ADDRESS = RECIPIENT;
    }

    function initializePublicationAction(
        uint256 profileId,
        uint256 pubId,
        address /* transactionExecutor */,
        bytes calldata data
    ) external override onlyHub returns (bytes memory) {
        string memory initChain = abi.decode(data, (string));

        // _tipReceivers[profileId][pubId] = tipReceiver;
        _initChain[profileId][pubId] = initChain;

        return data;
    }

    function processPublicationAction(
        Types.ProcessActionParams calldata params
    ) external override returns (bytes memory) {
        address currency = abi.decode(params.actionModuleData, (address));

        uint96 mintFee = 2;

        if (!MODULE_GLOBALS.isCurrencyWhitelisted(currency)) {
            revert CurrencyNotWhitelisted();
        }

        string memory initChain = _initChain[params.publicationActedProfileId][
            params.publicationActedId
        ];


        IERC20(currency).transferFrom(
            params.transactionExecutor,
            RAVESHARE_ADDRESS,
            mintFee
        );

        emit ERC20TransactionSuccess(
            params.transactionExecutor,
            RAVESHARE_ADDRESS,
            currency,
            mintFee,
            params.publicationActedId,
            params.publicationActedProfileId
        );

        return abi.encode(RAVESHARE_ADDRESS, currency, mintFee);
    }
}
