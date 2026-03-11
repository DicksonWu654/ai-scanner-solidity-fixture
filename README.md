# AI Scanner Solidity Fixture

## Warning

This repository contains intentionally vulnerable Solidity code for scanner testing only.

- Do not deploy these contracts to any live network.
- Do not reuse this code in production, staging, tutorials, or audits as a safe reference.
- The bugs are deliberate and are present specifically to test whether tools follow imports and report inherited context.

This repo is a purpose-built scanner fixture for testing whether a tool follows imported Solidity files.

- `src/ContractA.sol` is intentionally large, interaction-heavy, and intentionally buggy while still compiling and deploying under Foundry.
- `src/ContractA.sol` also imports helper modules in `src/modules/` so the dependency graph extends beyond a single file.
- `src/ContractB.sol` now inherits from `ContractA` and exposes explicit wrapper functions that call `super`, which is useful for scanners that reason at the function level.

The intended experiment is:

1. Submit only `ContractB.sol` to the scanner.
2. Check whether the scanner follows the import graph into `ContractA.sol` and its imported helper modules.
3. Check whether findings are surfaced through the explicit wrapper functions in `ContractB`.
4. Compare findings reported directly on `ContractB` versus findings surfaced from inherited and imported code.

## Intentionally Included Issues

`ContractA` includes patterns such as:

- external call before state update in `withdraw`
- `tx.origin` authorization in `setOperator` and `sweep`
- unprotected owner reset in `initializeOwner`
- unrestricted bookkeeping mutation in `allocateReward`, `batchCredit`, `migrateLedger`, and multiple vault/campaign flows
- insecure randomness in `pickLuckyUser`
- interaction-heavy vault, strategy, proposal, campaign, payment-stream, and synthetic route logic

`ContractB` includes:

- ignored return value from a low-level call in `forwardDeposit`

## Build

```sh
forge build
forge test
```
