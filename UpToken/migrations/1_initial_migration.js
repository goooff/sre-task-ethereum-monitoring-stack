const UpToken = artifacts.require("UpToken");

// Guess the SRE reference in the initial supply amount ;) 
module.exports = (deployer) => {
    deployer.deploy(UpToken, 999999999);
};
