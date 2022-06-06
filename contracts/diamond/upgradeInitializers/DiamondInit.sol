// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../libraries/LibDiamond.sol";

contract DiamondInit {
    function init(bytes4[] calldata inclusions) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        for (uint256 i; i < inclusions.length; i++) {
            ds.selectorInfo[inclusions[i]].isInclusion = true;
        }
    }
}
