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
}
