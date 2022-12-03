import Image from 'next/image'

import { SetStateAction, useState } from 'react'
import copyIcon from '../styles/copy-icon.svg'

const Home = () => {
  const [wallet, setWalletAddress] = useState("");
  const [collection, setCollectionAddress] = useState("");
  const [NFTs, setNFTs] = useState([])
  const [fetchForCollection, setFetchForCollection]=useState(false)
  const [nextToken, setNextToken] = useState("");

  const fetchNFTs = async() => {
    let nfts; 
    console.log("fetching nfts");
    const api_key = process.env.NEXT_PUBLIC_ALCHEMY_API_KEY
    const baseURL = `https://eth-goerli.g.alchemy.com/v2/${api_key}/getNFTs/`;
    var requestOptions = {
        method: 'GET'
    };
     
    if (!collection.length) {
    
      let fetchURL = `${baseURL}?owner=${wallet}`;

      if (nextToken) {
        fetchURL = `${fetchURL}&pageKey=${nextToken}`
      }
  
      nfts = await fetch(fetchURL, requestOptions).then(data => data.json());
    } else {
      console.log("fetching nfts for collection owned by address")
      let fetchURL = `${baseURL}?owner=${wallet}&contractAddresses%5B%5D=${collection}`;
      if (nextToken) {
        fetchURL = `${fetchURL}&pageKey=${nextToken}`
      }
      nfts= await fetch(fetchURL, requestOptions).then(data => data.json())
    }
  
    if (nfts) {
      console.log("nfts:", nfts)
      setNextToken(nfts.pageKey);
      setNFTs(nfts.ownedNfts)
    }
  }
  
  const fetchNFTsForCollection = async () => {
    
    if (collection.length) {
      var requestOptions = {
        method: 'GET'
      };
      const api_key = process.env.NEXT_PUBLIC_ALCHEMY_API_KEY
      const baseURL = `https://eth-goerli.g.alchemy.com/v2/${api_key}/getNFTsForCollection/`;
      let fetchURL = `${baseURL}?contractAddress=${collection}&withMetadata=${"true"}`;
      console.log(nextToken);
      
      if (nextToken) {
        fetchURL = `${fetchURL}&startToken=${nextToken}`
      }
      console.log(fetchURL);
      
      const nfts = await fetch(fetchURL, requestOptions).then(data => data.json())
      if (nfts) {
        console.log("NFTs in collection:", nfts)
        setNextToken(nfts.nextToken);
        setNFTs(nfts.nfts)
      }
    }
  }

  return (
    
    <div className="flex flex-col items-center justify-center py-8 gap-y-3">
      <div className="flex flex-col w-full justify-center items-center gap-y-2">
        <input disabled={fetchForCollection} type={"text"} placeholder="Add your wallet address" onChange={(e)=>{setWalletAddress(e.target.value)}}></input>
        <input type={"text"} placeholder="Add the collection address" onChange={(e)=>{setCollectionAddress(e.target.value)}}></input>
        <label className="text-gray-600 "><input onChange={(e)=>{setFetchForCollection(e.target.checked)}} type={"checkbox"} className="mr-2"></input>Fetch for collection</label>
        <button className={"disabled:bg-slate-500 text-white bg-blue-400 px-4 py-2 mt-3 rounded-sm w-1/5"} onClick={
           () => {
            if (fetchForCollection) {
              fetchNFTsForCollection()
            }else fetchNFTs()
          }
        }>Let's go! </button>
              <button className={"disabled:bg-slate-500 text-white bg-blue-400 px-4 py-2 mt-3 rounded-sm w-1/5"} onClick={
            () => {
              if (fetchForCollection) {
                fetchNFTsForCollection()
              }else fetchNFTs()
            }
      }>Next Page</button>
      </div>
      <div className='flex flex-wrap gap-y-12 mt-4 w-5/6 gap-x-2 justify-center'>
        {
          NFTs.length && NFTs.map(nft => {
            return (
              <NFTCard nft={nft}></NFTCard>
            )
          })
        }
      </div>
    </div>
  )
}

export const NFTCard = ({ nft }) => {

  return (
      <div key={nft.id.tokenId} className="w-1/4 flex flex-col">
          <div className="rounded-md">
              <img className="object-cover h-128 w-full rounded-t-md" src={nft.media[0].gateway} ></img>
          </div>
          <div className="flex flex-col y-gap-2 px-2 py-3 bg-slate-100 rounded-b-md h-110 ">
              <div className="">
                  <h2 className="text-xl text-gray-800">{nft.title}</h2>
                  <p className="text-gray-600 truncate">Id: {nft.id.tokenId}</p>
                  <p className="text-gray-600 truncate" >{nft.contract.address}</p>
                  <button className="flex items-center gap-x-2 mt-2 bg-blue-400 text-white px-4 py-2 rounded-sm" onClick={
                    () => {
                    navigator.clipboard.writeText(nft.contract.address);
                    }
                  }>
                      <Image src={copyIcon} alt="copy icon" width={20} height={20}></Image>
                      Copy NFT address
                  </button>
              </div>

              <div className="flex-grow mt-2">
                  <p className="text-gray-600">{nft.description}</p>
              </div>
          </div>

      </div>
  )
}

export default Home