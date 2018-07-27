pragma solidity ^0.4.23;
pragma experimental ABIEncoderV2;

import './DGame.sol';

contract Arcadeum {
  mapping(address => uint) public balance;
  mapping(address => uint) public withdrawalTime;

  function deposit() external payable;

  function isWithdrawing(address account) public view returns (bool);

  function startWithdrawal() external;

  function canFinishWithdrawal(address account) public view returns (bool);

  function finishWithdrawal() external;

  // XXX: abigen: Failed to generate ABI binding: unsupported arg type: tuple
  function couldStopWithdrawalXXX(uint timestamp, uint8 timestampV, bytes32 timestampR, bytes32 timestampS, uint8 subkeyV, bytes32 subkeyR, bytes32 subkeyS) public view returns (bool);

  // XXX: abigen: Failed to generate ABI binding: unsupported arg type: tuple
  function canStopWithdrawalXXX(uint timestamp, uint8 timestampV, bytes32 timestampR, bytes32 timestampS, uint8 subkeyV, bytes32 subkeyR, bytes32 subkeyS) public view returns (bool);

  // XXX: abigen: Failed to generate ABI binding: unsupported arg type: tuple
  function stopWithdrawalXXX(uint timestamp, uint8 timestampV, bytes32 timestampR, bytes32 timestampS, uint8 subkeyV, bytes32 subkeyR, bytes32 subkeyS) public;

  event balanceChanged(address indexed account);
  event withdrawalStarted(address indexed account);
  event withdrawalStopped(address indexed account);
  event rewardClaimed(address indexed account, address indexed subkey, uint indexed timestamp);
  event cheaterReported(address indexed account, address indexed subkey, uint indexed timestamp);

  function subkeyMessage(address subkey) public pure returns (string);

  // XXX: abigen: Failed to generate ABI binding: unsupported arg type: tuple
  function subkeyParentXXX(address subkey, uint8 subkeyV, bytes32 subkeyR, bytes32 subkeyS) public pure returns (address);

  // XXX: abigen: Failed to generate ABI binding: unsupported arg type: tuple
  function timestampSubkeyXXX(uint timestamp, uint8 timestampV, bytes32 timestampR, bytes32 timestampS) public pure returns (address);

  // XXX: abigen: Failed to generate ABI binding: unsupported arg type: tuple
  function playerAccountXXX(uint timestamp, uint8 timestampV, bytes32 timestampR, bytes32 timestampS, uint8 subkeyV, bytes32 subkeyR, bytes32 subkeyS) public pure returns (address);

  function matchHash(DGame game, uint timestamp, address[2] accounts, address[2] subkeys, uint32[2] seedRatings, bytes[2] publicSeeds) public pure returns (bytes32);
}
