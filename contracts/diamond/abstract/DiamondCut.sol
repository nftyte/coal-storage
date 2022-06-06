// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IDiamondCut } from "../interfaces/IDiamondCut.sol";

abstract contract DiamondCut is IDiamondCut {
    /**
     * @dev See {IDiamondCut-diamondCut}.
     */
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external virtual override;
}
