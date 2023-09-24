// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";
import "openzeppelin-contracts/contracts/token/ERC1155/IERC1155Receiver.sol";
//6551 references
import "@6551/interfaces/IERC6551Account.sol";
import "@6551/lib/ERC6551AccountLib.sol";

abstract contract PoSImplementation is
    IERC165,
    IERC6551Account,
    IERC721Receiver
{
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
//////////////////////////////////////////////////////////////*/

    /// @notice This ERC6551 implementation contract does not accept NFTs except for the one that owns it.
    /// @dev Emitted when any other NFT is sent to this contract.
    error PoSDoesNotAccept721s();

    /// @notice This ERC6551 implementation contract does not accept NFTs except for the one that owns it.
    /// @dev Emitted when any other NFT is sent to this contract.
    error PoSDoesNotAccept1155s();

    /*//////////////////////////////////////////////////////////////
                                 FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /// @notice Nonce is not supported in this 6551 implementation
    /// @dev Included to maintain 6551 interface compliance
    /// @return uint256 The nonce
    function nonce() external pure returns (uint256) {
        return (0);
    }

    /// @notice Emits an event when the contract receives ETH
    receive() external payable {}

    /// @notice This function will revert when called.
    /// @dev The function is included only to remain 6551 compliant.
    /// @param to The address to call
    /// @param value The value to pass
    /// @param data The calldata
    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory) {
        require(value <= address(this).balance);
        payable(to).call{value: value}(data);
    }

    /// @notice Returns identifiers of the NFT that owns this account
    /// @dev Returns identifier of the ERC-721 token which owns the account
    /// @return chainId The EIP-155 ID of the chain the ERC-721 token exists on
    /// @return tokenContract The contract address of the ERC-721 token
    /// @return tokenId The ID of the ERC-721 token
    function token()
        public
        view
        returns (uint256 chainId, address tokenContract, uint256 tokenId)
    {
        return ERC6551AccountLib.token();
    }

    /// @notice Returns the owner of the ERC-721 token which controls the account if the token exists.
    /// @dev This is value is obtained by calling `ownerOf` on the ERC-721 contract.
    /// @return Address of the owner of the ERC-721 token which owns the account
    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = this
            .token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return (interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC6551Account).interfaceId);
    }

    /// @notice Burns the 721 that owns this account and sends the ETH balance to the NFT owner, or reverts if it receives any other 721.
    /// @dev Called by 721 contracts when sending ERC721s to this contract.
    /// @inheritdoc IERC721Receiver
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        // Grab the info about the token associated with this 6551 account
        (uint256 nftChainId, address nftAddress, uint256 nftId) = token();

        // Revert if the 721 transferred to the contract is not the token that owns this account
        if (
            nftChainId != block.chainid ||
            tokenId != nftId ||
            msg.sender != nftAddress
        ) {
            revert PoSDoesNotAccept721s();
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice This function will revert when called.
    /// @dev Handles the receipt of a single ERC1155 token type. This function is called at the end of a `safeTransferFrom` after the balance has been updated.
    /// @param operator The address which initiated the transfer (i.e. msg.sender)
    /// @param from The address which previously owned the token
    /// @param id The ID of the token being transferred
    /// @param value The amount of tokens being transferred
    /// @param data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` (i.e., `0xf23a6e61`) if transfer is allowed
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure returns (bytes4) {
        revert PoSDoesNotAccept1155s();
    }
}