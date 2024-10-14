// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

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
pragma solidity ^0.8.18;

import {ERC20Burnable, ERC20} from "@openzeppelin/openzeppelin-contracts/token/ERC20/extensions/ERC20Burnable.sol"; //ERC20Burnable includes `burn` functionality for our tokens which will be important when we need to take the asset out of circulation to support stability.
import {Ownable} from "@openzeppelin/openzeppelin-contracts/access/Ownable.sol";

contract ArceusStableCoin is ERC20Burnable, Ownable {
    error ArceusStableCoin__mustBeMoreThanZero();
    error ArceusStableCoin__BurnAmountExceedsBalance();
    error ArceusStableCoin__NotZeroAddress();

    constructor() ERC20("ArceusStableCoin", "ARC") {}

    function burn(uint _amount) external override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert ArceusStableCoin__mustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert ArceusStableCoin__BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert ArceusStableCoin__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert ArceusStableCoin__mustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
