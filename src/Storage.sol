// File is named 'Storage.sol' in the 'src' directory
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Storage
 * @dev Contract that defines the storage layout to be inherited by implementation contracts
 * This ensures that storage layouts remain consistent across upgrades
 */
contract Storage {
    // Storage slot for the value
    uint256 internal _value;
    
    // Optional: add a gap for future storage variables
    // This allows for adding new storage variables in future upgrades without affecting the layout
    uint256[50] private __gap;
}