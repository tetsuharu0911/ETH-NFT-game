// deploy.js
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

  // ローカルのブロックチェーンにデプロイされるまで待つ。
  const nftGame = await gameContract.deployed();
  console.log('Contract deployed to:', nftGame.address);

  let txn;
  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();
  console.log('Minted NFT #1');

  txn = await gameContract.mintCharacterNFT(1);
  await txn.wait();
  console.log('Minted NFT #2');

  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();
  console.log('Minted NFT #3');

  console.log('Done deploying and minting!');
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
