// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { Diamond } from "./diamond/Diamond.sol";
import { IDiamondCut } from "./diamond/interfaces/IDiamondCut.sol";
import { LibDiamond } from "./diamond/libraries/LibDiamond.sol";
import { ICoalStorage } from "./interfaces/ICoalStorage.sol";
import { LibCoal } from "./libraries/LibCoal.sol";

contract Coal {
    bytes4 constant FACES_SELECTOR = bytes4(keccak256("faces()"));
    bytes4 constant AT_SELECTOR = bytes4(keccak256("at(uint256)"));

    constructor(address _contractOwner, address _diamondCutFacet) payable {        
        LibDiamond.setContractOwner(_contractOwner);

        // Add the diamondCut external function from the diamondCutFacet
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _diamondCutFacet, 
            action: IDiamondCut.FacetCutAction.Add, 
            functionSelectors: functionSelectors
        });
        LibDiamond.diamondCut(cut, address(0), "");
    }

    function faces() internal view returns (ICoalStorage.Face[] memory) {
        return LibCoal.faces();
    }
    
    function at(uint256 _i) internal view returns (bytes memory) {
        return LibCoal.at(_i);
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        // get diamond storage
        assembly {
            ds.slot := position
        }

        bytes4 selector = msg.sig;
        // get facet from function selector
        address facet = ds.facetAddressAndSelectorPosition[selector].facetAddress;

        if (facet == address(0)) {
            bytes memory result;

            if (selector == AT_SELECTOR) {
                (uint256 i) = abi.decode(msg.data[4:], (uint256));
                result = abi.encode(at(i));
            } else if (selector == FACES_SELECTOR) {
                result = abi.encode(faces());
            } else {
                revert("Coal: Function does not exist");
            }

            assembly {
                return(add(result, 0x20), mload(result))
            }
        } else {
            // Execute external function from facet using delegatecall and return any value.
            assembly {
                // copy function selector and any arguments
                calldatacopy(0, 0, calldatasize())
                // execute function call using the facet
                let success := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
                // get any return value
                returndatacopy(0, 0, returndatasize())
                // return any return value or error back to the caller
                switch success
                    case 0 {
                        revert(0, returndatasize())
                    }
                    default {
                        return(0, returndatasize())
                    }
            }
        }
    }

    receive() external payable {}
}
