// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "forge-std/Test.sol";
// import { Registry } from "../src/Registry.sol";
// import { Registrar } from "../src/Registrar.sol";

// contract RegistryTest is Test {
//   Registry public registry;
//   Registrar public registrarA;

//   struct Pointer {
//     address owner;
//     address registrar;
//   }

//   event NewOwnerDescription(string _oldDesc, string _newDesc);
//   event NewOwnerWebsite(string _oldWebsite, string _newWebsite);
//   event NewOwnerEmail(string _oldEmail, string _newEmail);
//   event NewOwnerAvatar(string _oldAvatar, string _newAvatar);

//   event NewSubdomDescription(string _oldDesc, string _newDesc);
//   event NewSubdomWebsite(string _oldWebsite, string _newWebsite);
//   event NewSubdomEmail(string _oldEmail, string _newEmail);
//   event NewSubdomAvatar(string _oldAvatar, string _newAvatar);

//   event SubdomainTransfer(
//     bytes32 _subDomain,
//     address indexed _from,
//     address indexed _to
//   );

//   bytes32 _tld =
//     0x696e750000000000000000000000000000000000000000000000000000000000;

//   // Agents
//   address _deployer;
//   address _zero = address(0);
//   address _userA = address(1);
//   address _userB = address(2);
//   address _userC = address(3);

//   function setUp() public {
//     bytes32 _domainName = 0x756e697377617000000000000000000000000000000000000000000000000000;
//     _deployer = address(this);
//     registry = new Registry();

//     // "uniswap" in bytes32
//     vm.prank(_userA);
//     registry.newDomain(_domainName);

//     (, address registrarAdd) = registry.registry(_domainName);
//     registrarA = Registrar(registrarAdd);
//   }

//   function testInitialInfoRegistry() public {
//     assertEq(registry.owner(), _deployer);
//     assertEq(registry.TLD(), _tld);
//     assertEq(registry.name(), "SNSRegistry");
//     assertEq(registry.symbol(), "SNSR");
//   }

//   function testInitialInfoRegistrar() public {
//     bytes32 _domainName = 0x756e697377617000000000000000000000000000000000000000000000000000;
//     bytes32 parentDomain = registrarA.parentDomain();
//     address registryAdd = registrarA.registryContractAddr();
//     address regOwner = registrarA.owner();

//     assertEq(parentDomain, _domainName);
//     assertEq(registryAdd, address(registry));
//     assertEq(regOwner, _userA);
//   }

//   function testChangeOwnerInfo() public {
//     (
//       address ownerPrev,
//       string memory descripionPrev,
//       string memory websitePrev,
//       string memory emailPrev,
//       string memory avatarPrev
//     ) = registrarA.ownerInfo();

//     assertEq(ownerPrev, _userA);
//     assertEq(descripionPrev, "");
//     assertEq(websitePrev, "");
//     assertEq(emailPrev, "");
//     assertEq(avatarPrev, "");

//     string memory desc = "desc";
//     string memory webs = "www.x";
//     string memory email = "test@g.com";
//     string memory avatar = "imageHere";

//     vm.prank(_userA);
//     registrarA.setOwnerData(desc, webs, email, avatar);

//     (
//       address ownerNew,
//       string memory descripionNew,
//       string memory websiteNew,
//       string memory emailNew,
//       string memory avatarNew
//     ) = registrarA.ownerInfo();

//     assertEq(ownerNew, _userA);
//     assertEq(descripionNew, desc);
//     assertEq(websiteNew, webs);
//     assertEq(emailNew, email);
//     assertEq(avatarNew, avatar);
//   }

//   function testEventEmitionOnOwnerDataChange() public {
//     string memory desc = "desc";
//     string memory webs = "www.x";
//     string memory email = "test@g.com";
//     string memory avatar = "imageHere";

//     (
//       address oldOwner,
//       string memory oldDesc,
//       string memory oldWeb,
//       string memory oldEmail,
//       string memory oldAvatar
//     ) = registrarA.ownerInfo();

//     assertEq(oldOwner, _userA);

//     vm.prank(_userA);
//     vm.expectEmit();
//     emit NewOwnerDescription(oldDesc, desc);
//     registrarA.setOwnerDescription(desc);

