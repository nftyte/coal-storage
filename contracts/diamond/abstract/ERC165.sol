// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165 } from "../interfaces/IERC165.sol";

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        external
        view
        virtual
        override
        returns (bool);
}
