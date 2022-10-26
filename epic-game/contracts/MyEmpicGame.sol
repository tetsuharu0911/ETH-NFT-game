// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// NFT発行のコントラクトERC721.solをインポート
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// OpenZeppelinが提供するヘルパー機能のインポート
import  "@openzeppelin/contracts/utils/Counters.sol";
import  "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";
import "hardhat/console.sol";

// NFT発行のコントラクト(ERC721を継承)
contract MyEpicGame is ERC721 {
    // キャラクターのデータを格納する CharacterAttributes 型の 構造体（`struct`）を作成しています。
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }
    // tokenIdsを管理するライブラリ
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // キャラクターのデフォルトデータを保持するための配列 defaultCharacters を作成します。それぞれの配列は、CharacterAttributes 型です。
    CharacterAttributes[] defaultCharacters;
    
    // NFTのtokenIdとCharacterAttributesを紐づけるmapping
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // ユーザーのアドレスとNFTのtokenIdを紐づけるmapping
    mapping(address => uint256) public nftHolders;

    constructor(
        // プレイヤーが新しく NFT キャラクターを Mint する際に、キャラクターを初期化するために渡されるデータを設定しています。これらの値は フロントエンド（js ファイル）から渡されます。
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg
    )
    // 作成するNFTの名前とそのシンボルをERC721規格にセット
    ERC721("OnePiece", "ONEPIECE")
    {
        // ゲームで扱う全てのキャラクターをループ処理で呼び出し、それぞれのキャラクターに付与されるデフォルト値をコントラクトに保存します。
        // 後でNFTを作成する際に使用します。
        for(uint i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHp[i],
                maxHp: characterHp[i],
                attackDamage: characterAttackDmg[i] 
            }));
            CharacterAttributes memory character = defaultCharacters[i];
            // hardhat の console.log() では、任意の順番で最大4つのパラメータを指定できます。
	        // 使用できるパラメータの種類: uint, string, bool, address
            console.log("Done initializing %s w/ HP %s, img %s", character.name, character.hp, character.imageURI);
        }
    _tokenIds.increment();
    }

    // ユーザーはmintCharacterNFT関数を呼び出してMintする
    function mintCharacterNFT(uint _characterIndex) external {
        // 現在のtokenIdを取得
        uint256 newItemId = _tokenIds.current();
        // NFTをユーザーにMint
        _safeMint(msg.sender, newItemId);

        // tokenIdとCharacterAttributesの紐づけ
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log("Minted NFR w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

        // NFTの所有者を確認
        nftHolders[msg.sender] = newItemId;

        // 次に使用するためにtokenIdをインクリメント
        _tokenIds.increment();
    }

    // nftHolderAttributesを更新して、tokenURIを添付する関数
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];
        // charAttributesのデータ編集してJSONの構造に合わせた変数に格納していきます。
        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

        string memory json = Base64.encode(
            // abi.encodePacked で文字列を結合します。
            // OpenSeaが採用するJSONデータをフォーマットしています。
            abi.encodePacked(
            '{"name": "',
            charAttributes.name,
            ' -- NFT #: ',
            Strings.toString(_tokenId),
            '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
            charAttributes.imageURI,
            '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
            strAttackDamage,'} ]}'
            )
        );
        // 文字列 data:application/json;base64, と json の中身を結合して、tokenURI を作成しています。
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }
}