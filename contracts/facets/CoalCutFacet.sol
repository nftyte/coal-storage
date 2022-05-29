// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { LibDiamond } from "../diamond/libraries/LibDiamond.sol";
import { LibCoal } from "../libraries/LibCoal.sol";
import { ICoalCut } from "../interfaces/ICoalCut.sol";
import { ICoalStorage } from "../interfaces/ICoalStorage.sol";

contract CoalCutFacet is ICoalCut {
    function addFaces(ICoalStorage.Face[] calldata _faces) external override {
        LibDiamond.enforceIsContractOwner();
        LibCoal.addFaces(_faces);
    }

    function removeFaces(uint256[] calldata _faces) external override {
        LibDiamond.enforceIsContractOwner();
        LibCoal.removeFaces(_faces);
    }

    function insertFaceAt(ICoalStorage.Face calldata _face, uint256 _i) external override {
        LibDiamond.enforceIsContractOwner();
        LibCoal.insertFaceAt(_face, _i);
    }

    function removeFaceAt(uint256 _i) external override {
        LibDiamond.enforceIsContractOwner();
        LibCoal.removeFaceAt(_i);
    }
}