// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
pragma abicoder v2;

import "openzeppelin-contracts/access/Ownable.sol";

contract Registrar is Ownable {
  struct Data {
    address owner;
    string description;
    string website;
    string email;
    string avatar;
  }

  struct SubDomainData {
    address target;
    string description;
  }

  bytes32 public parentDomain;
  address public registryContractAddr;

  event NewOwnerDescription(string indexed _oldDesc, string indexed _newDesc);
  event NewOwnerWebsite(string indexed _oldWeb, string indexed _newWeb);
  event NewOwnerEmail(string indexed _oldEmail, string indexed _newEmail);
  event NewOwnerAvatar(string indexed _oldAvatar, string indexed _newAvatar);

  event NewSubdomDescription(string indexed _oldDesc, string indexed _newDesc);
  event NewSubdomTarget(address indexed _oldTarget, address indexed _newTarget);

  event SubdomainTransfer(
    bytes32 _subDomain,
    address indexed _from,
    address indexed _to
  );

  Data public ownerInfo;

  bytes32[] public subDomains;
  mapping(bytes32 => SubDomainData) public subDomainData;
  mapping(bytes32 => bool) public registered;
  mapping(address => bool) public hasSubDomain;

  constructor(bytes32 _domain, address _domainOwner) {
    parentDomain = _domain;
    registryContractAddr = msg.sender;
    _transferOwnership(_domainOwner);
    ownerInfo.owner = _domainOwner;
  }

  function transfer(address _newOwner) public {
    require(msg.sender == registryContractAddr, "Caller is not Registry");
    _transferOwnership(_newOwner);
  }

  // owner issues a new domain
  function setNewSubdomain(
    bytes32 _subDomain,
    address _target,
    string memory _description
  ) public onlyOwner {
    require(!registered[_subDomain], "This subdomain already exists!");
    require(!hasSubDomain[_target], "This address already has a subdomain");
    require(validateName(_subDomain), "This is not a valid domain name!");

    addToSubdomainList(_subDomain);

    subDomainData[_subDomain].target = _target;
    subDomainData[_subDomain].description = _description;

    registered[_subDomain] = true;
    hasSubDomain[_target] = true;
  }

  function _addToSubdomainList(bytes32 _subdomain) internal {
    subDomains.push(_subdomain);
  }

  // resets all info and tranfers to zero address
  function deleteSubDomain(bytes32 _subDomain) public onlyOwner {
    require(registered[_subDomain], "This subdomain is not registered!");

    uint256 _subdomIndex;
    for (uint256 i; i < subDomains.length; i++) {
      if (_subDomain == subDomains[i]) {
        _subdomIndex = i;
        return;
      }
    }

    address prevOwner = subDomainData[_subDomain].target;
    hasSubDomain[prevOwner] = false;
    registered[_subDomain] = false;

    subDomains[_subdomIndex] = subDomains[subDomains.length - 1];
    subDomains.pop();

    subDomainData[_subDomain].target = address(0);
    subDomainData[_subDomain].description = "";
  }

  function validateName(bytes32 _name) public pure returns (bool) {
    if (_name == 0) return false;

    for (uint i; i < 32; i++) {
      bytes1 char = _name[i];

      if (char == 0x20) return false;

      if (
        !((char >= 0x30 && char <= 0x39) ||
          (char >= 0x61 && char <= 0x7A) ||
          (char == 0x00))
      ) return false;
    }
    return true;
  }

  // -------------------- Setters ------------------------------
  function setOwnerData(
    string memory _description,
    string memory _website,
    string memory _email,
    string memory _avatar
  ) public onlyOwner {
    setOwnerDescription(_description);
    setOwnerWebsite(_website);
    setOwnerEmail(_email);
    setOwnerAvatar(_avatar);
  }

  function setOwnerDescription(string memory _description) public onlyOwner {
    string memory oldDescription = ownerInfo.description;
    ownerInfo.description = _description;
    emit NewOwnerDescription(oldDescription, _description);
  }

  function setOwnerWebsite(string memory _website) public onlyOwner {
    string memory oldWebsite = ownerInfo.website;
    ownerInfo.website = _website;
    emit NewOwnerWebsite(oldWebsite, _website);
  }

  function setOwnerEmail(string memory _email) public onlyOwner {
    string memory oldEmail = ownerInfo.email;
    ownerInfo.email = _email;
    emit NewOwnerEmail(oldEmail, _email);
  }

  function setOwnerAvatar(string memory _avatar) public onlyOwner {
    string memory oldAvatar = ownerInfo.avatar;
    ownerInfo.avatar = _avatar;
    emit NewOwnerAvatar(oldAvatar, _avatar);
  }

  // Subdomain Changes
  function changeSubdomainDescription(
    bytes32 _subDomain,
    string memory _description
  ) public onlyOwner {
    require(registered[_subDomain], "This subdomain is not registered!");
    string memory oldDesc = subDomainData[_subDomain].description;

    subDomainData[_subDomain].description = _description;
    emit NewSubdomDescription(oldDesc, _description);
  }

  function changeSubdomainTarget(
    bytes32 _subDomain,
    address _target
  ) public onlyOwner {
    require(registered[_subDomain], "This subdomain is not registered!");
    require(!hasSubDomain[_target], "The new target already has a subdomain.");

    address oldAdd = subDomainData[_subDomain].target;
    subDomainData[_subDomain].target = _target;
    emit NewSubdomTarget(oldAdd, _target);
  }
}
