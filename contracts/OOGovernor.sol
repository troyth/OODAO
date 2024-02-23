// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.9;

import "@gnosis.pm/zodiac/contracts/interfaces/IAvatar.sol";
import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorSettingsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorPreventLateQuorumUpgradeable.sol";
import "./SOFT.sol";
import "./HARD.sol";
import "./BlueprintFactory.sol";



interface IBlueprint {
    function accept() external;
}



contract OOGovernor is
    GovernorUpgradeable,
    GovernorSettingsUpgradeable,
    GovernorCountingSimpleUpgradeable,
    GovernorVotesUpgradeable,
    GovernorVotesQuorumFractionUpgradeable,
    GovernorPreventLateQuorumUpgradeable
{
    address public owner;
    address public multisend;
    address public target;
    SOFT public soft;
    HARD public hard;

    event MultisendSet(address indexed multisend);
    event TargetSet(address indexed previousTarget, address indexed newTarget);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OODAOGovernorSetUp(address indexed owner, address indexed target, address indexed softToken);
    event BlueprintAccepted(address indexed blueprintAddress);
    event BlueprintProposed(uint256 indexed proposalId, address indexed blueprintAddress, address indexed proposer, string description);


    constructor(
        address _owner,
        address _target,
        address _multisend,
        SOFT _soft,
        string memory _name,
        uint256 _votingDelay,
        uint256 _votingPeriod,
        uint256 _proposalThreshold,
        uint256 _quorum,
        uint64 _initialVoteExtension
    ) {
        bytes memory initializeParams = abi.encode(
            _owner,
            _target,
            _multisend,
            _soft,
            _name,
            _votingDelay,
            _votingPeriod,
            _proposalThreshold,
            _quorum,
            _initialVoteExtension
        );
        setUp(initializeParams);
    }

    function setUp(bytes memory initializeParams) public initializer {
        (
            address _owner,
            address _target,
            address _multisend,
            SOFT _soft,
            string memory _name,
            uint256 _votingDelay,
            uint256 _votingPeriod,
            uint256 _proposalThreshold,
            uint256 _quorum,
            uint64 _initialVoteExtension
        ) = abi.decode(
                initializeParams,
                (address, address, address, SOFT, string, uint256, uint256, uint256, uint256, uint64)
            );
        owner = _owner;
        target = _target;
        multisend = _multisend;
        soft = _soft;
        __Governor_init(_name);
        __GovernorSettings_init(_votingDelay, _votingPeriod, _proposalThreshold);
        __GovernorCountingSimple_init();
        __GovernorVotes_init(IVotesUpgradeable(address(_soft)));
        __GovernorVotesQuorumFraction_init(_quorum);
        __GovernorPreventLateQuorum_init(_initialVoteExtension);
        emit OODAOGovernorSetUp(_owner, _target, address(_soft));
    }

    function proposeBlueprintAcceptance(address blueprintAddress, string memory description) public returns (uint256 proposalId) {
        require(blueprintAddress != address(0), "Invalid Blueprint address");
        require(BlueprintFactory.blueprintExists(blueprintAddress), "Invalid Blueprint");
        
        // Define the call to the `acceptBlueprint` function with the blueprint address
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = address(this); // Target is the Governor contract itself
        values[0] = 0; // No ETH is sent
        calldatas[0] = abi.encodeWithSignature("acceptBlueprint(address)", blueprintAddress);
        
        // Description hash for the proposal, could also be a direct string or an IPFS hash
        bytes32 descriptionHash = keccak256(bytes(description));
        
        // Creating the proposal in the Governor contract
        proposalId = propose(targets, values, calldatas, description);
        
        emit BlueprintProposalCreated(proposalId, blueprintAddress, msg.sender, description);
    }


    // Custom functions for OODAO governance, such as module proposal and approval logic, can be added here.
    function acceptBlueprint(address blueprintAddress) public onlyGovernance {
        require(blueprintAddress != address(0), "Invalid Blueprint address");
        require(BlueprintFactory.blueprintExists(blueprintAddress), "Invalid Blueprint");

        IBlueprint iB = IBlueprint(blueprintAddress);

        uint256 totalHard = iB.getTotalHardBounties();
        uint256 totalSoft = iB.getTotalSoftBounties();

        IERC20(hard)._mint(address(this), totalHard);
        IERC20(soft)._mint(address(this), totalSoft);

        IERC20(hard).approve(blueprintAddress, totalHard);
        IERC20(soft).approve(blueprintAddress, totalSoft);

        // Interface for the Blueprint contract, assuming accept() doesn't require arguments
        iB.accept();

        emit BlueprintAccepted(blueprintAddress);
    }



    // Override functions and custom logic as necessary for OODAO's specific governance needs

    // The following functions are overrides required by Solidity.
    // Add or modify override functions as needed for OODAO's governance.

    function _executor() internal view override returns (address) {
        return owner;
    }

    function version() public pure override returns (string memory) {
        return "OODAO Governor Module: v1.0.0";
    }

    // Implement and override other necessary functions from the inherited contracts
}
