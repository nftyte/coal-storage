# Coal Storage Hardhat Implementation

An upgradable static database implementation utilizing [EIP-2535 Diamonds](https://github.com/ethereum/EIPs/issues/2535) and [Diamond Storage](https://dev.to/mudgen/how-diamond-storage-works-90e).

**Note:** This implementation uses [diamond-1](https://github.com/mudgen/diamond-1-hardhat). Other optimizations can be found [here](https://github.com/mudgen/diamond).

## Usage

Static data is stored in coal faces, which double as diamond facets. View `contracts/faces/Test1Face.sol` and `contracts/faces/Test2Face.sol` for reference. Both files contain 1,000 random addresses in bytes constants.

The `contracts/facets/CoalStorageFacet.sol` file is used to connect, enumerate, and retrieve information from coal faces externally. The internal implementation is available in `contracts/libraries/LibCoal.sol`.

## Deployment

```console
npx hardhat run scripts/deploy.js
```

**Note:** This is the same as deploying a diamond, only with an extra facet in `CoalStorageFacet`.

## Tests

```console
npx hardhat test
```

## Contributing

This is a WIP reference implementation. To contribute, feel free to open an issue or contact me.

## Author

This example implementation was written by NFTyte.

Contact: https://twitter.com/nftyte

## License

MIT license. See the license file.
Anyone can use or modify this software for their purposes.