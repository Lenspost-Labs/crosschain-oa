// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {HubRestricted} from "lens/HubRestricted.sol";
import {Types} from "lens/Types.sol";
import {IPublicationActionModule} from "./interfaces/IPublicationActionModule.sol";
import {IModuleRegistry} from "./interfaces/IModuleRegistry.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {AggregatorV3Interface} from "./interfaces/IAggregatorV3Interface.sol";

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

    event Log(string variable, string message);
    event Log(string variable, address message);
    event Log(string variable, int message);

    address public immutable RAVESHARE_ADDRESS;
    IModuleRegistry public immutable MODULE_GLOBALS;
    AggregatorV3Interface public immutable maticFeed;

    constructor(
        address hub,
        address moduleGlobals,
        address RECIPIENT,
        address dataFeed
    ) HubRestricted(hub) {
        MODULE_GLOBALS = IModuleRegistry(moduleGlobals);
        RAVESHARE_ADDRESS = RECIPIENT;
        maticFeed = AggregatorV3Interface(dataFeed);
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

        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = maticFeed.latestRoundData();

        emit Log("price", price);

        uint96 mintFee = 1020000;
        // uint96 mintFee = 74400000;
        emit Log("currency", currency);

        if (!MODULE_GLOBALS.isErc20CurrencyRegistered(currency)) {
            revert CurrencyNotWhitelisted();
        }

        string memory initChain = _initChain[params.publicationActedProfileId][
            params.publicationActedId
        ];

        emit Log("initChain", initChain);

        IERC20(currency).transferFrom(
            params.transactionExecutor,
            RAVESHARE_ADDRESS,
            mintFee
        );

        // 75144956

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
