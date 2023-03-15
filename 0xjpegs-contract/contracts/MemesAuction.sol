// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

  
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
  
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IMintableNFT} from "./interfaces/IMintableNFT.sol";


import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
 

/*

    Auction Contract for 0xJPEGs

    A reverse dutch auction that burns 0xbtc in order to mint NFTs.

    ---------------------------------------------------------------

    0xBitcoin (0xbtc) is the decentralized mineable ERC20 token for Ethereum Mainnet. 

    Contract by @ethereumdegen

*/

contract MemesAuction is Ownable {

    uint256 constant startPrice = 21000000 * 1e8;
 
 
    address public immutable mintableNFT;
    address public immutable currencyToken;

    address public fundsRecipient;
    uint32 public burnPct = 5000; //50 percent

    uint256 public lastEpochStartBlockNumber;
    bool public auctionStarted;

    event Buyout(address buyer, uint256 tokenId, uint256 price); 
    event AuctionStarted(); 
    event AuctionPaused(); 
    event SetFundsRecipient(address recipient);
    event SetBurnPercent(uint32 pct);

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

        _transferFundsOut( mintPrice );

        
 
        uint256 tokenId = IMintableNFT(mintableNFT).mint(recipient);

 
        emit Buyout(recipient, tokenId, mintPrice);


        if( IMintableNFT(mintableNFT).hasMintableNft() ) {
            _startAuction();
        }else{
            _pauseAuction();
        }
       

    }

    function _transferFundsOut(uint256 amount) internal {

        uint256 amountToBurn = Math.mulDiv(
            amount,
            burnPct ,
            10000
        );       

        IERC20(currencyToken).transfer(address(0), amountToBurn);

        uint256 amountRemaining = amount- amountToBurn;

        IERC20(currencyToken).transfer(fundsRecipient, amountRemaining); 

    }




    function setFundsRecipient(address _recipient) public onlyOwner {
        fundsRecipient = _recipient;

        emit SetFundsRecipient(_recipient);
    }

     function setBurnPct(uint32 _pct) public onlyOwner {
        require(_pct >= 0 && _pct <= 10000, "Invalid percent");

        burnPct = _pct;
        
        emit SetBurnPercent(_pct);
    }

    function getMintPrice(uint256 blockNumber) public view returns (uint256) {

        if(!auctionStarted) return startPrice;

        uint256 blockNumbersDelta = blockNumber - lastEpochStartBlockNumber;

        return Math.ceilDiv(startPrice , ( Math.ceilDiv(  (blockNumbersDelta**2 + 100) , 200 ) )); 

    }
    

       
    function receiveApproval(address from, uint256 amount, address token, bytes memory) public returns (bool success) {

        require( msg.sender == currencyToken , "Invalid receiveApproval origin");
        require( token == currencyToken , "Invalid token type received");
        
        _buyout(from,amount,from); 

        return true;

     }

}


 