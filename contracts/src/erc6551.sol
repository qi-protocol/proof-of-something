// SPDX-License-Identifier: GPL-3.0
pragma solidity^0.8.19;

contract erc6551 {
    constructor() payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC1271.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";

import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

import "@6551/interfaces/IERC6551Account.sol";
import "@6551/interfaces/IERC6551Executable.sol";

contract ERC6551Account is IERC165, IERC1271, IERC6551Account, IERC6551Executable {
    using ECDSA for bytes32;

    uint256 public state; // this is nonce

    receive() external payable {}

    //function internal

    function execute(
        address to,
        uint256 value,
        bytes calldata data,
        uint256 operation
    ) external payable returns (bytes memory result) {
        /**
          * execution flow should be
          * call target contract << call 4337 contracts << call 6551 contract << EntryPoint
          * this means that the owner of the 4337 is the 6551
          * 4337 ecdsa recovery >> 6551
          * that means 6551 needs to encode and sign it's input data;
          * maybe paid for by biconmoy, maybe not idc
          *
          * data order: blah, blah, slot, blah, calldata
          * calldata: signature, transaction (userop)
          * needs state to be in the signature to protect against sybil attacks

         */
        // need to make sure the size of the calldata
        // calldata = (size + 32) - (4 + 32*4) => size + 32 >= 229
        // first 132 are garbage
        // next 32 is data length
        // next 32 + 65 is signature
        // if next 32 is not 0, 32 + ? is userop
        // means size must be at least 132 + 97
        uint256 size = msg.data.length;
        require(size >= 229, "Invalid data length");
        bytes memory signature_ = msg.data[197:229];
        //bytes memory userop = msg.data[229:size];

        bytes32 hash_ = keccak256(state, msg.data[229:size])
        bytes memory signature_ = msg.data[133:197];
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash_.toEthSignedMessageHash(), signature_);
        if (error != ECDSA.RecoverError.NoError) {
            revert BadSignature();
        }

        if(recovered != account_) {
            revert InvalidSignature(account_, recovered);
        }


        revert _isValidSigner(recovered, "Invalid signer");
        require(operation == 0, "Only call operations are supported");

        ++state;

        bool success;
        (success, result) = to.call{value: value}(msg.data[229:size]);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function isValidSigner(address signer, bytes calldata data) external view returns (bytes4) {
        if (_isValidSigner(signer)) { // see already have the bytes to have a sig
            return IERC6551Account.isValidSigner.selector;
        }
        uint256 size = msg.data.length;
        require(size >= 64, "Invalid data length");
        bytes memory signature_ = msg.data[647:229];
        //bytes memory userop = msg.data[229:size];

        bytes32 hash_ = keccak256(state, msg.data[229:size])
        bytes memory signature_ = msg.data[133:197];
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash_.toEthSignedMessageHash(), signature_);
        if (error != ECDSA.RecoverError.NoError) {
            revert BadSignature();
        }

        if(recovered != account_) {
            revert InvalidSignature(account_, recovered);
        }

        return bytes4(0);
    }

    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        returns (bytes4 magicValue)
    {
        bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return (interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC6551Account).interfaceId ||
            interfaceId == type(IERC6551Executable).interfaceId);
    }

    function token()
        public
        view
        returns (
            uint256,
            address,
            uint256
        )
    {
        bytes memory footer = new bytes(0x60);

        assembly {
            extcodecopy(address(), add(footer, 0x20), 0x4d, 0x60)
        }

        return abi.decode(footer, (uint256, address, uint256));
    }

    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function _isValidSigner(address signer) internal view returns (bool) {
        /**
          * execution flow should be
          * call target contract << call 4337 contracts << call 6551 contract << EntryPoint
          * this means that the owner of the 4337 is the 6551
          * 4337 ecdsa recovery >> 6551
          * that means 6551 needs to encode and sign it's input data;
          * maybe paid for by biconmoy, maybe not idc
          *
          * data order: blah, blah, slot, blah, calldata
          * needs state to be in the signature to protect against sybil attacks

         */
        return signer == owner();
    }
}