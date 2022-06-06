/* global ethers */
/* eslint prefer-const: "off" */

const { deployer } = require("./libraries/deployer.js");

const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

async function deploy() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    // deploy Diamond
    const Diamond = await ethers.getContractFactory("ImpureDiamond");
    const diamond = await Diamond.deploy(contractOwner.address);
    await diamond.deployed();
    console.log("Diamond deployed:", diamond.address);

    // deploy CoalInit
    // CoalInit provides a function that is called when the diamond is upgraded to initialize state variables
    // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
    coalInit = await deployer("CoalInit");
    console.log("CoalInit deployed:", coalInit.address);

    // deploy facets
    console.log("");
    console.log("Deploying facets");
    const FacetNames = ["CoalStorageFacet"];
    const cut = [];
    for (const FacetName of FacetNames) {
        const facet = await deployer(FacetName);
        console.log(`${FacetName} deployed: ${facet.address}`);
        cut.push({
            facetAddress: facet.address,
            action: FacetCutAction.Add,
            functionSelectors: getSelectors(facet),
        });
    }

    // upgrade diamond with facets
    console.log("");
    // console.log("Diamond Cut:", cut);
    const diamondCut = await ethers.getContractAt(
        "IDiamondCut",
        diamond.address
    );
    let tx;
    let receipt;
    // call to init function
    let functionCall = coalInit.interface.encodeFunctionData("init");
    tx = await diamondCut.diamondCut(cut, coalInit.address, functionCall);
    console.log("Diamond cut tx: ", tx.hash);
    receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }
    console.log("Completed diamond cut");
    return diamond;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    deploy()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}

exports.deploy = deploy;
