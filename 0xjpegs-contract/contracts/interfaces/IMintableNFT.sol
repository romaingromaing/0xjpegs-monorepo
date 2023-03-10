// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


interface IMintableNFT {

    function mint(address to ) external returns (uint256 tokenId);


    function hasMintableNft() external returns (bool);
}