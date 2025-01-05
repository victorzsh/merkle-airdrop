// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract Interact is Script {
    error ClaimAirdrop__InvalidSignatureLength();

    address CLAIMING_ADDRESS = 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 PRROF_ONE = 0x0000000000000000000000000000000000000000000000000000000000000000;
    bytes32 PRROF_TWO = 0x0000000000000000000000000000000000000000000000000000000000000000;
    bytes32 PRROF_THREE = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32[] proof = [PRROF_ONE, PRROF_TWO, PRROF_THREE];
    bytes private SIGNATURE =
        hex"fbd2270e6f23fb5fe9248480c0f4be8a4e9bd77c3ad0b1333cc60b5debc511602a2a06c24085d8d7c038bad84edc53664c8ce0346caeaa3570afec0e61144dc11c";

    function claimAirdrop(address merkleAirdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(merkleAirdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);

        vm.stopBroadcast();
    }

    function splitSignature(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (signature.length != 65) {
            revert ClaimAirdrop__InvalidSignatureLength();
        }
        assembly {
            v := byte(0, mload(add(signature, 0)))
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
        }
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}
