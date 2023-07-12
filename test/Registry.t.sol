// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import { Registry } from "../src/Registry.sol";
import { Registrar } from "../src/Registrar.sol";

contract RegistryTest is Test {
  Registry public registry;

  struct Pointer {
    address owner;
    address registrar;
  }

  event NewDomain(
    address indexed _creator,
    bytes32 indexed _domain,
    address indexed _registrar
  );

  event PrimaryDomainChange(address indexed _owner, bytes32 indexed _domain);

  bytes32 _tld =
    0x696e750000000000000000000000000000000000000000000000000000000000;

  // Agents
  address _deployer;
  address _zero = address(0);
  address _userA = address(1);
  address _userB = address(2);

  function setUp() public {
    _deployer = address(this);
    registry = new Registry();
  }

  function testInitialInfo() public {
    assertEq(registry.owner(), _deployer);
    assertEq(registry.TLD(), _tld);
    assertEq(registry.name(), "SNSRegistry");
    assertEq(registry.symbol(), "SNSR");
  }

  function testCreatesNewDomain() public {
    bytes32 _domainName = 0x756e697377617000000000000000000000000000000000000000000000000000;
    // "uniswap" in bytes32

    vm.prank(_userA);
    registry.newDomain(_domainName);

    bytes32 _domain = registry.tokenToDomain(0);
    assertEq(_domain, _domainName);

    (address dOwner, address dRegistrar) = registry.registry(_domainName);
    assertEq(_userA, dOwner);

    Registrar domainInfo = Registrar(dRegistrar);
    address registrarOwner = domainInfo.owner();
    assertEq(registrarOwner, _userA);
  }

  function testRevertInvalidName() public {
    bytes32 _domainName = 0x756e697377617023240000000000000000000000000000000000000000000000;
    // "uniswap#$" in bytes32

    vm.prank(_userA);
    vm.expectRevert(bytes("This is not a valid domain name!"));
    registry.newDomain(_domainName);
  }

  function testRevertNameTaken() public {
    bytes32 _domainName = 0x756e697377617000000000000000000000000000000000000000000000000000;
    // "uniswap" in bytes32

    vm.prank(_userA);
    registry.newDomain(_domainName);

    vm.prank(_userB);
    vm.expectRevert(bytes("This domain is not available"));
    registry.newDomain(_domainName);
  }

  function testCheckAvailable() public {
    bytes32 _domainName = 0x756e697377617000000000000000000000000000000000000000000000000000;
    // "uniswap" in bytes32
    bool isAvailableBefore = registry.checkAvailable(_domainName);
    assert(isAvailableBefore);

    vm.prank(_userA);
    registry.newDomain(_domainName);

    bool isAvailableAfter = registry.checkAvailable(_domainName);
    assert(!isAvailableAfter);
  }

  function testValidatesNames() public {
    bytes32 _spaces = 0x7761736420776461730000000000000000000000000000000000000000000000;
    bytes32 _specialChar = 0x7761736440214021332424000000000000000000000000000000000000000000;
    bytes32 _empty = 0x0000000000000000000000000000000000000000000000000000000000000000;

    vm.prank(_userA);
    bool spaces = registry.validateName(_spaces);
    assert(!spaces);
    bool special = registry.validateName(_specialChar);
    assert(!special);
    bool empty = registry.validateName(_empty);
    assert(!empty);
  }

  function testSetPrimary() public {
    bytes32 _domainName1 = 0x756e697377617000000000000000000000000000000000000000000000000000;
    bytes32 _domainName2 = 0x756e697377617031000000000000000000000000000000000000000000000000;

    vm.prank(_userA);
    registry.newDomain(_domainName1);

    vm.prank(_userA);
    registry.newDomain(_domainName2);

    bytes32 _domain = registry.tokenToDomain(0);
    assertEq(_domain, _domainName1);

    bytes32 _domain2 = registry.tokenToDomain(1);
    assertEq(_domain2, _domainName2);

    vm.prank(_userB);
    vm.expectRevert(bytes("You are not the onwer of this domain!"));
    registry.setPrimaryDomain(_domainName1);

    vm.prank(_userA);
    vm.expectRevert(bytes("This is already your primary domain!"));
    registry.setPrimaryDomain(_domainName1);

    vm.prank(_userA);
    vm.expectEmit();
    emit PrimaryDomainChange(_userA, _domainName2);
    registry.setPrimaryDomain(_domainName2);
  }

  function testTranferingDomains() public {
    bytes32 _domainName1 = 0x756e697377617000000000000000000000000000000000000000000000000000;
    bytes32 _domainName2 = 0x756e697377617031000000000000000000000000000000000000000000000000;

    vm.prank(_userA);
    registry.newDomain(_domainName1);

    vm.prank(_userA);
    registry.newDomain(_domainName2);

    assertEq(registry.primaryDomain(_userA), _domainName1);
    (, address _registrarAdd) = registry.registry(_domainName1);
    Registrar _domain1 = Registrar(_registrarAdd);
    address _regOwner = _domain1.owner();
    assertEq(_regOwner, _userA);

    vm.prank(_userA);
    registry.transferFrom(_userA, _zero, 0);

    bytes32 _bPrimary = registry.primaryDomain(_userB);
    assertEq(_bPrimary, _domainName1);
    Registrar _domain2 = Registrar(_registrarAdd);
    address _regOwner2 = _domain2.owner();
    assertEq(_regOwner2, _userB);
  }

  function testTransferPrimary() public {
    bytes32 _domainName1 = 0x756e697377617000000000000000000000000000000000000000000000000000;

    vm.prank(_userA);
    registry.newDomain(_domainName1);

    assertEq(registry.primaryDomain(_userA), _domainName1);

    vm.prank(_userA);
    registry.transferFrom(_userA, _userB, 0);

    bytes32 _bPrimary = registry.primaryDomain(_userB);
    assertEq(_bPrimary, _domainName1);

    bytes32 _aPrimary = registry.primaryDomain(_userA);
    assertEq(_aPrimary, 0);
  }
}
