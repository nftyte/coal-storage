// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC173 } from "../interfaces/IERC173.sol";

abstract contract Ownership is IERC173 {
    /**
     * @dev See {IERC173-owner}.
     */
    function owner() external view virtual override returns (address owner_);

    /**
     * @dev See {IERC173-transferOwnership}.
     */
    function transferOwnership(address _newOwner) external virtual override;
}
