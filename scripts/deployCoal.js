/* global ethers */
/* eslint prefer-const: "off" */

const { deployer } = require("./libraries/deployer.js");

async function deploy() {
    // deploy Coal
    const coal = await deployer("Coal");
    console.log(`Coal deployed:`, coal.address);
    return coal;
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
