// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    IERC20 public token;
    BagelToken public bagelToken;
    MerkleAirdrop public merkleAirdrop;

    uint256 public constant AMOUNT_TO_MINT = 25 * 5 * 1e18;

    bytes32 public constant ROOT = 0xe446880466c6cb072462c5b07a7549efc0327e61e223dd550e6a2ae4c1fddd6f;

    function deployMerkleAirdrop() public returns (BagelToken, MerkleAirdrop) {
        vm.startBroadcast();
        bagelToken = new BagelToken();
        merkleAirdrop = new MerkleAirdrop(ROOT, bagelToken);

        bagelToken.mint(bagelToken.owner(), AMOUNT_TO_MINT);
        bagelToken.transfer(address(merkleAirdrop), AMOUNT_TO_MINT);

        vm.stopBroadcast();

        return (bagelToken, merkleAirdrop);
    }

    function run() public {
        (bagelToken, merkleAirdrop) = deployMerkleAirdrop();
    }
}
