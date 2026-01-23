// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    // Minimum contribution set to 5 USD (18 decimals)
    uint256 public constant MINIMUM_USD = 5e18;

    AggregatorV3Interface private s_priceFeed;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Send at least $5 worth of ETH");
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

    function getVersion() public view returns (uint256) {
        // Use the same Sepolia ETH/USD price feed address as PriceConverter
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
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