//     vm.prank(_userA);
//     vm.expectEmit();
//     emit NewOwnerWebsite(oldWeb, webs);
//     registrarA.setOwnerWebsite(webs);

//     vm.prank(_userA);
//     vm.expectEmit();
//     emit NewOwnerEmail(oldEmail, email);
//     registrarA.setOwnerEmail(email);

//     vm.prank(_userA);
//     vm.expectEmit();
//     emit NewOwnerAvatar(oldAvatar, avatar);
//     registrarA.setOwnerAvatar(avatar);
//   }

//   function testNewSubdomain() public {
//     bytes32 _subdomain = 0x7465737400000000000000000000000000000000000000000000000000000000;
//     string memory desc = "desc";
//     string memory webs = "www.x";
//     string memory email = "test@g.com";
//     string memory avatar = "imageHere";

//     vm.prank(_userA);
//     registrarA.setNewSubdomain(_subdomain, _userB, desc, email, webs, avatar);

//     (
//       address subOwner,
//       string memory subDesc,
//       string memory subWebs,
//       string memory subEmail,
//       string memory subAvatar
//     ) = registrarA.subDomainData(_subdomain);

//     bool hasSubdom = registrarA.hasSubDomain(_userB);
//     assert(hasSubdom);
//     assertEq(subOwner, _userB);
//     assertEq(subDesc, desc);
//     assertEq(subEmail, email);
//     assertEq(subWebs, webs);
//     assertEq(subAvatar, avatar);
//   }

//   function testEmitEventsOnSubdomInfoChange() public {
//     bytes32 _subdomain = 0x7465737400000000000000000000000000000000000000000000000000000000;
//     string memory descA = "desc";
//     string memory websA = "www.x";
//     string memory emailA = "test@g.com";
//     string memory avatarA = "imageHere";

//     string memory descB = "desc";
//     string memory websB = "www.x";
//     string memory emailB = "test@g.com";
//     string memory avatarB = "imageHere";

//     vm.prank(_userA);
//     registrarA.setNewSubdomain(
//       _subdomain,
//       _userB,
//       descA,
//       emailA,
//       websA,
//       avatarA
//     );

//     vm.prank(_userB);
//     vm.expectEmit();
//     emit NewSubdomDescription(descA, descB);
//     registrarA.changeSubdomainDescription(_subdomain, descB);

//     vm.prank(_userB);
//     vm.expectEmit();
//     emit NewSubdomEmail(emailA, emailB);
//     registrarA.changeSubdomainEmail(_subdomain, emailB);

//     vm.prank(_userB);
//     vm.expectEmit();
//     emit NewSubdomWebsite(websA, websB);
//     registrarA.changeSubdomainWebsite(_subdomain, websB);

//     vm.prank(_userB);
//     vm.expectEmit();
//     emit NewSubdomAvatar(avatarA, avatarB);
//     registrarA.changeSubdomainAvatar(_subdomain, avatarB);
//   }

//   function testRevertIfNotOwner() public {
//     bytes32 _subdomain = 0x7465737400000000000000000000000000000000000000000000000000000000;

//     string memory desc = "desc";
//     string memory webs = "www.x";
//     string memory email = "test@g.com";
//     string memory avatar = "imageHere";

//     vm.expectRevert(bytes("Ownable: caller is not the owner"));
//     registrarA.setOwnerData(desc, webs, email, avatar);

//     vm.prank(_userA);
//     registrarA.setNewSubdomain(_subdomain, _userB, desc, email, webs, avatar);

//     vm.prank(_userC);
//     vm.expectRevert(bytes("You are not the owner of this sub-domain"));
//     registrarA.changeSubdomainEmail(_subdomain, email);
//   }

//   function testValidatesNames() public {
//     bytes32 _spaces = 0x7761736420776461730000000000000000000000000000000000000000000000;
//     bytes32 _specialChar = 0x7761736440214021332424000000000000000000000000000000000000000000;
//     bytes32 _empty = 0x0000000000000000000000000000000000000000000000000000000000000000;

//     vm.prank(_userA);
//     bool spaces = registrarA.validateName(_spaces);
//     assert(!spaces);
//     bool special = registrarA.validateName(_specialChar);
//     assert(!special);
//     bool empty = registrarA.validateName(_empty);
//     assert(!empty);
//   }

