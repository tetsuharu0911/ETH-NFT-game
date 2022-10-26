// run.js
const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
  const gameContract = await gameContractFactory.deploy(
    ['ZORO', 'NAMI', 'USOPP'], // キャラクターの名前
    [
      'https://i.imgur.com/TZEhCTX.png', // キャラクターの画像
      'https://i.imgur.com/WVAaMPA.png',
      'https://i.imgur.com/pCMZeiM.png',
    ],
    [100, 200, 300], // キャラクターのHP
    [100, 50, 25] // キャラクターの攻撃力
  );
  const nftGame = await gameContract.deployed();

  console.log('Contract deployed to:', nftGame.address);

  // 再代入可能なtxnを宣言
  let txn;
  // 3タイのキャラクターの中から、３番目のキャラクターをMint
  txn = await gameContract.mintCharacterNFT(2);

  // Mintingが仮想マイナーにより承認されるのを待つ
  await txn.wait();

  // NFTのURIの値を取得
  let returnedTokenUri = await gameContract.tokenURI(1);
  console.log('Token URI:', returnedTokenUri);
};
const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};
runMain();
