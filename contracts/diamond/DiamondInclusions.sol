// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "./libraries/LibDiamond.sol";

contract DiamondInclusions {
    /**
     * @notice Attempts to upgrade an inclusion function call.
     * @dev Upgrades the call if the inclusion function selector is part of an external facet.
     * @return success_ `true` if the call was upgraded.
     * @return result_ returndata from the upgraded call.
     */
    function inclusionCall() internal virtual returns (bool success_, bytes memory result_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address facet = ds.selectorInfo[msg.sig].facetAddress;

        require(facet != address(0), "DiamondInclusions: Function does not exist");

        if (facet != address(this)) {
            (success_, result_) = facet.delegatecall(msg.data);

            if (!success_) {
                if (result_.length > 0) {
                    revert(string(result_));
                } else {
                    revert("DiamondInclusions: Facet function reverted");
                }
            }
        }
    }

    /**
     * @dev See {inclusionCall}.
     */
    function boolInclusionCall() internal virtual returns(bool success_, bool result_) {
        (bool success, bytes memory result) = inclusionCall();
        if (success) {
            return (true, abi.decode(result, (bool)));
        }
    }
    
    /**
     * @dev See {inclusionCall}.
     */
    function addressInclusionCall() internal virtual returns(bool success_, address result_) {
        (bool success, bytes memory result) = inclusionCall();
        if (success) {
            return (true, abi.decode(result, (address)));
        }
    }
}