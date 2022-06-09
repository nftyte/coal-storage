// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { DiamondInclusions } from "../../diamond/DiamondInclusions.sol";
import { ICoalStorage } from "../interfaces/ICoalStorage.sol";
import { LibCoal } from "../libraries/LibCoal.sol";
import { LibDiamond } from "../../diamond/libraries/LibDiamond.sol";

contract CoalStorageInclusions is ICoalStorage, DiamondInclusions {
    constructor() {
        bytes4[] memory functionSelectors = new bytes4[](6);
        functionSelectors[0] = ICoalStorage.faces.selector;
        functionSelectors[1] = ICoalStorage.at.selector;
        functionSelectors[2] = ICoalStorage.addFaces.selector;
        functionSelectors[3] = ICoalStorage.removeFaces.selector;
        functionSelectors[4] = ICoalStorage.insertFaceAt.selector;
        functionSelectors[5] = ICoalStorage.removeFaceAt.selector;
        LibDiamond.addInclusions(functionSelectors);
        LibDiamond.setSupportedInterface(type(ICoalStorage).interfaceId, true);
    }
    
    function faces() external override inclusion returns (Face[] memory) {
        return LibCoal.faces();
    }
    
    function at(uint256 _i) external override inclusion returns (bytes memory) {
        return LibCoal.at(_i);
    }
    
    function addFaces(ICoalStorage.Face[] calldata _faces) external override inclusion {
        LibDiamond.enforceIsContractOwner();
        LibCoal.addFaces(_faces);
    }

    function removeFaces(uint256[] calldata _faces) external override inclusion {
        LibDiamond.enforceIsContractOwner();
        LibCoal.removeFaces(_faces);
    }

    function insertFaceAt(ICoalStorage.Face calldata _face, uint256 _i) external override inclusion {
        LibDiamond.enforceIsContractOwner();
        LibCoal.insertFaceAt(_face, _i);
    }

    function removeFaceAt(uint256 _i) external override inclusion {
        LibDiamond.enforceIsContractOwner();
        LibCoal.removeFaceAt(_i);
    }
}