// File is named 'ProxyAdmin.sol' in the 'src' directory
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TransparentProxy.sol";

/**
 * @title ProxyAdmin
 * @dev This contract is the admin for a TransparentProxy.
 * It provides functions to manage the proxy and is meant to be controlled by governance.
 */
contract ProxyAdmin {
    address public owner;
    
    /**
     * @dev Emitted when ownership of the contract is transferred.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "ProxyAdmin: caller is not the owner");
        _;
    }
    
    /**
     * @dev Constructor that sets the owner of the contract.
     */
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    
    /**
     * @dev Transfers ownership of the contract to a new account.
     * @param newOwner The address of the new owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "ProxyAdmin: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    /**
     * @dev Returns the current implementation of a proxy.
     * @param proxy The TransparentProxy contract
     * @return The address of the current implementation
     */
    function getProxyImplementation(TransparentProxy proxy) public view returns (address) {
        // Call the implementation() function on the proxy
        (bool success, bytes memory data) = address(proxy).staticcall(
            abi.encodeWithSignature("implementation()")
        );
        require(success, "ProxyAdmin: failed to get implementation");
        return abi.decode(data, (address));
    }
    
    /**
     * @dev Returns the admin of a proxy.
     * @param proxy The TransparentProxy contract
     * @return The address of the current admin
     */
    function getProxyAdmin(TransparentProxy proxy) public view returns (address) {
        // Call the admin() function on the proxy
        (bool success, bytes memory data) = address(proxy).staticcall(
            abi.encodeWithSignature("admin()")
        );
        require(success, "ProxyAdmin: failed to get admin");
        return abi.decode(data, (address));
    }
    
    /**
     * @dev Changes the admin of a proxy.
     * @param proxy The TransparentProxy contract
     * @param newAdmin The new admin address
     */
    function changeProxyAdmin(TransparentProxy proxy, address newAdmin) public onlyOwner {
        proxy.changeAdmin(newAdmin);
    }
    
    /**
     * @dev Upgrades a proxy to a new implementation.
     * @param proxy The TransparentProxy contract
     * @param implementation The new implementation address
     */
    function upgrade(TransparentProxy proxy, address implementation) public onlyOwner {
        proxy.upgradeTo(implementation);
    }
    
    /**
     * @dev Upgrades a proxy to a new implementation and calls a function on the new implementation.
     * @param proxy The TransparentProxy contract
     * @param implementation The new implementation address
     * @param data The function call data to be used after upgrading
     */
    function upgradeAndCall(
        TransparentProxy proxy, 
        address implementation, 
        bytes memory data
    ) public payable onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}