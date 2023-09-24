# Proof of Something

PoS is an ironic misnomer.

So the idea is pivioting off of two concepts:
- 6551 with proof of humanhood
- 6551 owning multiple 4337 wallets with the option of anychain

But what if my proof of humanhood is only on one chain?

Well the easy answer would be offchain verification, but that makes Vitalik cry.

The solution is to be a PoS and use waaaay too much gas!

### Here's how it works!

1. create a worldcoin ID to create a proof of humanhood
2. connect your wallet via WAGMI
3. call 6551 mint, which will call worldcoin prover
4. send that data to your create account on the 721 contract with 6551 implented, the proof will be forwarded to worldcoin
5. send a 4337 userop to create your 4337 account
6. send userop transactions from any of your 4337 accounts
   
### But what about other chains!?

To make our lives easier we call other chains using hyperlane but any validator/relay oracle combo that can send messages will work. If we want to use a proof their are three step that need to happen.

1. have the chain A call the oracle to chain B
2. get what we want for desired proof on chain B, then call the oracle to chain A
3. our proof is satisfied so we execute on chain A


// PoSImplementation.sol
forge create --rpc-url=https://alpha-rpc.scroll.io/l2 --legacy  ./src/PoSImplementation.sol:PoSImplementation

forge create src/PoSImplementation.sol:PoSImplementation --rpc-url https://still-orbital-theorem.base-goerli.quiknode.pro/7778efb6a98a8757645ed9ead407fd614d3964b9/ --verify

forge create src/PoSImplementation.sol:PoSImplementation --rpc-url https://erpc.apothem.network --legacy

forge create src/PoSImplementation.sol:PoSImplementation --rpc-url https://alfajores-forno.celo-testnet.org --legacy

forge create src/PoSImplementation.sol:PoSImplementation --rpc-url https://proxy.devnet.neonlabs.org/solana




// PoS721.sol
forge create src/PoS721.sol:PoS721 --rpc-url=https://alpha-rpc.scroll.io/l2 --legacy --constructor-args 0x9100621e7b609138cC7E07035Ba476b249D42EA3 0x9100621e7b609138cC7E07035Ba476b249D42EA3 1000 0

forge create src/PoS721.sol:PoS721 --rpc-url https://still-orbital-theorem.base-goerli.quiknode.pro/7778efb6a98a8757645ed9ead407fd614d3964b9/  --constructor-args 0x9100621e7b609138cC7E07035Ba476b249D42EA3 0x9100621e7b609138cC7E07035Ba476b249D42EA3 1000 0

forge create src/PoS721.sol:PoS721 --rpc-url https://erpc.apothem.network --legacy  --constructor-args 0x9100621e7b609138cC7E07035Ba476b249D42EA3 0x9100621e7b609138cC7E07035Ba476b249D42EA3 1000 0

forge create src/PoS721.sol:PoS721 --rpc-url https://alfajores-forno.celo-testnet.org --legacy --constructor-args 0x9100621e7b609138cC7E07035Ba476b249D42EA3 0x9100621e7b609138cC7E07035Ba476b249D42EA3 1000 0

forge create src/PoS721.sol:PoS721 --rpc-url https://proxy.devnet.neonlabs.org/solana --constructor-args 0x9100621e7b609138cC7E07035Ba476b249D42EA3 0x9100621e7b609138cC7E07035Ba476b249D42EA3 1000 0


https://erpc.apothem.network
https://alfajores-forno.celo-testnet.org
https://proxy.devnet.neonlabs.org/solana


Goreli:
Deployer: 0xfF65689a4AEB6EaDd18caD2dE0022f8Aa18b67de
Deployed to: 0x9100621e7b609138cC7E07035Ba476b249D42EA3
Transaction hash: 0x75132bc495e390ea8b65cbc650a43ff8383523f83c616f7b5a160953be178002

Deployer: 0xfF65689a4AEB6EaDd18caD2dE0022f8Aa18b67de
Deployed to: 0x6dDD392833eC341da955bE9baC5Ab5aff69AF5d6
Transaction hash: 0xd270d37650679ed8f9140b0cb1c6efde1d084e6a61c02ec8dddd802adb006eee

XDC:
Deployer: 0xfF65689a4AEB6EaDd18caD2dE0022f8Aa18b67de
Deployed to: 0x5E08D920B38a62a779eb1748564f8776Bb55bb0A
Transaction hash: 0xc40712e819757c1364a636844f1048abf98e4e875b7755da056ed44b651330b2

Celo:
Deployer: 0xfF65689a4AEB6EaDd18caD2dE0022f8Aa18b67de
Deployed to: 0x1151F98ee70a8D640250BC00bCb94F55ab652581
Transaction hash: 0xe3402441e59c1fc0c33c76cc680063f975c89a93d5afcdd5ed1167576142902f

Scroll:
https://sepolia-blockscout.scroll.io/tx/0x7e61c7686b16dc57d431836c50954e389d6b957862dd08af3e6e4a9918cd8296


https://sepolia-blockscout.scroll.io/tx/0x7e61c7686b16dc57d431836c50954e389d6b957862dd08af3e6e4a9918cd8296

Neon:
https://devnet.neonscan.org/search?q=0xd240bed32349d25edc1fc0bae4f1105daeb51753338081a65ecbad3de1734b3d