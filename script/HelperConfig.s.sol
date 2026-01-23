// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

uint8 public constant DECIMALS = 8;
int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    // Public so we get an auto-generated getter
    NetworkConfig public activeNetworkConfig;




    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // Sepolia ETH / USD
        NetworkConfig memory sepoliaConfig =
            NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // Mainnet ETH / USD
        NetworkConfig memory ethConfig =
            NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethConfig;
    }

    // Add this for local Anvil: deploy or point to a mock
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;

        } 
      // price  feed address

      // 01. Deploy the mocks
      // 02. Return the mock address

      vm.startBroadcast();
      MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
      vm.stopBroadcast();


      NetworkConfig memory anvilConfig  = NetworkConfig({
        priceFeed: address (mockPriceFeed)
      });

      return anvilConfig;
    }

    
}
