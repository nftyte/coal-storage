// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { DiamondInclusions } from "../../diamond/DiamondInclusions.sol";
import { ICoalStorage } from "../interfaces/ICoalStorage.sol";
import { LibCoal } from "../libraries/LibCoal.sol";
import { LibDiamond } from "../../diamond/libraries/LibDiamond.sol";

abstract contract CoalStorage is ICoalStorage {
    function faces() external view virtual override returns (Face[] memory);
    
    function at(uint256 _i) external view virtual override returns (bytes memory);
    
    function addFaces(ICoalStorage.Face[] calldata _faces) external virtual override;

    function removeFaces(uint256[] calldata _faces) external virtual override;

    function insertFaceAt(ICoalStorage.Face calldata _face, uint256 _i) external virtual override;

    function removeFaceAt(uint256 _i) external virtual override;
}