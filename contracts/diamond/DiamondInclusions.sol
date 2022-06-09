// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "./libraries/LibDiamond.sol";

contract DiamondInclusions {
    /**
     * @notice Attempts to upgrade an inclusion function call.
     * @dev Upgrades the call if the inclusion function selector is part of an external facet.
     */
    modifier inclusion() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address facet = ds.selectorInfo[msg.sig].facetAddress;

        require(facet != address(0), "DiamondInclusions: Function does not exist");
        
        if (facet == address(this)) {
            _;
        } else {
            assembly {
                calldatacopy(0, 0, calldatasize())

                let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)

                returndatacopy(0, 0, returndatasize())

                switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
            }
        }
    }
}