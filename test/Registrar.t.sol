// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import { Registry } from "../src/Registry.sol";
import { Registrar } from "../src/Registrar.sol";

contract RegistryTest is Test {
  Registry public registry;
  Registrar public registrarA;

  struct Pointer {
    address owner;
    address registrar;
  }

  event NewOwnerDescription(string _oldDesc, string _newDesc);
  event NewOwnerWebsite(string _oldWebsite, string _newWebsite);
  event NewOwnerEmail(string _oldEmail, string _newEmail);
  event NewOwnerAvatar(string _oldAvatar, string _newAvatar);

  event NewSubdomain(bytes32 _name, address target);
  event NewSubdomDescription(string _oldDesc, string _newDesc);
  event NewSubdomTarget(address _oldTarget, address _newTarget);
  event SubdomainTransfer(bytes32 _subDomain, address _from, address _to);

  bytes32 _tld =
    0x696e750000000000000000000000000000000000000000000000000000000000;

  // Agents
  address _deployer;
  address _zero = address(0);
  address _userA = address(1);
  address _userB = address(2);
  address _userC = address(3);
  address _userD = address(4);

  function setUp() public {
    bytes32 _domainName = 0x756e697377617000000000000000000000000000000000000000000000000000;
    _deployer = address(this);
    registry = new Registry();

    // "uniswap" in bytes32
    vm.prank(_userA);
    registry.newDomain(_domainName);

    (, address registrarAdd) = registry.registry(_domainName);
    registrarA = Registrar(registrarAdd);
  }

  function testInitialInfoRegistry() public {
    assertEq(registry.owner(), _deployer);
    assertEq(registry.TLD(), _tld);
    assertEq(registry.name(), "SNSRegistry");
    assertEq(registry.symbol(), "SNSR");
  }

  function testInitialInfoRegistrar() public {
    bytes32 _domainName = 0x756e697377617000000000000000000000000000000000000000000000000000;
    bytes32 parentDomain = registrarA.parentDomain();
    address registryAdd = registrarA.registryContractAddr();
    address regOwner = registrarA.owner();

    assertEq(parentDomain, _domainName);
    assertEq(registryAdd, address(registry));
    assertEq(regOwner, _userA);
  }

  function testChangeOwnerInfo() public {
    (
      address ownerPrev,
      string memory descripionPrev,
      string memory websitePrev,
      string memory emailPrev,
      string memory avatarPrev
    ) = registrarA.ownerInfo();

    assertEq(ownerPrev, _userA);
    assertEq(descripionPrev, "");
    assertEq(websitePrev, "");
    assertEq(emailPrev, "");
    assertEq(avatarPrev, "");

    string memory desc = "desc";
    string memory webs = "www.x";
    string memory email = "test@g.com";
    string memory avatar = "imageHere";

    vm.prank(_userA);
    registrarA.setOwnerData(desc, webs, email, avatar);

    (
      address ownerNew,
      string memory descripionNew,
      string memory websiteNew,
      string memory emailNew,
      string memory avatarNew
    ) = registrarA.ownerInfo();

    assertEq(ownerNew, _userA);
    assertEq(descripionNew, desc);
    assertEq(websiteNew, webs);
    assertEq(emailNew, email);
    assertEq(avatarNew, avatar);
  }

  function testEventEmitionOnOwnerDataChange() public {
    string memory desc = "desc";
    string memory webs = "www.x";
    string memory email = "test@g.com";
    string memory avatar = "imageHere";

    (
      address oldOwner,
      string memory oldDesc,
      string memory oldWeb,
      string memory oldEmail,
      string memory oldAvatar
    ) = registrarA.ownerInfo();

    assertEq(oldOwner, _userA);

    vm.prank(_userA);
    vm.expectEmit();
    emit NewOwnerDescription(oldDesc, desc);
    registrarA.setOwnerDescription(desc);

    vm.prank(_userA);
    vm.expectEmit();
    emit NewOwnerWebsite(oldWeb, webs);
    registrarA.setOwnerWebsite(webs);

    vm.prank(_userA);
    vm.expectEmit();
    emit NewOwnerEmail(oldEmail, email);
    registrarA.setOwnerEmail(email);

    vm.prank(_userA);
    vm.expectEmit();
    emit NewOwnerAvatar(oldAvatar, avatar);
    registrarA.setOwnerAvatar(avatar);
  }

  function testNewSubdomain() public {
    bytes32 _subdomain = 0x7465737400000000000000000000000000000000000000000000000000000000;
    string memory desc = "desc";

    vm.prank(_userA);
    registrarA.setNewSubdomain(_subdomain, _userB, desc);

    (address subOwner, string memory subDesc) = registrarA.subDomainData(
      _subdomain
    );

    bool hasSubdom = registrarA.hasSubDomain(_userB);
    assert(hasSubdom);
    assertEq(subOwner, _userB);
    assertEq(subDesc, desc);
  }

  function testEmitEventsOfSubdomains() public {
    bytes32 _subdomainA = 0x7465737400000000000000000000000000000000000000000000000000000000;
    bytes32 _subdomainB = 0x7465737474000000000000000000000000000000000000000000000000000000;

    string memory descA = "desc a";
    string memory descA2 = "desc a new";
    address targetA = _userB;

    string memory descB = "desc b";
    address targetB = _userC;

    vm.prank(_userA);
    vm.expectEmit();
    emit NewSubdomain(_subdomainA, targetA);
    registrarA.setNewSubdomain(_subdomainA, targetA, descA);

    vm.prank(_userA);
    vm.expectEmit();
    emit NewSubdomain(_subdomainB, targetB);
    registrarA.setNewSubdomain(_subdomainB, targetB, descB);

    vm.prank(_userA);
    vm.expectEmit();
    emit NewSubdomDescription(descA, descA2);
    registrarA.changeSubdomainDescription(_subdomainA, descA2);

    vm.prank(_userA);
    vm.expectEmit();
    emit NewSubdomTarget(targetB, _userD);
    registrarA.changeSubdomainTarget(_subdomainB, _userD);
  }

  function testRevertsIfSubdomainAlreadyExists() public {
    bytes32 _subdomain = 0x7465737400000000000000000000000000000000000000000000000000000000;
    bytes32 _subdomain2 = 0x7465737474000000000000000000000000000000000000000000000000000000;
    string memory desc = "desc";

    vm.prank(_userB);
    vm.expectRevert(bytes("Ownable: caller is not the owner"));
    registrarA.setNewSubdomain(_subdomain, _userB, desc);

    vm.prank(_userA);
    registrarA.setNewSubdomain(_subdomain, _userB, desc);

    vm.prank(_userA);
    vm.expectRevert(bytes("This subdomain already exists!"));
    registrarA.setNewSubdomain(_subdomain, _userA, desc);

    vm.prank(_userA);
    vm.expectRevert(bytes("This address already has a subdomain"));
    registrarA.setNewSubdomain(_subdomain2, _userB, desc);
  }

  function testAddAndRemoveDomains() public {
    bytes32 _subdomain1 = 0x7465737400000000000000000000000000000000000000000000000000000000;
    bytes32 _subdomain2 = 0x7465737474000000000000000000000000000000000000000000000000000000;
    bytes32 _subdomain3 = 0x7465737474740000000000000000000000000000000000000000000000000000;
    bytes32 _subdomain4 = 0x7465737474747400000000000000000000000000000000000000000000000000;

    string memory desc = "desc";

    vm.prank(_userA);
    registrarA.setNewSubdomain(_subdomain1, _userB, desc);

    vm.prank(_userA);
    registrarA.setNewSubdomain(_subdomain2, _userC, desc);

    vm.prank(_userA);
    registrarA.setNewSubdomain(_subdomain3, _userD, desc);

    bool hasSubB = registrarA.hasSubDomain(_userB);
    bool hasSubC = registrarA.hasSubDomain(_userC);
    bool hasSubD = registrarA.hasSubDomain(_userD);

    bool registeredB = registrarA.registered(_subdomain1);
    bool registeredC = registrarA.registered(_subdomain2);
    bool registeredD = registrarA.registered(_subdomain3);
    bool registeredE = registrarA.registered(_subdomain4);

    assert(hasSubB);
    assert(hasSubC);
    assert(hasSubD);

    assert(registeredB);
    assert(registeredC);
    assert(registeredD);
    assert(!registeredE);

    bytes32 name1 = registrarA.subDomains(0);
    bytes32 name2 = registrarA.subDomains(1);
    bytes32 name3 = registrarA.subDomains(2);

    assertEq(name1, _subdomain1);
    assertEq(name2, _subdomain2);
    assertEq(name3, _subdomain3);

    vm.prank(_userA);
    registrarA.deleteSubDomain(_subdomain1);

    bytes32 after1 = registrarA.subDomains(0);
    bytes32 after2 = registrarA.subDomains(1);

    assertEq(after1, _subdomain3);
    assertEq(after2, _subdomain2);

    bool hasSubB2 = registrarA.hasSubDomain(_userB);
    bool registeredB2 = registrarA.registered(_subdomain1);

    assert(!hasSubB2);
    assert(!registeredB2);
  }
}
