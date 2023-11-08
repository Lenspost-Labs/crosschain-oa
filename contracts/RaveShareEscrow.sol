// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./IZoraNFTCreatorV1/IZoraNFTCreatorV1.sol";

contract RaveShareEscrowProxy {
    address public zoraNFTCreatorContract =
        0xfFFD7409031B1aeb731271C6C2D59771523Ff8a8;

    IZoraNFTCreatorV1 public zora = IZoraNFTCreatorV1(zoraNFTCreatorContract);

    function createNFT(DropParams calldata params) public returns (address) {
        IZoraNFTCreatorV1.SalesConfiguration memory salesConfig = params.saleConfig;
        // Call the external contract's createDrop function with the struct
        address newNFTContract = zora.createDrop(
            params.name,
            params.symbol,
            params.defaultAdmin,
            params.editionSize,
            params.royaltyBPS,
            params.fundsRecipient,
            salesConfig,
            params.metadataURIBase,
            params.metadataContractURI
        );

        // Return the address of the newly created NFT contract
        return newNFTContract;
    }
}
