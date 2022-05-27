# Coal Storage Hardhat Implementation

An upgradable static database implementation utilizing [EIP-2535 Diamonds](https://github.com/ethereum/EIPs/issues/2535) and [Diamond Storage](https://dev.to/mudgen/how-diamond-storage-works-90e).

**Note:** This implementation uses [diamond-1](https://github.com/mudgen/diamond-1-hardhat). Other optimizations can be found [here](https://github.com/mudgen/diamond).

## Usage

Static data is stored in coal faces, which double as diamond facets. View `contracts/faces/Test1Face.sol` and `contracts/faces/Test2Face.sol` for reference. Currently both files contain 1,000 random addresses in bytes constants.

The `contracts/facets/CoalStorageFacet.sol` file is used to enumerate or retrieve information from coal faces.

## Deployment

```console
npx hardhat run scripts/deploy.js
```

**Note:** This is the same as deploying a diamond, only with an extra facet in `CoalStorageFacet`.

## Tests

```console
npx hardhat test
```

## Author

This example implementation was written by NFTyte.

Contact:

- https://twitter.com/nftyte

## License

MIT license. See the license file.
Anyone can use or modify this software for their purposes.