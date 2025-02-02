# Numo 🟩 

[![Fuzz Testing](https://github.com/Uniswap/uniswap-v3-core/actions/workflows/fuzz-testing.yml/badge.svg)](https://github.com/numocash/numo/actions/workflows/fuzz-testing.yml)
[![npm version](https://img.shields.io/npm/v/@uniswap/v3-core/latest.svg)](https://www.npmjs.com/package/@numocash/numo/v/latest)

### A market maker for call options on FX pairs (e.g. USD/EUR).

The smart contract suite is a Uniswap V4 hook and is inspired by @primitivefinance's open source [RMM-01](https://github.com/primitivefinance/rmm) implementation and the [replicating market makers](https://arxiv.org/abs/2103.14769) paper that first proved any option strategy can be constructed using CFMMs.

Liquidity providers on Numo are sellers of european-style call options who earn a premium from "theta decay." In the context of decentralized finance, these premiums are paid by traders who swap on the underlying liquidity. In the future, a batch auction can be implemented to match buyers and sellers or calls could be directly sold on an exisiting options market (e.g. CME). These would optimize the premiums earned for option sellers.

Numo deploys a `market` instance for each FX pair. Each `market` can handle any two arbitrary ERC-20 token and follows the standard naming conventions seen in traditional FX markets (`base`/`quote`).

## Set up

*requires [foundry](https://book.getfoundry.sh)*

```
forge install
forge test
```

<details>
<summary>Updating to v4 dependencies</summary>

```bash
forge install v4-core
```

</details>

### Local Development (Anvil)

Other than writing unit tests (recommended!), you can only deploy & test hooks on [anvil](https://book.getfoundry.sh/anvil/)

```bash
# start anvil, a local EVM chain
anvil

# in a new terminal
forge script script/Anvil.s.sol \
    --rpc-url http://localhost:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    --broadcast
```

<details>
<summary><h3>Testnets</h3></summary>

NOTE: 11/21/2023, the Goerli deployment is out of sync with the latest v4. **It is recommend to use local testing instead**

~~For testing on Goerli Testnet the Uniswap Foundation team has deployed a slimmed down version of the V4 contract (due to current contract size limits) on the network.~~

~~The relevant addresses for testing on Goerli are the ones below~~

```bash
POOL_MANAGER = 0x0
POOL_MODIFY_POSITION_TEST = 0x0
SWAP_ROUTER = 0x0
```

Update the following command with your own private key:

```
forge script script/00_Counter.s.sol \
--rpc-url https://rpc.ankr.com/eth_goerli \
--private-key [your_private_key_on_goerli_here] \
--broadcast
```

### *Deploying your own Tokens For Testing*

Because V4 is still in testing mode, most networks don't have liquidity pools live on V4 testnets. We recommend launching your own test tokens and expirementing with them that. We've included in the templace a Mock UNI and Mock USDC contract for easier testing. You can deploy the contracts and when you do you'll have 1 million mock tokens to test with for each contract. See deployment commands below

```
forge create script/mocks/mUNI.sol:MockUNI \
--rpc-url [your_rpc_url_here] \
--private-key [your_private_key_on_goerli_here]
```

```
forge create script/mocks/mUSDC.sol:MockUSDC \
--rpc-url [your_rpc_url_here] \
--private-key [your_private_key_on_goerli_here]
```

</details>

---
