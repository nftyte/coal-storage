# Coal Storage Hardhat Implementation

An upgradable static database implementation utilizing [EIP-2535 Diamonds](https://github.com/ethereum/EIPs/issues/2535) and [Diamond Storage](https://dev.to/mudgen/how-diamond-storage-works-90e).

**Note:** This implementation uses [diamond-1](https://github.com/mudgen/diamond-1-hardhat). Other optimizations can be found [here](https://github.com/mudgen/diamond).

## Usage

Static data is stored in coal faces, which double as diamond facets. View `contracts/faces/Test1Face.sol` and `contracts/faces/Test2Face.sol` for reference. Both files contain 1,000 random addresses in bytes constants.

Coal Storage IO facets:

- `contracts/facets/CoalCutFacet.sol` is used to add, replace and remove faces.
- `contracts/facets/CoalStorageFacet.sol` is used to retrieve data and face information.

**Note:** Both facets are implemented internally in `contracts/libraries/LibCoal.sol`.

There are two implemenation variations available:

- `contracts/diamond/Diamond.sol` is a pure diamond that can implement ICoalStorage through CoalStorageFacet.
- `contracts/Coal.sol` implements ICoalStorage internally to offer a (slightly) more gas efficient method of accessing Coal Storage. These functions remain upgradable with diamond cutting.
The smart contract is deployed the same as the diamond-based implemenation, only without CoalStorageFacet.

## Deployment

### Diamond

```console
npx hardhat run scripts/deployDiamond.js
```

### Coal

```console
npx hardhat run scripts/deployCoal.js
```

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