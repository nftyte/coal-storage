// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibCoal } from "../libraries/LibCoal.sol";
import { ICoalStorage } from "../interfaces/ICoalStorage.sol";

contract CoalInit {    
    function init() external {
        ICoalStorage.Face[] memory faces = new ICoalStorage.Face[](2);
        faces[0].size = faces[1].size = 1000;
        faces[0].selector = bytes4(keccak256("test1Face(uint256)"));
        faces[1].selector = bytes4(keccak256("test2Face(uint256)"));
        LibCoal.addFaces(faces);
    }
}
