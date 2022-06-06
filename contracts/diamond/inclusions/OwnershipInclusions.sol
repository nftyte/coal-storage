// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { DiamondInclusions } from "../DiamondInclusions.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";
import { IERC173 } from "../interfaces/IERC173.sol";

contract OwnershipInclusions is IERC173, DiamondInclusions {
    constructor(address _contractOwner) {
        LibDiamond.setContractOwner(_contractOwner);
        bytes4[] memory functionSelectors = new bytes4[](2);
        functionSelectors[0] = IERC173.transferOwnership.selector;
        functionSelectors[1] = IERC173.owner.selector;
        LibDiamond.addInclusions(functionSelectors);
        LibDiamond.setSupportedInterface(type(IERC173).interfaceId, true);
    }
    
    /**
     * @dev See {IERC173-owner}.
     */
    function owner() external virtual override returns (address) {
        (bool success, address result) = addressInclusionCall();
        return success ? result : LibDiamond.contractOwner();
    }

    /**
     * @dev See {IERC173-transferOwnership}.
     */
    function transferOwnership(address _newOwner) external virtual override {
        (bool success,) = inclusionCall();
        if (!success) {
            LibDiamond.enforceIsContractOwner();
            LibDiamond.setContractOwner(_newOwner);
        }
    }
}
