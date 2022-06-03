// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const PrimeUnicorn = await hre.ethers.getContractFactory("PrimeUnicorn");
  const primeUnicorn = await PrimeUnicorn.deploy("https://gateway.pinata.cloud/ipfs/Qme6dCutqqY4immM3b2u88A2hU1ExjKpG2h1T74dnZTSu5/giphy.gif");
  //mainnet = 0xa5409ec958c83c3f309868babaca7c86dcb077c1

  await primeUnicorn.deployed();

  console.log("Prime Unicorn NFTs deployed to:", primeUnicorn.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});