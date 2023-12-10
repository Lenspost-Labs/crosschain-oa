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
    mapping(uint256 profileId => mapping(uint256 pubId => string mintChain))
        public _mintChain;

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
        uint256 profileId,
        string mintChain
    );

    event Log(string variable, string message);
    event Log(string variable, address message);
    event Log(string variable, int message);

    address public immutable RAVESHARE_ADDRESS;
    IModuleRegistry public immutable MODULE_GLOBALS;
    AggregatorV3Interface public immutable maticFeed;
    AggregatorV3Interface public immutable ethFeed;

    constructor(
        address hub,
        address moduleGlobals,
        address RECIPIENT,
        address maticUSDFeed,
        address ethUSDFeed,
        address moduleOwner
    ) HubRestricted(hub) LensModuleMetadata(moduleOwner) {
        MODULE_GLOBALS = IModuleRegistry(moduleGlobals);
        RAVESHARE_ADDRESS = RECIPIENT;
        maticFeed = AggregatorV3Interface(maticUSDFeed);
        ethFeed = AggregatorV3Interface(ethUSDFeed);
    }

    function initializePublicationAction(
        uint256 profileId,
        uint256 pubId,
        address /* transactionExecutor */,
        bytes calldata data
    ) external override onlyHub returns (bytes memory) {
        (address mintAddress, string memory mintChain) = abi.decode(
            data,
            (address, string)
        );
        _mintAddress[profileId][pubId] = mintAddress;
        _mintChain[profileId][pubId] = mintChain;
        return data;
    }

    function getMintAddress(
        uint256 profileId,
        uint256 pubId
    ) external view returns (address) {
        return _mintAddress[profileId][pubId];
    }

    function getMintChain(
        uint256 profileId,
        uint256 pubId
    ) external view returns (string memory) {
        return _mintChain[profileId][pubId];
    }

    function processPublicationAction(
        Types.ProcessActionParams calldata params
    ) external override returns (bytes memory) {
        address currency = abi.decode(params.actionModuleData, (address));
        string memory mintChain = _mintChain[params.publicationActedProfileId][
            params.publicationActedId
        ];
        address mint_add = _mintAddress[params.publicationActedProfileId][
            params.publicationActedId
        ];

        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = maticFeed.latestRoundData();

        (
            uint80 roundID2,
            int price2,
            uint startedAt2,
            uint timeStamp2,
            uint80 answeredInRound2
        ) = ethFeed.latestRoundData();

    // price = 90196782 (0.000090196782 * 10 ** 18)
        emit Log("price", price);

    // price2 = 234600000000 (0.0002346 * 10 ** 18)
        emit Log("price2", price2);

        // uint256 mintFee = 0.000777;
        uint256 mintFee = 0.000777 * 10 ** 6;
        uint256 maticPrice = uint256(price);
        uint256 ethPrice = uint256(price2);

        // 9205998
        // 2025367

        uint256 mintFeeInMatic = (mintFee * ethPrice) / (maticPrice);
        
        
        emit Log("mintFeeInMatic", int(mintFeeInMatic));
        emit Log("currency", currency);
        emit Log("chain", mintChain);

        if (!MODULE_GLOBALS.isErc20CurrencyRegistered(currency)) {
            revert CurrencyNotWhitelisted();
        }

        IERC20(currency).transferFrom(
            params.transactionExecutor,
            RAVESHARE_ADDRESS,
            mintFeeInMatic
        );

        emit ERC20TransactionSuccess(
            params.transactionExecutor,
            mint_add,
            currency,
            mintFeeInMatic,
            params.publicationActedId,
            params.publicationActedProfileId,
            mintChain
        );

        return abi.encode(RAVESHARE_ADDRESS, currency, mintFee);
    }
}
