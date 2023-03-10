// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "forge-std/Test.sol";

import "../contracts/MemesAuction.sol";


import {IMintableNFT} from "../contracts/interfaces/IMintableNFT.sol";

contract MemesAuctionTest is Test {
    MemesAuction mAuction;

    uint256 startBlockNumber = 1000;

    function setUp() public {

        vm.roll(startBlockNumber);

        mAuction = new MemesAuction(address(new MockJpegsNft()),address(0));
    }

    function test_getMintPrice() public {
     
        mAuction.startAuction();

        uint256 mintPrice = mAuction.getMintPrice(startBlockNumber + 1);
       
        assertEq(
             mAuction.getMintPrice(startBlockNumber + 1),
             2100000000000000,
             "unexpected mint price after 1 block"

        );

        assertEq(
             mAuction.getMintPrice(startBlockNumber + 10),
             2100000000000000,
             "unexpected mint price after 10 blocks"

        );

 
        assertEq(
             mAuction.getMintPrice(startBlockNumber + 1000),
             4199_16016797,
             "unexpected mint price after few hours"

        );  

        //after one day
        assertEq(
             mAuction.getMintPrice(startBlockNumber + 7000),
             85_71393587,
             "unexpected mint price after one day"
        );

        assertEq(
             mAuction.getMintPrice(startBlockNumber + 14000),
             21_42854957,
             "unexpected mint price after two days"
        );

        assertEq(
             mAuction.getMintPrice(startBlockNumber + 21000),
             9_52380521,
             "unexpected mint price after three days"
        );

         assertEq(
             mAuction.getMintPrice(startBlockNumber + 28000),
             5_35714150,
             "unexpected mint price after four days"
        );
 
    }
}


contract MockJpegsNft is IMintableNFT {


    function mint(address to ) external returns (uint256 tokenId)
    {
     return 0 ;
    }


    function hasMintableNft() external returns (bool){
     return true;
    }


}