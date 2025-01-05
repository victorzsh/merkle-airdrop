// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    MerkleAirdrop public merkleAirdrop;
    BagelToken public bagelToken;

    bytes32 public constant ROOT = 0xe446880466c6cb072462c5b07a7549efc0327e61e223dd550e6a2ae4c1fddd6f;
    uint256 public constant AMOUNT = 25 * 1e18;
    uint256 public constant AMOUNT_TO_MINT = 125 * 1e18;
    bytes32 proofOne = 0x0000000000000000000000000000000000000000000000000000000000000000;
    bytes32 proofTwo = 0x0000000000000000000000000000000000000000000000000000000000000000;
    bytes32 proofThree = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    bytes32[] public PROOF = [proofOne, proofTwo, proofThree];

    address public gasPayer;
    address public user;
    uint256 public userPrivKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (bagelToken, merkleAirdrop) = deployer.deployMerkleAirdrop();
        } else {
            bagelToken = new BagelToken();
            merkleAirdrop = new MerkleAirdrop(ROOT, bagelToken);

            bagelToken.mint(address(merkleAirdrop), AMOUNT_TO_MINT);
        }
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = bagelToken.balanceOf(user);
        bytes32 digest = merkleAirdrop.getMessageHash(user, AMOUNT);

        // sign a message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        // gasPayer calls claim using the signature
        vm.prank(gasPayer);
        merkleAirdrop.claim(user, AMOUNT, PROOF, v, r, s);

        uint256 endingBalance = bagelToken.balanceOf(user);
        console.log("Ending balance ", endingBalance);
        console.log("Starting balance ", startingBalance);
        assertEq(endingBalance, startingBalance + AMOUNT);
    }
}
