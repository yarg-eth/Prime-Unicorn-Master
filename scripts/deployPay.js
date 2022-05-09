const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const paySplit = await hre.ethers.getContractFactory("paySplit");
  const paysplit = await paySplit.deploy(["0x16DD346Aa1483264DBb0Dde64235081C867fb3f2", "0x6d6257976bd82720A63fb1022cC68B6eE7c1c2B0"], [35, 65]);

  await paysplit.deployed();

  console.log("paySplit deployed to:", paysplit.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});