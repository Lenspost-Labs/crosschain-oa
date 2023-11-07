// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

struct SalesConfiguration {
    uint104 publicSalePrice;
    uint32 maxSalePurchasePerAddress;
    uint64 publicSaleStart;
    uint64 publicSaleEnd;
    uint64 presaleStart;
    uint64 presaleEnd;
    bytes32 presaleMerkleRoot;
}

struct DropParams {
    string name;
    string symbol;
    address defaultAdmin;
    uint64 editionSize;
    uint16 royaltyBPS;
    address payable fundsRecipient;
    SalesConfiguration saleConfig;
    string metadataURIBase;
    string metadataContractURI;
}

interface IZoraNFTCreatorV1 {
    function createDrop(
        string calldata name,
        string calldata symbol,
        address defaultAdmin,
        uint64 editionSize,
        uint16 royaltyBPS,
        address payable fundsRecipient,
        SalesConfiguration calldata saleConfig,
        string calldata metadataURIBase,
        string calldata metadataContractURI
    ) external returns (address);
}