// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NFTCollectible is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    // NFTの供給量
    uint public constant MAX_SUPPLY = 30;
    // NFTの価格
    uint public constant PRICE = 0.01 ether;
    // 1取引当たりの最大mint数
    uint public constant MAX_PER_MINT = 3;

    // JSONファイル（メタデータ）が格納されているフォルダの IPFS URL
    string public baseTokenURI;

    // ERC721()にNFTコレクションの名前とシンボルを渡す
    constructor(string memory baseURI) ERC721("NFT Collectible", "NFTC") {
        // メタデータが存在する場所のbase token URIを設定
        setBaseURI(baseURI);
    }

    function reserveNFTs() public onlyOwner {
        // これまでにmintされたNFTの総数を確認
        uint totalMinted = _tokenIds.current();
        require(totalMinted.add(10) < MAX_SUPPLY, "Not enough NFTs");
        for (uint i = 0; i < 10; i++) {
            _mintSingleNFT();
        }
    }

    // 空の関数をオーバーライドして、base token URIを返す
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    // メタデータが存在する場所のbase token URIを設定
    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    // ユーザーがコレクションからNFTを購入してMintしたいときに使う
    function mintNFTs(uint _count) public payable {
        uint totalMinted = _tokenIds.current();
        // ユーザーがmintを希望するNFTの数がコレクションに残っているか
        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs!");
        // ユーザーが0より多く、トランザクションごとに許可されるNFTの最大数（MAX_PER_MINT）以下のMint wo実行しようとしているか
        require(_count > 0 && _count <= MAX_PER_MINT, "Cannot mint specified number og NFTs.");
        // ユーザーはNFTをMintするのに十分なETHを送金しているか
        require(msg.value >= PRICE.mul(_count), "Not enough ether to purchase NFTs.");
        // 全てのrequire()が終わったら、_countの数だけユーザーにmintする
        for (uint i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }

    function _mintSingleNFT() private {
        // まだmintされていないNFTのIDを取得、初めて呼び出されたときは、0になり、tokenIDは0番になる
        uint newTokenID = _tokenIds.current();
        // openzepplinですでに定義されている、この関数を利用することで、ユーザーのアドレスにNFT IDを割り当てる
        _safeMint(msg.sender, newTokenID);
        // tokenIDのカウンターを+1する
        _tokenIds.increment();
    }

    function tokensOfOwner(address _owner) external view returns (uint[] memory) {
        // balanceOf()で特定の所有者がいくつトークンを持っているかを参照する
        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);
        for (uint i = 0; i < tokenCount; i++) {
            // 所有者が持つ全てのtokenIdを参照
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}