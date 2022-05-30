// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ICoalStorage } from "../interfaces/ICoalStorage.sol";
import { LibDiamond } from "../diamond/libraries/LibDiamond.sol";

library LibCoal {
    bytes32 constant COAL_STORAGE_POSITION = keccak256("diamond.standard.coal.storage");

    struct CoalStorage {
        ICoalStorage.Face[] faces;
    }
    
    function coalStorage() internal pure returns (CoalStorage storage cs) {
        bytes32 position = COAL_STORAGE_POSITION;
        assembly {
            cs.slot := position
        }
    }

    function faces() internal view returns (ICoalStorage.Face[] memory) {
        return coalStorage().faces;
    }

    function find(uint256 _i) internal view returns (bytes4 face_, uint256 i_) {
        uint256 size;
        CoalStorage storage cs = coalStorage();
        uint256 faceCount = cs.faces.length;
        
        for (uint256 i; i < faceCount; i++) {
            ICoalStorage.Face memory face = cs.faces[i];
            if (_i < size + face.size) {
                return (face.selector, _i - size);
            }
            size += face.size;
        }

        return (0, 0);
    }

    function at(uint256 _i) internal view returns (bytes memory) {
        (bytes4 face, uint256 i) = find(_i);
        require(face > 0, "LibCoal: Out of bounds");

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        
        address facet = ds.facetAddressAndSelectorPosition[face].facetAddress;
        require(facet != address(0), "LibCoal: Function does not exist");
        
        (bool success, bytes memory result) = facet.staticcall(abi.encodeWithSelector(face, i));

        assembly {
            switch success
                case 0 {
                    revert(add(result, 0x20), returndatasize())
                }
                default {
                    return(add(result, 0x20), returndatasize())
                }
        }
    }

    function addFaces(ICoalStorage.Face[] memory _faces) internal {
        CoalStorage storage cs = coalStorage();
        
        for (uint256 i; i < _faces.length; i++) {
            cs.faces.push(_faces[i]);
        }
    }

    function removeFaces(uint256[] memory _faces) internal {
        CoalStorage storage cs = coalStorage();
        uint256 faceCount = cs.faces.length;
        
        for (uint256 i; i < _faces.length; i++) {
            uint256 id = _faces[i];
            require(id < faceCount);
            delete cs.faces[id];
        }
    }

    function insertFaceAt(ICoalStorage.Face memory _face, uint256 _i) internal {
        CoalStorage storage cs = coalStorage();
        require(_i < cs.faces.length);
        cs.faces[_i] = _face;
    }

    function removeFaceAt(uint256 _i) internal {
        CoalStorage storage cs = coalStorage();
        require(_i < cs.faces.length);
        delete cs.faces[_i];
    }
}