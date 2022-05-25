// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { LibCoal } from "../libraries/LibCoal.sol";
import { ICoalStorage } from "../interfaces/ICoalStorage.sol";

contract CoalFacet is ICoalStorage {
    function faces() external view override returns (Face[] memory) {
        return LibCoal.faces();
    }
    
    function at(uint256 _i) external override returns (bytes memory) {
        return LibCoal.at(_i);
    }
}