async function main() {
    const [deployer] = await ethers.getSigners();
    const beginBalance = await deployer.getBalance();
  
    console.log("Deployer:", deployer.address);
    console.log("Balance:", ethers.utils.formatEther(beginBalance));

    // Deploy
    const bottleFactory = await ethers.getContractFactory("GalaxyDriftbottle");
    const mintRole = ethers.constants.AddressZero;    
    const bottle = await bottleFactory.deploy("GalaxyDriftbottle", "GDB", mintRole);
    console.log("GalaxyDriftbottle Contract:", bottle.address);
    
    // setting
    await bottle.setBaseURI("");
    await bottle.setBaseExtension(".json");
    console.log("Set base info successfully");

    // +++
    const endBalance = await deployer.getBalance();
    const gasSpend = beginBalance.sub(endBalance);

    console.log("\nLatest balance:", ethers.utils.formatEther(endBalance));
    console.log("Gas:", ethers.utils.formatEther(gasSpend));
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });