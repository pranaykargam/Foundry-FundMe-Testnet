// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    // Minimum contribution set to 5 USD (18 decimals)
    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Send at least $5 worth of ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    function withdraw(uint256 amountToWithdraw) public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);

        // call
        (bool callSuccess,) = payable(msg.sender).call{value: amountToWithdraw}("");

        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert NotOwner();
        _; // is a placeholder for the body of the function that uses the modifier.
    }

    // what happens if some one send this contract ETH without calling the fund function.

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
