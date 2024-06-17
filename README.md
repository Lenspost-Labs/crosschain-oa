# Raveshare

### A Raveshare creation

This is a cross-chain open action, which uses off-chain triggers - this can be used with any chain, the off-chain trigger is located at https://github.com/Lenspost-Labs/mint-server 

This was used to enable the user, to pay using a currency on polygon and mint nft on zora to the user.

Link to contract on mumbai testnet

[https://mumbai.polygonscan.com/address/0xb2cb3a2617431699db5435303f0c1264c4dcc9a4](https://mumbai.polygonscan.com/address/0x0d8cb52b3889c9911b589e105379acc6ea5e7cac)

Link to contract on polygon mainnet 

[https://polygonscan.com/address/0x410688fc60028C805Bdf8592A6504A0096927911](https://polygonscan.com/address/0x410688fc60028C805Bdf8592A6504A0096927911)

#### Steps to deploy 

source .env

forge script script/Deploy.s.sol:Deploy --rpc-url $MUMBAI_RPC_URL --broadcast --verify -vvvv

Link to PR merged to Lens Protocol - https://github.com/lens-protocol/verified-modules/pull/8
