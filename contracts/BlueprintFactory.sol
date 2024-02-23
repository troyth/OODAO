// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Blueprint.sol";

contract BlueprintFactory {
    address public immutable template;
    mapping(uint256 => address) public blueprintAddressById;
    mapping(address => uint256) public blueprintIdByAddress;
    uint256 private index = 1;

    event BlueprintCreated(address indexed blueprintAddress, string name, string symbol);

    constructor(address template_) {
        require(template_ != address(0), "BlueprintFactory: template is the zero address");
        template = template_;
    }

    function createBlueprint(string memory name, string memory symbol) external returns(address cloneAddr) {
        cloneAddr = Clones.clone(template);
        Blueprint(cloneAddr).initialize(name, symbol, msg.sender);

        blueprintAddressById[supply] = cloneAddr;
        blueprintIdByAddress[cloneAddr] = supply;
        supply++;

        emit BlueprintCreated(cloneAddr, name, symbol);
    }

    function totalSupply() external view returns(uint256) {
        return index-1;
    }

    function blueprintExists(address blueprintAddress) external view returns(bool) {
        return (blueprintIdByAddress[blueprintAddress] > 0);
    }
}
