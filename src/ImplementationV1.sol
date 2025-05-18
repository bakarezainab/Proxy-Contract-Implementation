// File is named 'ImplementationV1.sol' in the 'src' directory
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Storage.sol";

/**
 * @title ImplementationV1
 * @dev Initial implementation contract with simple functionality.
 * Note that we inherit from Storage to ensure consistent storage layout.
 */
contract ImplementationV1 is Storage {
    /**
     * @dev Emitted when the value is changed.
     */
    event ValueChanged(uint256 newValue);
    
    /**
     * @dev Initializer function (replaces constructor for upgradeable contracts).
     * This should be called only once when the proxy is deployed.
     */
    function initialize() external {
        // Ensure this function can only be called once
        require(_value == 0, "Already initialized");
        
        // Initialize state variables
        _value = 1;
    }
    
    /**
     * @dev Sets a new value.
     * @param newValue The new value to set
     */
    function setValue(uint256 newValue) external {
        _value = newValue;
        emit ValueChanged(newValue);
    }
    
    /**
     * @dev Gets the current value.
     * @return The current value
     */
    function getValue() external view returns (uint256) {
        return _value;
    }
}