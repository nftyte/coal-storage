// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../../diamond/libraries/LibDiamond.sol";
import { ICoalStorage } from "../interfaces/ICoalStorage.sol";

contract CoalInit {    
    function init() external {
        LibDiamond.setSupportedInterface(type(ICoalStorage).interfaceId, true);
    }
}
