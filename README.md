# Escrow Contract [![License: MIT][license-badge]][license]

[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

A simple escrow contract empowering freelancers and clients to conduct business without intermediaries. Currently
supports only ERC20-based holdings and payments to further incentivise the usage of stable coins (USDC, USDT, etc.).

Still in development, needs further tests and an audit.

Made from [PaulRBerg's](https://github.com/PaulRBerg/ "Paul Razvan Berg's Profile")
[template](https://github.com/PaulRBerg/hardhat-template "Hardhat Template")

### GitHub Actions

This template comes with GitHub Actions pre-configured. Your contracts will be linted and tested on every push and pull
request made to the `main` branch.

Note though that to make this work, you must use your `INFURA_API_KEY` and your `MNEMONIC` as GitHub secrets.

You can edit the CI script in [.github/workflows/ci.yml](./.github/workflows/ci.yml).

## Usage

### Pre Requisites

Before being able to run any command, you need to create a `.env` file and set a BIP-39 compatible mnemonic as an
environment variable. You can follow the example in `.env.example`. If you don't already have a mnemonic, you can use
this [website](https://iancoleman.io/bip39/) to generate one.

Then, proceed with installing dependencies:

```sh
$ pnpm install
```

### Compile

Compile the smart contracts with Hardhat:

```sh
$ pnpm compile
```

### TypeChain

Compile the smart contracts and generate TypeChain bindings:

```sh
$ pnpm typechain
```

### Test

Run the tests with Hardhat:

```sh
$ pnpm test
```

### Lint Solidity

Lint the Solidity code:

```sh
$ pnpm lint:sol
```

### Lint TypeScript

Lint the TypeScript code:

```sh
$ pnpm lint:ts
```

### Coverage

Generate the code coverage report:

```sh
$ pnpm coverage
```

### Report Gas

See the gas usage per unit test and average gas per method call:

```sh
$ REPORT_GAS=true pnpm test
```

### Clean

Delete the smart contract artifacts, the coverage reports and the Hardhat cache:

```sh
$ pnpm clean
```

### Deploy

Deploy the contracts to Hardhat Network:

```sh
$ pnpm deploy:contracts"
```

### Tasks

#### Deploy Greeter

Deploy a new instance of the Greeter contract via a task:

```sh
$ pnpm task:deployGreeter --network ganache --greeting "Bonjour, le monde!"
```

#### Set Greeting

Run the `setGreeting` task on the Ganache network:

```sh
$ pnpm task:setGreeting --network ganache --greeting "Bonjour, le monde!" --account 3
```

## Tips

### Syntax Highlighting

If you use VSCode, you can get Solidity syntax highlighting with the
[hardhat-solidity](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity) extension.

## Local development with Ganache

### Install Ganache

```sh
$ npm i -g ganache
```

### Run a Development Blockchain

```sh
$ ganache -s test
```

> The `-s test` passes a seed to the local chain and makes it deterministic

Make sure to set the mnemonic in your `.env` file to that of the instance running with Ganache.

## License

This project is licensed under MIT.
