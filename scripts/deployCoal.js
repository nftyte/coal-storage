/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')
const { deployDiamond } = require('./deployDiamond.js');

async function deployCoal () {
  const coalAddress = await deployDiamond();

  console.log('')
  console.log('Deploying facets')
  
  const CoalStorageFacet = await ethers.getContractFactory('CoalStorageFacet')
  const coalStorageFacet = await CoalStorageFacet.deploy()
  await coalStorageFacet.deployed()
  console.log(`CoalStorageFacet deployed: ${coalStorageFacet.address}`)
  const cut = [{
    facetAddress: coalStorageFacet.address,
    action: FacetCutAction.Add,
    functionSelectors: getSelectors(coalStorageFacet)
  }]

  console.log('')
  console.log('Diamond Cut:', cut)
  const diamondCut = await ethers.getContractAt('IDiamondCut', coalAddress)
  let tx
  let receipt
  tx = await diamondCut.diamondCut(cut, ethers.constants.AddressZero, "0x")
  console.log('Diamond cut tx: ', tx.hash)
  receipt = await tx.wait()
  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`)
  }
  console.log('Completed diamond cut')
  return coalAddress
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployCoal()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployCoal = deployCoal
