// File is named 'TransparentProxy.sol' in the 'src' directory
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TransparentProxy
 * @dev This contract implements a transparent proxy pattern that forwards calls to an implementation contract.
 * It separates admin functions from user functions to avoid function selector clashes.
 */
contract TransparentProxy {
    // Implementation slot follows EIP-1967
    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    
    // Admin slot follows EIP-1967
    bytes32 private constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);
    
    /**
     * @dev Emitted when the admin is changed.
     */
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

    /**
     * @dev Constructor that sets the initial implementation and admin.
     * @param _logic The address of the initial implementation contract
     * @param _admin The address of the admin
     * @param _data Optional initialization data to be passed to the implementation
     */
    constructor(address _logic, address _admin, bytes memory _data) {
        require(_logic != address(0), "Implementation cannot be zero address");
        require(_admin != address(0), "Admin cannot be zero address");
        
        _setImplementation(_logic);
        _setAdmin(_admin);
        
        // Initialize the implementation if data is provided
        if (_data.length > 0) {
            (bool success, ) = _logic.delegatecall(_data);
            require(success, "Initialization failed");
        }
    }

    /**
     * @dev Modifier to check if the caller is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current implementation address.
     * Only callable by the admin.
     */
    function implementation() external ifAdmin returns (address) {
        return _implementation();
    }

    /**
     * @dev Returns the current admin address.
     * Only callable by the admin.
     */
    function admin() external ifAdmin returns (address) {
        return _admin();
    }

    /**
     * @dev Changes the admin of the proxy.
     * Only callable by the admin.
     * @param newAdmin The new admin address
     */
    function changeAdmin(address newAdmin) external ifAdmin {
        require(newAdmin != address(0), "New admin cannot be zero address");
        address oldAdmin = _admin();
        _setAdmin(newAdmin);
        emit AdminChanged(oldAdmin, newAdmin);
    }

    /**
     * @dev Upgrades the implementation to a new address.
     * Only callable by the admin.
     * @param newImplementation The new implementation address
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeTo(newImplementation);
    }

    /**
     * @dev Upgrades the implementation and calls an initialization function.
     * Only callable by the admin.
     * @param newImplementation The new implementation address
     * @param data The initialization data to be passed to the new implementation
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeTo(newImplementation);
        (bool success, ) = newImplementation.delegatecall(data);
        require(success, "Call to new implementation failed");
    }

    /**
     * @dev Fallback function that delegates calls to the implementation.
     * Will run if the call data is not matching any of the admin functions.
     */
    fallback() external payable {
        _fallback();
    }

    /**
     * @dev Receive function to accept Ether.
     */
    receive() external payable {
        _fallback();
    }

    /**
     * @dev Internal function to delegate the current call to the implementation.
     */
    function _fallback() internal {
        // Delegate call to the implementation contract
        address _impl = _implementation();
        
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code.
            calldatacopy(0, 0, calldatasize())
            
            // Forward the call to the implementation
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            
            // Get the returned data
            returndatacopy(0, 0, returndatasize())
            
            switch result
            // delegatecall returns 0 on error
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev Internal function to upgrade the implementation contract.
     * @param newImplementation The new implementation address
     */
    function _upgradeTo(address newImplementation) internal {
        require(newImplementation != address(0), "Implementation cannot be zero address");
        require(newImplementation != _implementation(), "New implementation cannot be the same as current");
        
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Internal function to get the implementation address.
     * @return impl The implementation address
     */
    function _implementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    /**
     * @dev Internal function to get the admin address.
     * @return adm The admin address
     */
    function _admin() internal view returns (address adm) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    /**
     * @dev Internal function to set the implementation address.
     * @param newImplementation The new implementation address
     */
    function _setImplementation(address newImplementation) internal {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }

    /**
     * @dev Internal function to set the admin address.
     * @param newAdmin The new admin address
     */
    function _setAdmin(address newAdmin) internal {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            sstore(slot, newAdmin)
        }
    }
}