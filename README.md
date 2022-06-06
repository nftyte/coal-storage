# Coal Storage Hardhat Implementation

An upgradable static database reference implementation utilizing [EIP-2535 Diamonds](https://github.com/ethereum/EIPs/issues/2535) and [Diamond Storage](https://dev.to/mudgen/how-diamond-storage-works-90e).

**Note:** This implementation uses [impure-diamond](https://github.com/nftyte/impure-diamond) for simplicity. Other diamond implementations can be found [here](https://github.com/mudgen/diamond).

## Faces

Faces are diamond facets that store and enable access to static data chunks.

For example, the files `contracts/coalStorage/faces/Test1Face.sol` and `contracts/coalStorage/faces/Test2Face.sol` have 1,000 random addresses stored in bytecode.

`contracts/coalStorage/abstract/CoalStorage.sol` can be used to retrieve and update face information. Its `at(uint256)` function can be used to retrieve an entry from faces as if they were a single array.

## Deployment

### Diamond

A generic diamond that implements `ICoalStorage` through `CoalStorageFacet`.

```console
npx hardhat run scripts/deployDiamond.js
```

### Coal

A diamond that implements `ICoalStorage` directly to offer a (slightly) more gas efficient access to storage.

```console
npx hardhat run scripts/deployCoal.js
```

**Note:** `ICoalStorage` functions remain upgradable using diamond inclusions (see [impure-diamond](https://github.com/nftyte/impure-diamond#inclusions)).

## Tests

```console
npx hardhat test
```

## TODO

- [ ] Add documentation to coal storage components
- [x] Emit `FacetCut` event for default `at(uint256)` and `faces()` in Coal implementation
- [x] Make default `at(uint256)` and `faces()` visible through loupe functions

## Author

This example implementation was written by NFTyte.

Contact: https://twitter.com/nftyte

## License

MIT license. Anyone can use or modify this software for their purposes.
