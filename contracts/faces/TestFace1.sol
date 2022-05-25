// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { LibReader } from "../libraries/LibReader.sol";

contract TestFace1 {
    bytes constant DATA = hex"";
    uint256 constant ITEM_SIZE = 20;

    function testFace1(uint256 _i) external pure returns (bytes memory) {
        return LibReader.read(_i * ITEM_SIZE, ITEM_SIZE, DATA);
    }
}