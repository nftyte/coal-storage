// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { DiamondInclusions } from "../DiamondInclusions.sol";
import { IERC165 } from "../interfaces/IERC165.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

contract ERC165Inclusions is IERC165, DiamondInclusions {
    constructor() {
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IERC165.supportsInterface.selector;
        LibDiamond.addInclusions(functionSelectors);
        LibDiamond.setSupportedInterface(type(IERC165).interfaceId, true);
    }
    
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) external virtual override inclusion returns (bool) {
        return LibDiamond.diamondStorage().supportedInterfaces[interfaceId];
    }
}