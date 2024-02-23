// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import ".IDAO.sol";
//import IERC20.sol

contract Blueprint is ERC721Enumerable, Ownable {
    bool private _initialized;
    bool public accepted;
    address public dao;
    address public hardToken;
    address public softToken;

    struct Module {
        bool isHardware;
        bool testOnChain;
        uint256 bounty;
        string description;
        string[] inputs;
        string[] outputs;
    }

    mapping(uint256 => Module) public modules;
    uint256 public supply;
    bool public supplyLocked;

    mapping(uint256 => bool) public bountyCollected;



    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function initialize(string memory name, string memory symbol, address initialOwner) public {
        require(!_initialized, "Blueprint: already initialized");
        _name = name;
        _symbol = symbol;
        _transferOwnership(initialOwner);
        _initialized = true;
    }


    function getBounty(uint256 tokenId) external returns(uint256) {
        return modules[tokenId].bounty;
    }

    function getTotalHardBounties() external returns(uint256 total) {
        for(uint256 i = 0; i < supply; i++){
            if(modules[i].isHardware){
                total += modules[i].bounty;
            }
        }
    }

    function getTotalSoftBounties() external returns(uint256 total) {
        for(uint256 i = 0; i < supply; i++){
            if(!modules[i].isHardware){
                total += modules[i].bounty;
            }
        }
    }

    function getTotalBounties() external returns(uint256 total) {
        for(uint256 i = 0; i < supply; i++){
            total += modules[i].bounty;
        }
    }


    /**
     * @dev Allows owner to lock and then propose the entire collection
     * to the `_dao`
     */
    function propose(address _dao, address _hardToken, address _softToken, string memory _proposal) external onlyOwner {
        IDAO(_dao).propose(_proposal);
        dao = _dao;
        hardToken = _hardToken;
        softToken = _softToken;
        supplyLocked = true;
    }

    function revokeProposal(address _dao, string memory _note) external onlyOwner {
        require(!accepted, "Blueprint: already accepted");
        IDAO(_dao).removeProposal(_note);
        dao = address(0);
        supplyLocked = false;
    }   

    /**
     * @dev Allows DAO to approve a proposal, agreeing to accept NFTs minted
     * by the Blueprint, and pause such minting
     */
    function accept() external {
        require(msg.sender == dao, "Blueprint: only DAO");

        // transfer HARD and SOFT tokens from DAO to this contract
        IERC20(hardToken).transferFrom(msg.sender, address(this), getTotalHardBounties());
        IERC20(softToken).transferFrom(msg.sender, address(this), getTotalSoftBounties());

        for(uint256 i = 0; i < supply; i++){
            _mintToDAO(i);
        }

        accepted = true;
    }

    /**
     * @dev Allows the architect to draft a module
     */
    function draft(
        bool _isHardware, 
        bool _testOnChain, 
        uint256 _bounty,
        string memory _description, 
        string[] memory _inputs,
        string[] memory _outputs
    ) external onlyOwner {
        require(!supplyLocked, "Blueprint: supply locked");

        modules[supply] = Module(_isHardware, _testOnChain, _bounty, _description, _inputs, _outputs);
        supply++;
    }

    /**
     * @dev Allows the architect to update a module
     */
    function redraft(
        uint256 tokenId,
        bool _isHardware, 
        bool _testOnChain, 
        uint256 _bounty,
        string memory _description, 
        string[] memory _inputs,
        string[] memory _outputs
    ) external onlyOwner {
        require(!supplyLocked, "Blueprint: supply locked");
        require(tokenId < supply, "Blueprint: tokenId not yet drafted");

        modules[tokenId] = Module(_isHardware, _testOnChain, _bounty, _description, _inputs, _outputs);
        supply++;
    }

    /**
     * @dev TODO
     */
    function tokenURI(uint256 tokenId) public view override returns(string memory uri) {
        require(_exists(tokenId), "Blueprint: Module does not exist");
        return modules[tokenId].description;
    }

    function getModule(uint256 tokenId) external view returns(Module module) {
        return modules[tokenId];
    }

    function collectBounty(uint256 tokenId) external {
        require(_exists(tokenId), "Blueprint: Module does not exist");
        require(ownerOf(tokenId) == msg.sender, "Blueprint: not token owner");
        require(!bountyCollected[tokenId], "Blueprint: bounty already collected");

        bountyCollected[tokenId] = true;

        if(modules[tokenId].isHardware){
            IERC20(hardToken).transferFrom(address(this), msg.sender, modules[tokenId].bounty);
        }else{
            IERC20(softToken).transferFrom(address(this), msg.sender, modules[tokenId].bounty);
        }
    }

    /**
     * @dev Tokens are minted directly to the DAO
     */
    function _mintToDAO(uint256 tokenId) internal {
        _mint(dao, tokenId);
    }


}
