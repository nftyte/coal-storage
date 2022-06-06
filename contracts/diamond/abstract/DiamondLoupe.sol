// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";

abstract contract DiamondLoupe is IDiamondLoupe {
    /**
     * @dev See {IDiamondLoupe-facets}.
     */
    function facets()
        external
        view
        virtual
        override
        returns (Facet[] memory facets_);

    /**
     * @dev See {IDiamondLoupe-facetFunctionSelectors}.
     */
    function facetFunctionSelectors(address _facet)
        external
        view
        virtual
        override
        returns (bytes4[] memory _facetFunctionSelectors);

    /**
     * @dev See {IDiamondLoupe-facetAddresses}.
     */
    function facetAddresses()
        external
        view
        virtual
        override
        returns (address[] memory facetAddresses_);

    /**
     * @dev See {IDiamondLoupe-facetAddress}.
     */
    function facetAddress(bytes4 _functionSelector)
        external
        view
        virtual
        override
        returns (address facetAddress_);
}
