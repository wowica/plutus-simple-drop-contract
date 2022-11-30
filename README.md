# Simple Drop Plutus Smart Contract

This is a Plutus Smart Contract for the [Simple Drop dApp.](https://github.com/wowica/simple_drop)

This contract reads a list of pub key hashes and stores them as part of the Datum. This is similiar to how "snapshots" are taken in order to whitelist participants for a future airdrop.

When trying to spend the UTXO that's part of this contract, the validation checks whether the signer of the transaction, passed via `--required-signer-hash`, is part of the whitelist.

See the following files:

1. [DropValidator](src/SimpleDrop/DropValidator.hs) - logic which runs on-chain.  
2. [DeployDrop](src/SimpleDrop/DeployDrop.hs) - generates the ".plutus" script.


## How to Run

* From the project root folder, run `nix-shell` to start a nix shell.
* From inside the nix shell, type `cabal repl` to enter the cabal repl.
* From inside the repl, type `import SimpleDrop.DeployDrop` and then `writeDropValidator`.

This command should create a "simple_drop.plutus" file on the project root folder. 
This is the file which will be used as the source to generate a script adress.

**TODO:** Add more info to the README