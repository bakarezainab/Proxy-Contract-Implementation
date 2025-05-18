// File is named 'ImplementationV2.sol' in the 'src' directory
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Storage.sol";

/**
 * @title ImplementationV2
 * @dev Upgraded implementation contract with enhanced functionality.
 * Inherits from the same Storage contract to maintain the same storage layout.
 */
contract ImplementationV2 is Storage {
    /**
     * @dev Emitted when the value is changed.
     */
    event ValueChanged(uint256 newValue);
    
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
    
    /**
     * @dev New function added in V2 - returns the current value plus one.
     * @return The current value plus one
     */
    function getValuePlusOne() external view returns (uint256) {
        return _value + 1;
    }
    
    /**
     * @dev New function added in V2 - multiplies the current value by a factor.
     * @param factor The multiplication factor
     * @return The result of multiplication
     */
    function multiply(uint256 factor) external view returns (uint256) {
        return _value * factor;
    }
}