// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

  
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
  
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IMintableNFT} from "./interfaces/IMintableNFT.sol";


import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
 

/*

    Memes Auction for 0xJPEGs

    A reverse dutch auction that burns 0xbtc in order to mint NFTs.

*/

contract MemesAuction is Ownable {

    uint256 constant startPrice = 21000000 * 1e8;
 
 
    address public immutable mintableNFT;
    address public immutable currencyToken;

    uint256 public lastEpochStartBlockNumber;
    bool public auctionStarted;

    event Buyout(address buyer, uint256 tokenId, uint256 price); 
    event AuctionStarted(); 
    event AuctionPaused(); 

    constructor(address _mintableNFT, address _currencyToken) Ownable() {

        mintableNFT = _mintableNFT;
        currencyToken = _currencyToken;

    }

    function startAuction() public onlyOwner {

        _startAuction();

    }


    function _startAuction() internal {

        require( IMintableNFT(mintableNFT).hasMintableNft(), "There is no mintable nft available." );

        auctionStarted = true;
        lastEpochStartBlockNumber = block.number;

        emit AuctionStarted();

    }


    function pauseAuction() public onlyOwner {
        _pauseAuction();
    }

    function _pauseAuction() internal {

        auctionStarted = false; 

        emit AuctionPaused();  
    }

    function buyout(uint256 amount, address recipient) public {  
       
        _buyout(msg.sender,amount,recipient);
        
    }   

 

    function _buyout(address buyer, uint256 amount, address recipient) internal {
       
       
        uint256 blockNumber = block.number;
        uint256 mintPrice = getMintPrice(blockNumber);

        require(amount>= mintPrice,"Insufficient amount.");

       
        require(auctionStarted, "Auction is not started.");
        auctionStarted = false;  

 

        IERC20(currencyToken).transferFrom(buyer, address(this), mintPrice);
   
        
        //mint the nft 
        uint256 tokenId = IMintableNFT(mintableNFT).mint(recipient);

          //emit event 
        emit Buyout(recipient, tokenId, mintPrice);


        if( IMintableNFT(mintableNFT).hasMintableNft() ) {
            _startAuction();
        }else{
            _pauseAuction();
        }
       

    }

 

    function getMintPrice(uint256 blockNumber) public view returns (uint256) {

        if(!auctionStarted) return startPrice;

        uint256 blockNumbersDelta = blockNumber - lastEpochStartBlockNumber;

        return Math.ceilDiv(startPrice , ( Math.ceilDiv(  (blockNumbersDelta**2 + 100) , 200 ) )); 

    }
    

       
    function receiveApproval(address from, uint256 amount, address token, bytes memory data) public returns (bool success) {
        
        require( token == currencyToken , "Invalid token type received");
        
        _buyout(from,amount,from); 

        return true;

     }

}


 