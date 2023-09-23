// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

contract IERC721 {
    function supportsInterface(
        bytes4 interfaceId
    ) external view virtual override(ERC165, IERC165) returns (bool);

    function balanceOf(
        address owner
    ) external view override returns (uint256);

    function ownerOf(
        uint256 tokenId
    ) external view virtual override returns (address);

    function name() external view virtual override returns (string memory);

    function symbol() external view virtual override returns (string memory);

    function tokenURI(
        uint256 tokenId
    ) external view virtual override returns (string memory);
    function approve(address to, uint256 tokenId) external virtual override;
    function getApproved(
        uint256 tokenId
    ) external view virtual override returns (address);

    function setApprovalForAll(
        address operator,
        bool approved
    ) external virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) external view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external virtual override;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external virtual override;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public external override;
}