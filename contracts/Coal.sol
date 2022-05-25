// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { Diamond } from "@diamond/contracts/Diamond.sol";

contract Coal is Diamond {
    constructor(address _contractOwner, address _diamondCutFacet)
        Diamond(_contractOwner, _diamondCutFacet)
    {}
}
