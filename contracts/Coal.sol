// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ImpureDiamond } from "./diamond/ImpureDiamond.sol";
import { CoalStorageInclusions } from "./coalStorage/inclusions/CoalStorageInclusions.sol";

contract Coal is ImpureDiamond, CoalStorageInclusions {
    constructor() payable ImpureDiamond(msg.sender) {}
}
