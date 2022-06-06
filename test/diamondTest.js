/* global describe it before ethers */

const { deployer } = require("../scripts/libraries/deployer.js");

const {
    getSelectors,
    FacetCutAction,
} = require("../scripts/libraries/diamond.js");

const { deploy } = require("../scripts/deployDiamond.js");

const { assert } = require("chai");
const { ethers } = require("hardhat");

let diamond,
    coalStorage,
    iCoalStorage,
    coalStorageFacet,
    test1Face,
    test2Face,
    diamondCut,
    diamondLoupe,
    addresses,
    result,
    tx,
    receipt;

describe("Diamond Test", async function () {
    before(async function () {
        diamond = await deploy();
        coalStorage = await ethers.getContractAt(
            "CoalStorage",
            diamond.address
        );
        iCoalStorage = await ethers.getContractAt(
            "ICoalStorage",
            diamond.address
        );
        diamondCut = await ethers.getContractAt("DiamondCut", diamond.address);
        diamondLoupe = await ethers.getContractAt(
            "DiamondLoupe",
            diamond.address
        );
        addresses = [];
    });

    it("should have two facets -- call to facetAddresses function", async () => {
        for (const address of await diamondLoupe.facetAddresses()) {
            addresses.push(address);
        }
        assert.equal(addresses.length, 2);
    });

    it("facets should have the right function selectors -- call to facetFunctionSelectors function", async () => {
        let selectors = await diamondLoupe.facetFunctionSelectors(
            diamond.address
        );
        assert.sameMembers(selectors, getSelectors(diamond));
        selectors = await diamondLoupe.facetFunctionSelectors(addresses[1]);
        assert.sameMembers(selectors, getSelectors(coalStorage));
    });

    it("should add test1 functions", async () => {
        test1Face = await deployFacet("Test1Face");
        addresses.push(test1Face.address);
        const selectors = getSelectors(test1Face);
        result = await diamondLoupe.facetFunctionSelectors(test1Face.address);
        assert.sameMembers(result, selectors);
    });

    it("should test function call", async () => {
        await test1Face.test1Face(0);
    });

    it("should add test2 functions", async () => {
        test2Face = await deployFacet("Test2Face");
        addresses.push(test2Face.address);
        const selectors = getSelectors(test2Face);
        result = await diamondLoupe.facetFunctionSelectors(test2Face.address);
        assert.sameMembers(result, selectors);
    });

    it("should connect coal faces", async () => {
        const faces = [
            [1000, getSelectors(test1Face).get(["test1Face(uint256)"])[0]],
            [1000, getSelectors(test2Face).get(["test2Face(uint256)"])[0]],
        ];

        await coalStorage.addFaces(faces);

        assert.sameDeepMembers(
            (await coalStorage.faces()).map((f) => [...f]),
            faces
        );
    });

    it("should test at function", async () => {
        tx = await iCoalStorage.at(0);
        receipt = await tx.wait();
    });

    it("should retrieve data from coal storage", async () => {
        let fromStorage = ethers.utils.defaultAbiCoder.decode(
            ["address"],
            await coalStorage.at(999)
        )[0];

        let fromFace = await test1Face.test1Face(999);

        assert.equal(fromStorage, fromFace);

        fromStorage = ethers.utils.defaultAbiCoder.decode(
            ["address"],
            await coalStorage.at(1000)
        )[0];

        fromFace = await test2Face.test2Face(0);

        assert.equal(fromStorage, fromFace);
    });

    it("should upgrade coal storage functions", async () => {
        coalStorageFacet = await deployFacet(
            "CoalStorageFacet",
            FacetCutAction.Replace
        );
        addresses.push(coalStorageFacet.address);
        const selectors = getSelectors(coalStorageFacet);
        result = await diamondLoupe.facetFunctionSelectors(
            coalStorageFacet.address
        );
        assert.sameMembers(result, selectors);
    });

    it("should test at function", async () => {
        let gasUsed = receipt.gasUsed;
        tx = await iCoalStorage.at(0);
        receipt = await tx.wait();
        assert.isTrue(receipt.gasUsed.eq(gasUsed));
    });

    it("should retrieve data from coal storage", async () => {
        let fromStorage = ethers.utils.defaultAbiCoder.decode(
            ["address"],
            await coalStorage.at(999)
        )[0];

        let fromFace = await test1Face.test1Face(999);

        assert.equal(fromStorage, fromFace);

        fromStorage = ethers.utils.defaultAbiCoder.decode(
            ["address"],
            await coalStorage.at(1000)
        )[0];

        fromFace = await test2Face.test2Face(0);

        assert.equal(fromStorage, fromFace);
    });
});

async function deployFacet(
    facetName,
    action = FacetCutAction.Add,
    removeSelectors = []
) {
    const facet = await deployer(facetName);
    const selectors = getSelectors(facet).remove(removeSelectors);

    const tx = await diamondCut.diamondCut(
        [
            {
                facetAddress: facet.address,
                action,
                functionSelectors: selectors,
            },
        ],
        ethers.constants.AddressZero,
        "0x",
        { gasLimit: 800000 }
    );

    const receipt = await tx.wait();

    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }

    return facet;
}
