require("dotenv").config();
const { MNEMONIC, PROJECT_ID } = process.env;

const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
    networks: {
        development: {
            host: "127.0.0.1", // Localhost 
            port: 9545, // Standard Ethereum port 
            network_id: "*", // Any network 
        },
        sepolia: {
            provider: () =>
                new HDWalletProvider(
                    MNEMONIC,
                    `https://eth-sepolia.g.alchemy.com/v2/${PROJECT_ID}`,
                ),
            network_id: 11155111, // Sepolia's id
            confirmations: 2, // # of confirmations to wait between deployments
            timeoutBlocks: 200, // # of blocks before a deployment times out 
            skipDryRun: true, // Skip dry run before migrations? 
        },
    },
    compilers: {
        solc: {
            version: "0.8.26",
        },
    },
};