// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibReader {
    function read(
        uint256 _i,
        uint256 _length,
        bytes memory _data
    ) internal pure returns (bytes memory) {
        bytes memory res = new bytes(((_length + 31) >> 5) << 5);

        assembly {
            for { let i := 0 } lt(i, _length) { } {
                i := add(i, 0x20)
                mstore(add(res, i), mload(add(add(_data, _i), i)))
            }

            mstore(res, _length)
        }

        return res;
    }
}
