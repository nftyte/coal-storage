// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ICoalStorage } from "./ICoalStorage.sol";

interface ICoalCut {
    function addFaces(ICoalStorage.Face[] calldata _faces) external;

    function removeFaces(uint256[] calldata _faces) external;

    function insertFaceAt(ICoalStorage.Face calldata _face, uint256 _i) external;

    function removeFaceAt(uint256 _i) external;
}
