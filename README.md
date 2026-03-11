# AI Scanner Solidity Fixture

## Warning

This repository contains intentionally vulnerable Solidity code for scanner testing only.

- Do not deploy these contracts to any live network.
- Do not reuse this code in production, staging, tutorials, or audits as a safe reference.
- The bugs are deliberate and are present specifically to test whether tools follow imports and report inherited context.

This repo is a purpose-built scanner fixture for testing whether a tool follows imported Solidity files.

- `src/ContractA.sol` is intentionally large and intentionally buggy while still compiling and deploying under Foundry.
- `src/ContractB.sol` is intentionally thin. It imports `ContractA`, keeps a typed dependency on it, and has a smaller bug of its own.

The intended experiment is:

1. Submit only `ContractB.sol` to the scanner.
2. Check whether the scanner follows the import graph into `ContractA.sol`.
3. Compare findings reported directly on `ContractB` versus findings surfaced from `ContractA`.

## Intentionally Included Issues

`ContractA` includes patterns such as:

- external call before state update in `withdraw`
- `tx.origin` authorization in `setOperator` and `sweep`
- unprotected owner reset in `initializeOwner`
- unrestricted bookkeeping mutation in `allocateReward`, `batchCredit`, and `migrateLedger`
- insecure randomness in `pickLuckyUser`

`ContractB` includes:

- ignored return value from a low-level call in `forwardDeposit`

## Build

```sh
forge build
forge test
```
