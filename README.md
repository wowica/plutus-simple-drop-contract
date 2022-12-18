# Simple Drop Plutus Smart Contract

This is a Plutus Smart Contract for the [Simple Drop dApp.](https://github.com/wowica/simple_drop)

This contract reads a list of pub key hashes from a text file and compiles them as part of the smart contract. This is similiar to how "snapshots" are taken in order to whitelist participants for a future airdrop.

When trying to spend the UTXO that's part of this contract, the validation checks whether the signer of the transaction, passed via `--required-signer-hash`, is part of the whitelist.

See the following files:

1. [DropValidator](src/SimpleDrop/DropValidator.hs) - logic which runs on-chain.  
2. [DeployDrop](src/SimpleDrop/DeployDrop.hs) - generates the ".plutus" script.


## Generating the Plutus Script

* If you haven't yet, be sure to [configure IOHK binary caches](https://github.com/input-output-hk/plutus-apps#iohk-binary-cache) in order to speed up the next step.
* From the project root folder, run `nix-shell` to start a nix shell. If for some reason IOG's binary cache repo is down, try running the following command:
     `nix-shell --option build-use-substitutes false`
* From inside the nix shell, type `cabal repl` to enter the cabal repl.
* From inside the repl, type `import SimpleDrop.DeployDrop` and then `writeDropValidator`.

This command should create a "simple_drop.plutus" file on the project root folder. 
This is the file which will be used as the source to generate a script adress.

## Generating the Address

The following command generates a script address from the plutus script:

```bash
cardano-cli address build --payment-script-file simple_drop.plutus \
     --out-file simple_drop.addr --testnet-magic $MAGIC
```

The value for $MAGIC dictates the testnet: 1 = preprod, 2 = preview.

**TODO:** Add more info to the README
