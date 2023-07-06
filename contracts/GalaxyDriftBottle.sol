// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract GalaxyDriftBottle is ERC721, ERC2981, ERC721Enumerable, Pausable, AccessControl, ERC721Burnable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    string private baseURI;
    string private baseExtension;
    mapping(address => uint256) public userStatus;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor(
        string memory name,
        string memory symbol,
        address _mintRole
    ) ERC721(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, _mintRole);
        _setDefaultRoyalty(msg.sender, 500);
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function airdrop(address[] memory addrs) public onlyRole(MINTER_ROLE) {
        for(uint256 i = 0; i < addrs.length; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(addrs[i], tokenId);
        }
    }

    function getBalanceIds(address _address) public view returns (uint256[] memory) {
        uint256 balance = balanceOf(_address);

        uint256[] memory ids = new uint256[](balance);

        for (uint256 i = 0; i < balance; i++) {
            uint256 _tokenId = tokenOfOwnerByIndex(_address, i);
            ids[i] = _tokenId;
        }
        return ids;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        string memory base = _baseURI();
        return bytes(base).length > 0 ? string(abi.encodePacked(base, tokenId.toString(), baseExtension)) : "";
    }
   
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyRole(DEFAULT_ADMIN_ROLE) {
        baseExtension = _newBaseExtension;
    }

    function setUserStatus(address[] memory addrs, uint256[] memory status) public onlyRole(MINTER_ROLE) {
        require(addrs.length == status.length, "Addrs and status length mismatch");
        for (uint256 i = 0; i < status.length; i++) {
            userStatus[addrs[i]] = status[i];
        }
    }

    // Royalty
    function setDefaultRoyalty(address _receiver, uint96 _feeNumerator) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }

    function deleteDefaultRoyalty() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _deleteDefaultRoyalty();
    }

    function setTokenRoyalty(
        uint256 _tokenId,
        address _receiver,
        uint96 _feeNumerator
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setTokenRoyalty(_tokenId, _receiver, _feeNumerator);
    }

    function resetTokenRoyalty(uint256 _tokenId) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _resetTokenRoyalty(_tokenId);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}