// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoalStorage {
    struct Face {
        uint16 size;
        bytes4 selector;
    }

    // TODO add length getter
    
    function faces() external view returns (Face[] memory);
    
    function at(uint256 _i) external view returns (bytes memory);
    
    function addFaces(Face[] calldata _faces) external;

    function removeFaces(uint256[] calldata _faces) external;

    function insertFaceAt(Face calldata _face, uint256 _i) external;

    function removeFaceAt(uint256 _i) external;
}
