import { Provider } from "@ethersproject/abstract-provider"
import { ethers } from "ethers"


import  JpegsNftAbi from '../config/abi/jpegsNft.abi.json'
 
import MemesAuctionAbi from '../config/abi/memesAuction.abi.json'

import  contractsConfig from '../config/contracts-config.json'

export async function getMintCount(networkName:string, provider: Provider){

    let localConfig:any = contractsConfig[networkName]
    
    let jpegsContract = new ethers.Contract(localConfig['jpegsNFT'].address, JpegsNftAbi, provider)

    return await jpegsContract.mintedTokenCount()
}


export async function getTokenUriExtension(tokenId: string, networkName:string, provider: Provider){

    let localConfig:any = contractsConfig[networkName]
    
    let jpegsContract = new ethers.Contract(localConfig['jpegsNFT'].address, JpegsNftAbi, provider)

    return await jpegsContract.uriExtensions(tokenId)
}