//   function testRegistersAndActivatesSubdomain() public {
//     bytes32 _subdomain = 0x7465737400000000000000000000000000000000000000000000000000000000;
//     string memory desc = "desc";
//     string memory webs = "www.x";
//     string memory email = "test@g.com";
//     string memory avatar = "imageHere";

//     vm.prank(_userA);
//     registrarA.setNewSubdomain(_subdomain, _userB, desc, email, webs, avatar);
//     assert(registrarA.registered(_subdomain));
//     assert(registrarA.isDomainActive(_subdomain));
//   }

//   function testReverstIfSubdomainAlreadyExists() public {
//     bytes32 _subdomain = 0x7465737400000000000000000000000000000000000000000000000000000000;
//     string memory desc = "desc";
//     string memory webs = "www.x";
//     string memory email = "test@g.com";
//     string memory avatar = "imageHere";

//     vm.prank(_userA);
//     registrarA.setNewSubdomain(_subdomain, _userB, desc, email, webs, avatar);

//     vm.prank(_userA);
//     vm.expectRevert(bytes("This subdomain already exists!"));
//     registrarA.setNewSubdomain(_subdomain, _userB, desc, email, webs, avatar);
//   }

//   function testTransfersSubdomain() public {
//     bytes32 _subdomain1 = 0x7465737400000000000000000000000000000000000000000000000000000000;
//     string memory desc = "desc";
//     string memory webs = "www.x";
//     string memory email = "test@g.com";
//     string memory avatar = "imageHere";

//     vm.prank(_userA);
//     registrarA.setNewSubdomain(_subdomain1, _userB, desc, email, webs, avatar);

//     (
//       address subOwner,
//       string memory desc2,
//       string memory webs2,
//       string memory email2,
//       string memory avat2
//     ) = registrarA.subDomainData(_subdomain1);
//     assertEq(subOwner, _userB);

//     vm.prank(_userB);
//     registrarA.transferSubDomain(_subdomain1, _userC);

//     (address subOwner1, , , , ) = registrarA.subDomainData(_subdomain1);
//     assertEq(subOwner1, _userC);

//     assertEq(desc, desc2);
//     assertEq(webs, webs2);
//     assertEq(email, email2);
//     assertEq(avat2, avatar);
//   }

//   function testAddSubdomToList() public {
//     bytes32 _subdomain1 = 0x7465737400000000000000000000000000000000000000000000000000000000;
//     string memory desc = "desc";
//     string memory webs = "www.x";
//     string memory email = "test@g.com";
//     string memory avatar = "imageHere";

//     vm.prank(_userA);
//     registrarA.setNewSubdomain(_subdomain1, _userB, desc, email, webs, avatar);

//     bool contains;
//     contains = _subdomain1 == registrarA.subDomainsList(0);
//     assert(contains);
//   }

//   function testGetSubdomains() public {
//     bytes32 _subdomain1 = 0x7465737400000000000000000000000000000000000000000000000000000000;
//     string memory desc = "desc";
//     string memory webs = "www.x";
//     string memory email = "test@g.com";
//     string memory avatar = "imageHere";

//     vm.prank(_userA);
//     registrarA.setNewSubdomain(_subdomain1, _userB, desc, email, webs, avatar);

//     bytes32[] memory result = registrarA.getAllSubDomains();

//     assertEq(result[0], _subdomain1);
//     assert(registrarA.isDomainActive(_subdomain1));
//   }

//   function testDeleteSubdomain() public {
//     bytes32 _subdomain1 = 0x7465737400000000000000000000000000000000000000000000000000000000;
//     string memory desc = "desc";
//     string memory webs = "www.x";
//     string memory email = "test@g.com";
//     string memory avatar = "imageHere";

//     vm.prank(_userA);
//     registrarA.setNewSubdomain(_subdomain1, _userB, desc, email, webs, avatar);

//     bytes32[] memory result = registrarA.getAllSubDomains();

//     assertEq(result[0], _subdomain1);
//     assert();
//     assert(!registrarA.isDomainActive(_subdomain1));
//   }
// }
