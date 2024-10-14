// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin
//A stablecoin is a type of cryptocurrency that's typically pegged to the value of a traditional asset, such as the US dollar. In this case, the contract includes minting and burning functionalities, which allow the creation and removal of tokens, helping maintain stability.

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

/*
 * @title: ArceusStableCoin
 * @author: 0Glitch 'extracted from cyfrin updraft for education purpose'
 * Collateral: Exogenous (ETH & BTC)
 * Minting: Algorithmic
 * Relative Stability: Pegged to USD
 *
 * This is the contract meant to be governed by DSCEngine. This contract is just the ERC20 implementation of our stablecoin system.
 */
pragma solidity 0.8.19;

//import {ERC20Burnable, ERC20} from "@openzeppelin/openzeppelin-contracts/token/ERC20/extensions/ERC20Burnable.sol"; //ERC20Burnable includes `burn` functionality for our tokens which will be important when we need to take the asset out of circulation to support stability.
//import {Ownable} from "@openzeppelin/openzeppelin-contracts/access/Ownable.sol"; //Ownable: This contract adds an ownership structure, where only the owner of the contract (typically the person who deployed it) can perform certain actions.

/*
The ArceusStableCoin contract inherits from two base contracts:
ERC20Burnable: Implements the core functionality of an ERC20 token with the addition of a burn function to destroy tokens.
Ownable: Allows only the owner of the contract to perform restricted actions like minting or burning tokens. The contract owner is determined by the Ownable contract and is set when the contract is deployed.
*/
contract ArceusStableCoin is
    ERC20Burnable,
    Ownable //Inheritance of contracts
{
    //These are custom errors to improve gas efficiency when handling specific error conditions. Instead of using standard require statements, Solidity can "revert" with these specific error messages:
    error ArceusStableCoin__mustBeMoreThanZero(); //when the amount of tokens provided (for minting or burning) is zero or negative. It's a logical check—transactions with zero or negative amounts are not allowed.
    error ArceusStableCoin__BurnAmountExceedsBalance(); //Thrown when the user tries to burn more tokens than they currently own.
    error ArceusStableCoin__NotZeroAddress(); // Thrown when the destination address for minting tokens is the zero address. The zero address (0x0000000000000000000000000000000000000000) is an invalid address and cannot be used in this context.

    constructor() ERC20("ArceusStableCoin", "ARC") {}

    /*
    Purpose of Constructor: The constructor is called once when the contract is deployed. 
    It initializes the token with a name ("ArceusStableCoin") and a symbol ("ARC"), which are passed to the base ERC20 contract.
    ERC20: The ERC20 constructor sets the token name and symbol,
    which are displayed when someone looks up the token on a blockchain explorer or interacts with it via a wallet.
    */

    function burn(uint256 _amount) external override onlyOwner {
        //Purpose: This function allows the owner of the contract (the only one allowed to call this function) to burn tokens. When tokens are burned, they are permanently destroyed, reducing the total supply of the token.
        uint256 balance = balanceOf(msg.sender); //How it works: Check balance: First, the contract checks the balance of the caller (which should be the contract owner) using balanceOf(msg.sender).
        if (_amount <= 0) {
            //The amount to burn (_amount) must be greater than 0.
            revert ArceusStableCoin__mustBeMoreThanZero(); //If not, the transaction reverts with the custom error ArceusStableCoin__mustBeMoreThanZero.
        }
        if (balance < _amount) {
            //The owner must have enough tokens to burn. If the owner tries to burn more tokens than they own,
            revert ArceusStableCoin__BurnAmountExceedsBalance(); //the transaction reverts with ArceusStableCoin__BurnAmountExceedsBalance.
        }
        super.burn(_amount); //Burning: If both conditions pass, the super.burn(_amount) function is called to burn the specified amount of tokens using the ERC20Burnable functionality.
    } //Why Burn Tokens?: Burning tokens reduces the total supply, which can help maintain or increase the value of the token in circulation. In stablecoins, burning is often part of a mechanism to maintain price stability by controlling supply.

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        //Purpose: This function allows the contract owner to mint (create) new tokens. Minting tokens adds them to circulation by increasing the supply.
        if (_to == address(0)) {
            //Check address: The _to address (the recipient of the newly minted tokens) must not be the zero address. Minting tokens to the zero address would effectively burn them, which is not allowed.
            revert ArceusStableCoin__NotZeroAddress(); //If _to is the zero address, the transaction reverts with ArceusStableCoin__NotZeroAddress.
        }
        if (_amount <= 0) {
            //Validate amount: The amount of tokens to mint (_amount) must be greater than zero. If not,
            revert ArceusStableCoin__mustBeMoreThanZero(); //the transaction reverts with ArceusStableCoin__mustBeMoreThanZero.
        }
        _mint(_to, _amount); //Minting: If both checks pass, the _mint function from the ERC20 contract is called, minting _amount tokens and assigning them to the _to address.
        return true;
    }
    /*
     * Why Mint Tokens?: Minting allows the owner to increase the supply of tokens in circulation. This is common in stablecoin systems where tokens need to be issued based on user demand or collateral backing.
     */
}
