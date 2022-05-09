// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract paySplit is PaymentSplitter, Ownable {
    
    constructor (address[] memory _payees, uint256[] memory _shares) PaymentSplitter(_payees, _shares) payable onlyOwner{}
    
}

/**
 ["0x16DD346Aa1483264DBb0Dde64235081C867fb3f2",
 "0x6d6257976bd82720A63fb1022cC68B6eE7c1c2B0"]
 */
 
 /**
 [35,
 65]
 */