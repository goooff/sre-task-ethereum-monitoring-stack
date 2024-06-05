// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UPToken is ERC20 {

  // Initial supply, token name, and symbol
  constructor(uint256 initialSupply) ERC20("UPToken", "UPT") {
    require(initialSupply > 0, "Initial supply has to be greater than 0");
    _mint(msg.sender, initialSupply * 10**18); // Mint the initial supply to the deployer address
  }

}