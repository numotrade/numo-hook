// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseHook} from "./forks/BaseHook.sol";

import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {Lockers} from "@uniswap/v4-core/contracts/libraries/Lockers.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts/types/Currency.sol";

contract Numo is BaseHook {
    address public token0;
    address public token1;
    uint256 public weight0; // Weight for token0 (e.g., 60% = 0.6e18)
    uint256 public weight1; // Weight for token1 (e.g., 40% = 0.4e18)
    uint256 public baseFee; // Base fee (e.g., 0.003e18 for 0.3%)

    constructor(
        address _token0,
        address _token1,
        uint256 _weight0,
        uint256 _weight1,
        uint256 _baseFee
    ) {
        require(_weight0 + _weight1 == 1e18, "Invalid weights");
        token0 = _token0;
        token1 = _token1;
        weight0 = _weight0;
        weight1 = _weight1;
        baseFee = _baseFee;
    }

    function onSwap(
        address, /* sender */
        uint256 amountIn,
        uint256, /* amountOut */
        address tokenIn,
        address /* tokenOut */
    ) external view override returns (uint256 newAmountOut, uint256 fee) {
        // Calculate the effective balance of each token
        uint256 balance0 = IERC20(token0).balanceOf(msg.sender);
        uint256 balance1 = IERC20(token1).balanceOf(msg.sender);

        // Determine the price based on weight ratios
        if (tokenIn == token0) {
            newAmountOut = calculateWeightedSwap(balance0, balance1, amountIn, weight0, weight1);
        } else {
            newAmountOut = calculateWeightedSwap(balance1, balance0, amountIn, weight1, weight0);
        }

        // Apply a fee based on the distance from the target ratio
        fee = calculateFee(balance0, balance1, tokenIn == token0 ? weight0 : weight1, baseFee);
        newAmountOut -= fee;
    }

    function calculateWeightedSwap(
        uint256 balanceIn,
        uint256 balanceOut,
        uint256 amountIn,
        uint256 weightIn,
        uint256 weightOut
    ) internal pure returns (uint256) {
        // Apply a Balancer-like weighted price formula
        uint256 weightedRatio = (balanceIn + amountIn) * weightOut / (balanceOut * weightIn);
        return amountIn * weightedRatio;
    }

    function calculateFee(
        uint256 balance0,
        uint256 balance1,
        uint256 targetWeight,
        uint256 baseFee
    ) internal pure returns (uint256) {
        // Calculate deviation from target weight
        uint256 currentWeight = balance0 * 1e18 / (balance0 + balance1);
        uint256 deviation = (currentWeight > targetWeight) ? currentWeight - targetWeight : targetWeight - currentWeight;
        
        // Higher deviation implies a larger fee to incentivize rebalancing
        return baseFee + (deviation * baseFee / 1e18);
    }
}
