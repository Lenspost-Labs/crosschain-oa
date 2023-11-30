// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {HubRestricted} from "lens/HubRestricted.sol";
import {Types} from "lens/Types.sol";
import {IPublicationActionModule} from "./interfaces/IPublicationActionModule.sol";
import {IModuleRegistry} from "./interfaces/IModuleRegistry.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {AggregatorV3Interface} from "./interfaces/IAggregatorV3Interface.sol";
import {LensModuleMetadata} from "lens/LensModuleMetadata.sol";

contract RaveShareMintOA is
    HubRestricted,
    IPublicationActionModule,
    LensModuleMetadata
{
    mapping(uint256 profileId => mapping(uint256 pubId => address mintAddress))
        internal _mintAddress;

    function supportsInterface(
        bytes4 interfaceID
    ) public pure override returns (bool) {
        return
            interfaceID == type(IPublicationActionModule).interfaceId ||
            super.supportsInterface(interfaceID);
    }

    error CurrencyNotWhitelisted();

    event ERC20TransactionSuccess(
        address indexed sender,
        address indexed mint_add,
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
        address dataFeed,
        address moduleOwner
    ) HubRestricted(hub) LensModuleMetadata(moduleOwner){
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
        address mintAddress = abi.decode(data, (address));
        _mintAddress[profileId][pubId] = mintAddress;
        emit Log("mintAddress", mintAddress);
        return data;
    }

    function getInitChain(
        uint256 profileId,
        uint256 pubId
    ) external view returns (address) {
        return _mintAddress[profileId][pubId];
    }

    function processPublicationAction(
        Types.ProcessActionParams calldata params
    ) external override returns (bytes memory) {
        address currency = abi.decode(params.actionModuleData, (address));
        address mint_add = _mintAddress[params.publicationActedProfileId][
            params.publicationActedId
        ];

        emit Log("initChain", mint_add);

        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = maticFeed.latestRoundData();

        emit Log("price", price);

        uint96 mintFee = 1020000;
        // uint96 maticUSD = 74400000;
        // uint96 maticFee = (price * mintFee) / maticUSD;
        emit Log("currency", currency);

        if (!MODULE_GLOBALS.isErc20CurrencyRegistered(currency)) {
            revert CurrencyNotWhitelisted();
        }

        IERC20(currency).transferFrom(
            params.transactionExecutor,
            RAVESHARE_ADDRESS,
            mintFee
        );

        emit ERC20TransactionSuccess(
            params.transactionExecutor,
            mint_add,
            currency,
            mintFee,
            params.publicationActedId,
            params.publicationActedProfileId
        );

        return abi.encode(RAVESHARE_ADDRESS, currency, mintFee);
    }
}
