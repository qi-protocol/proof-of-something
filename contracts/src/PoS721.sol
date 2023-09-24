// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Base64} from "openzeppelin-contracts/contracts/utils/Base64.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "@6551/lib/ERC6551AccountLib.sol";
import "@6551/interfaces/IERC6551Registry.sol";
import "./IWorldID.sol";

contract PoS721 is ERC721 {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 public totalSupply; // The total number of tokens minted on this contract
    address public immutable implementation; // The PoS6551Implementation address
    IERC6551Registry public immutable registry; // The 6551 registry address
    uint public immutable chainId = block.chainid; // The chainId of the network this contract is deployed on
    address public immutable tokenContract = address(this); // The address of this contract
    uint salt = 0; // The salt used to generate the account address
    uint public immutable maxSupply; // The maximum number of tokens that can be minted on this contract
    uint public immutable price;

    /// @notice Thrown when attempting to reuse a nullifier
    error InvalidNullifier();

    /// @dev The address of the World ID Router contract that will be used for verifying proofs
    IWorldID internal immutable worldId = IWorldID(0x11cA3127182f7583EfC416a8771BD4d11Fae4334);

    /// @dev The keccak256 hash of the externalNullifier (unique identifier of the action performed), combination of appId and action
    uint256 internal immutable externalNullifierHash;

    string public appId = "app_staging_6b6a58cc303bea4e83f09d790b4f814d";

    /// @dev The World ID group ID (1 for Orb-verified)
    uint256 internal immutable groupId = 1;

    /// @dev Whether a nullifier hash has been used already. Used to guarantee an action is only performed once by a single person
    mapping(uint256 => bool) internal nullifierHashes;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(
        address _implementation,
        address _registry,
        uint _maxSupply,
        uint _price
    ) ERC721("PoS721", "POS") {
        implementation = _implementation;
        //registry = IERC6551Registry(_registry);
        registry = IERC6551Registry(0x02101dfB77FDE026414827Fdc604ddAF224F0921);
        maxSupply = _maxSupply;
        price = _price;
        externalNullifierHash = uint256(keccak256(abi.encode("NOUNs are fun")));
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function hashToField(bytes memory value) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(value))) >> 8;
    }


    function getAccount(uint tokenId) public view returns (address) {
        return
            registry.account(
                implementation,
                chainId,
                tokenContract,
                tokenId,
                salt
            );
    }

function verifyAndExecute(
    bytes memory signal,
    uint256 root,
    uint256 nullifierHash,
    uint256[8] calldata proof
    ) public returns (address){
        // First make sure this person hasn't done this before
        if (nullifierHashes[nullifierHash]) revert InvalidNullifier();

        bytes memory appId_ = abi.encodePacked(appId);
        bytes memory signal_ = abi.encodePacked(signal);

        // Now verify the provided proof is valid and the user is verified by World ID
        IWorldID(worldId).verifyProof(
            root,
            groupId,
            hashToField(signal_),
            nullifierHash,
            hashToField(appId_),
            proof
        );

        // Record the user has done this, so they can't do it again (proof of uniqueness)
        nullifierHashes[nullifierHash] = true;

        (
            address implementation_, 
            uint256 chainId_, 
            address tokenContract_, 
            uint256 tokenId_, 
            uint256 salt_
        ) = abi.decode(signal, (address,uint256,address,uint256,uint256));
        return
        registry.createAccount(
            implementation_,
            chainId_,
            tokenContract_,
            tokenId_,
            salt_,
            ""
        );
    }

    function addEth(uint tokenId) external payable {
        address account = getAccount(tokenId);
        (bool success, ) = account.call{value: msg.value}("");
        require(success, "Failed to send ETH");
    }

    function mint() external payable {
        require(totalSupply < maxSupply, "Max supply reached");
        require(msg.value >= price, "Insufficient funds");
        _safeMint(msg.sender, ++totalSupply);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        address account = getAccount(tokenId);
        string[] memory uriParts = new string[](4);
        string memory balance = "0";
        string memory ethBalanceTwoDecimals = "0";

        string memory uri = string.concat(
            uriParts[0],
            Base64.encode(
                abi.encodePacked(uriParts[1], uriParts[2], uriParts[3])
            )
        );

        return uri;
    }

    function burn(uint256 tokenId) external virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        revert("");
    }
}