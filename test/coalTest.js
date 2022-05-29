/* global describe it before ethers */

const {
    getSelectors,
    FacetCutAction,
    // removeSelectors,
    // findAddressPositionInFacets
} = require("../scripts/libraries/diamond.js");

const { deployCoal } = require("../scripts/deploy.js");

const { assert } = require("chai");

describe.only("CoalTest", async function () {
    let coalAddress;
    let diamondCutFacet;
    let diamondLoupeFacet;
    let ownershipFacet;
    let coalCutFacet;
    let coalStorageFacet;
    let result;
    const addresses = [];

    before(async function () {
        coalAddress = await deployCoal();
        diamondCutFacet = await ethers.getContractAt(
            "DiamondCutFacet",
            coalAddress
        );
        diamondLoupeFacet = await ethers.getContractAt(
            "DiamondLoupeFacet",
            coalAddress
        );
        ownershipFacet = await ethers.getContractAt(
            "OwnershipFacet",
            coalAddress
        );
        coalCutFacet = await ethers.getContractAt(
            "CoalCutFacet",
            coalAddress
        );
        coalStorageFacet = await ethers.getContractAt(
            "CoalStorageFacet",
            coalAddress
        );
    });

    it("should have five facets -- call to facetAddresses function", async () => {
        for (const address of await diamondLoupeFacet.facetAddresses()) {
            addresses.push(address);
        }
        assert.equal(addresses.length, 5);
    });

    it("facets should have the right function selectors -- call to facetFunctionSelectors function", async () => {
        for (let [i, facet] of Object.entries([
            diamondCutFacet,
            diamondLoupeFacet,
            ownershipFacet,
            coalCutFacet,
            coalStorageFacet,
        ])) {
            result = await diamondLoupeFacet.facetFunctionSelectors(
                addresses[parseInt(i)]
            );
            assert.sameMembers(result, getSelectors(facet));
        }
    });

    it("selectors should be associated to facets correctly -- multiple calls to facetAddress function", async () => {
        for (let [addr, selectors] of Object.entries({
            [addresses[0]]: ["0x1f931c1c"],
            [addresses[1]]: ["0xcdffacc6", "0x01ffc9a7"],
            [addresses[2]]: ["0xf2fde38b"],
            [addresses[3]]: [/*removeFaceAt(uint256)*/ "0x27ed671a"],
            [addresses[4]]: [/*faces()*/ "0xd16df15f", /*at(uint256)*/ "0xe0886f90"],
        })) {
            for (let selector of selectors) {
                assert.equal(
                    addr,
                    await diamondLoupeFacet.facetAddress(selector)
                );
            }
        }
    });

    it("should add test1 functions", async () => {
        const test1Face = await deployFacet(diamondCutFacet, "Test1Face");
        addresses.push(test1Face.address);
        const selectors = getSelectors(test1Face);
        result = await diamondLoupeFacet.facetFunctionSelectors(
            test1Face.address
        );
        assert.sameMembers(result, selectors);
    });

    it("should test function call", async () => {
        const test1Face = await ethers.getContractAt("Test1Face", coalAddress);
        await test1Face.test1Face(0);
    });

    it("should add test2 functions", async () => {
        const test2Face = await deployFacet(diamondCutFacet, "Test2Face");
        addresses.push(test2Face.address);
        const selectors = getSelectors(test2Face);
        result = await diamondLoupeFacet.facetFunctionSelectors(
            test2Face.address
        );
        assert.sameMembers(result, selectors);
    });

    it("should connect coal faces", async () => {
        const test1Face = await ethers.getContractAt("Test1Face", coalAddress);
        const test2Face = await ethers.getContractAt("Test2Face", coalAddress);
        const faces = [
            {
                size: 1000,
                selector: getSelectors(test1Face).get([
                    "test1Face(uint256)",
                ])[0],
            },
            {
                size: 1000,
                selector: getSelectors(test2Face).get([
                    "test2Face(uint256)",
                ])[0],
            },
        ];

        await coalCutFacet.addFaces(faces);

        for (let face of await coalStorageFacet.faces()) {
            assert.equal(
                faces.filter(
                    (f) => f.size == face.size && f.selector == face.selector
                ).length,
                1
            );
        }
    });

    it("should retrieve data from coal storage", async () => {
        const test1Face = await ethers.getContractAt("Test1Face", coalAddress);
        const test2Face = await ethers.getContractAt("Test2Face", coalAddress);

        let fromStorage = ethers.utils.defaultAbiCoder.decode(
            ["address"],
            await coalStorageFacet.at(999)
        )[0];
        let fromFace = await test1Face.test1Face(999);
        
        assert.equal(fromStorage, fromFace);

        fromStorage = ethers.utils.defaultAbiCoder.decode(
            ["address"],
            await coalStorageFacet.at(1000)
        )[0];
        fromFace = await test2Face.test2Face(0);

        assert.equal(fromStorage, fromFace);
    });
});

async function deployFacet(diamondCutFacet, facetName, removeSelectors = []) {
    const Facet = await ethers.getContractFactory(facetName);
    const facet = await Facet.deploy();
    await facet.deployed();
    const selectors = getSelectors(facet).remove(removeSelectors);

    tx = await diamondCutFacet.diamondCut(
        [
            {
                facetAddress: facet.address,
                action: FacetCutAction.Add,
                functionSelectors: selectors,
            },
        ],
        ethers.constants.AddressZero,
        "0x",
        { gasLimit: 800000 }
    );

    receipt = await tx.wait();

    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }

    return facet;
}
