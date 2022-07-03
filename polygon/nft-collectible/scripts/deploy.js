async function main() {
    // あなたのコレクションの Base Token URI（JSON の CID）に差し替えてください
    // 注: 十分な NFT を確保するために、下記のサンプル Token URI を使用しても問題ありません。
    const baseTokenURI = "ipfs://QmTokYYbBnm9kAQC9tBFys4VTyYo7aEbyoB41jutJkka8b/";
    
    // オーナー/デプロイヤーのウォレットアドレスを取得する
    const [owner] = await hre.ethers.getSigners();
    
    // デプロイしたいコントラクトを取得
    const contractFactory = await hre.ethers.getContractFactory("NFTCollectible");
    
    // 正しいコンストラクタ引数（baseTokenURI）でコントラクトをデプロイします。
    const contract = await contractFactory.deploy(baseTokenURI);
    
    // このトランザクションがマイナーに承認（mine）されるのを待つ
    await contract.deployed();
    
    // コントラクトアドレスをターミナルに出力
    console.log("Contract deployed to:", contract.address);
    
    // 所有者の全トークンIDを取得
    let tokens = await contract.tokensOfOwner(owner.address);
    console.log("Owner has tokens: ", tokens);
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});
const { utils } = require("ethers");