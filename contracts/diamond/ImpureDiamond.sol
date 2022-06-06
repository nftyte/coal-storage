// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Diamond } from "./Diamond.sol";
import { ERC165Inclusions } from "./inclusions/ERC165Inclusions.sol";
import { OwnershipInclusions } from "./inclusions/OwnershipInclusions.sol";
import { DiamondLoupeInclusions } from "./inclusions/DiamondLoupeInclusions.sol";
import { DiamondCutInclusions } from "./inclusions/DiamondCutInclusions.sol";

contract ImpureDiamond is
    Diamond,
    DiamondCutInclusions,
    DiamondLoupeInclusions,
    OwnershipInclusions,
    ERC165Inclusions
{
    constructor(address _contractOwner) payable OwnershipInclusions(_contractOwner) {}
}
