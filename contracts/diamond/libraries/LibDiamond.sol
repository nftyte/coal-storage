// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";

// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.
// The loupe functions are required by the EIP2535 Diamonds standard

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct SelectorInfo {
        bool isInclusion;
        uint16 selectorPosition;
        address facetAddress;
    }

    struct DiamondStorage {
        // function selector => facet address and selector position in selectors array
        mapping(bytes4 => SelectorInfo) selectorInfo;
        bytes4[] selectors;
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors, false);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else {
                revert("LibDiamond: Incorrect FacetCutAction");
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors, bool _isInclusion) internal {
        require(_functionSelectors.length > 0, "LibDiamond: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        uint16 selectorCount = uint16(ds.selectors.length);
        require(_facetAddress != address(0), "LibDiamond: Add facet can't be address(0)");
        if (_facetAddress != address(this)) {
            enforceHasContractCode(_facetAddress, "LibDiamond: Add facet has no code");
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacet = ds.selectorInfo[selector].facetAddress;
            require(oldFacet == address(0), "LibDiamond: Can't add function that already exists");
            ds.selectorInfo[selector] = SelectorInfo(_isInclusion, selectorCount, _facetAddress);
            ds.selectors.push(selector);
            selectorCount++;
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamond: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamond: Replace facet can't be address(0)");
        enforceHasContractCode(_facetAddress, "LibDiamond: Replace facet has no code");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            SelectorInfo memory oldSelector = ds.selectorInfo[selector];
            address oldFacet = oldSelector.facetAddress;
            // can't replace immutable functions -- functions defined directly in the diamond w/o inclusion
            if (!oldSelector.isInclusion) {
                require(oldFacet != address(this), "LibDiamond: Can't replace immutable function");
            }
            require(oldFacet != _facetAddress, "LibDiamond: Can't replace function with same function");
            require(oldFacet != address(0), "LibDiamond: Can't replace function that doesn't exist");
            // replace old facet address
            ds.selectorInfo[selector].facetAddress = _facetAddress;
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamond: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        uint256 selectorCount = ds.selectors.length;
        require(_facetAddress == address(0), "LibDiamond: Remove facet address must be address(0)");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            SelectorInfo memory oldSelector = ds.selectorInfo[selector];
            require(oldSelector.facetAddress != address(0), "LibDiamond: Can't remove function that doesn't exist");
            // can't remove immutable functions -- functions defined directly in the diamond w/o inclusion
            if (!oldSelector.isInclusion) {
                require(oldSelector.facetAddress != address(this), "LibDiamond: Can't remove immutable function.");
            }
            // replace selector with last selector
            selectorCount--;
            if (oldSelector.selectorPosition != selectorCount) {
                bytes4 lastSelector = ds.selectors[selectorCount];
                ds.selectors[oldSelector.selectorPosition] = lastSelector;
                ds.selectorInfo[lastSelector].selectorPosition = oldSelector.selectorPosition;
            }
            // delete last selector
            ds.selectors.pop();
            delete ds.selectorInfo[selector];
        }
    }
    
    function addInclusions(bytes4[] memory _functionSelectors) internal {
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(this),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: _functionSelectors
        });
        addFunctions(address(this), _functionSelectors, true);
        emit DiamondCut(cut, address(0), "");
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamond: _init is address(0) but _calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamond: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamond: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamond: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }

    function setSupportedInterface(bytes4 _interfaceId, bool _supported) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.supportedInterfaces[_interfaceId] = _supported;
    }
}
