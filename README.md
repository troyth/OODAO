# Object-Oriented DAO (OODAO)
*SOFT POWER, HARD ASSETS*

Object-Oriented DAO (OODAO) is an architecture for DAOs assembled to create a specific object.

## Overview

The mission of an OODAO is described by a **Master Blueprint (MBP)**: an NFT collection in which each token describes a piece of the whole. Each master piece is a black box described by what it does and which other piece(s) it is attached to. Each piece also comes with a reward bounty claimable by the DAO member who contributes the functionality it describes.



 detailed by a Master Blueprint (MBP). The MBP is represented as an ERC721 NFT collection that breaks down the DAO's goal into individual modules—both hardware and software—each described functionally as a black box through its inputs and expected outputs, a unique symbol, and a bounty to be claimed by the member that creates it.

## Key Features
* Master Blueprint (MBP): An ERC721 NFT collection representing the schematic of the objective.
* Modules: Differentiated into hardware and software, each with associated bounties or revenue shares.
* $HARD Token: An ERC20 token representing a pro rata share of the OODAO treasury, associated with hardware modules.
* $SOFT Token: Represents a revenue share for software modules, redeemable for ETH.
* Gnosis Safe: Acts as the OODAO's treasury and signing authority.
* Zodiac Suite: Implements governance features, allowing for modular and customizable DAO operations.

## Architecture
### Contracts
#### MasterBlueprint.sol
* ERC721 contract to represent the MBP.
* Functions to mint, manage, and describe modules.

#### Module.sol
* Abstract contract defining common attributes for hardware and software modules.

#### HardwareModule.sol
* Inherits Module.sol.
* Implements bounty handling in $HARD tokens.

SoftwareModule.sol

Inherits Module.sol.
Manages revenue share through $fa tokens.
BountyToken.sol

ERC20 contract for $BRYX, with governance features.
RevenueShareToken.sol

ERC20 contract for $fa, redeemable against the DAO's ETH holdings.
Governance.sol

Implements voting mechanisms, leveraging Zodiac and Gnosis Safe for proposals and executions.
Treasury.sol

Manages the OODAO's funds, integrating with Gnosis Safe for secure asset storage and transactions.
Governance Flow
Module Claiming: Members claim MBP module NFTs by delivering the specified outputs.
Voting: $fa token holders vote on module offerings and proposals.
Module Replacement Proposals: Members can propose new blueprints for sub-module breakdowns.
Architect Rights: Blueprint authors have veto rights over module-related decisions.
Development Roadmap
Smart Contract Development

Implement and test the smart contracts outlined above.
Integration

Integrate the Zodiac suite for flexible governance.
Configure Gnosis Safe as the OODAO treasury.
Frontend Development

Develop a user interface for interacting with the OODAO, including module claiming and voting.
Testing and Deployment

Conduct thorough testing of smart contracts and frontend.
Deploy the system on a testnet, followed by mainnet deployment.
Community Building and Governance

Establish initial governance rules and community guidelines.
Begin onboarding OODAO members and distributing MBP NFTs.
Contributing
We welcome contributions from developers, designers, and thinkers interested in realizing the vision of an Object-Oriented DAO. Please see our Contribution Guidelines for more information on how to get involved.

License
MIT License