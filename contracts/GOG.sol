// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/common/ERC2981.sol';

contract GOG is ERC721Enumerable, Ownable, ReentrancyGuard, ERC2981 {
  using Strings for uint256;

  string private _baseTokenURI = 'ipfs://ipfsHash/';
  string private extension = '.json';
  address public admin1 = 0x94910DC8CfEBdBD884A40AD1Bd67d6fdc49Fa2A3;
  address public admin2 = 0x4995A7787816e2898c171D1064615EE7e4c3DD22;
  address public admin3 = 0x2b98dbF6E4af55FaD3f509152a867849b358677F;
  address public admin4 = 0x4d1d39E722A26d485DE95C9BaDA1E004690E7931;
  uint256 public constant MAX_ENTRIES = 7070;
  uint256[7] public PRICES = [
    49 ether,
    54 ether,
    59 ether,
    64 ether,
    69 ether,
    74 ether,
    79 ether
  ];
  uint256 public constant LIMIT_PER_TRANSACTION = 50;
  uint256 public totalMinted;
  mapping(address => bool) public minted;
  mapping(address => bool) public whitelisted;
  uint8 public saleState = 0;

  constructor() ERC721('Ghost OG', 'GOG') {
    setDefaultRoyalty(admin4, 1000);
  }

  function mint(uint256 amount) external payable {
    require(saleState > 0, 'Sale is not started');
    require(amount > 0, 'Insufficient mint amount');
    require(amount <= LIMIT_PER_TRANSACTION, 'Exceeds max nft per tx');
    require(totalMinted + amount <= MAX_ENTRIES, 'Exceeds max nfts');
    uint256 i;
    if (saleState == 1) {
      require(amount == 1, 'You can only mint 1 in presale');
      require(whitelisted[msg.sender], 'You are not whitelisted');
      require(!minted[msg.sender], 'You already minted an nft');
      minted[msg.sender] = true;
    } else {
      uint256 price = 0;
      for (i = 1; i <= amount; ++i) {
        price += getPrice(totalMinted + i);
      }
      require(msg.value >= price, 'Insufficient fund');
    }
    for (i = 0; i < amount; ++i) {
      _safeMint(msg.sender, ++totalMinted);
    }
  }

  function getPrice(uint256 index) public view returns (uint256) {
    if (index <= 1000) {
      return PRICES[0];
    } else if (index <= 2000) {
      return PRICES[1];
    } else if (index <= 3000) {
      return PRICES[2];
    } else if (index <= 4000) {
      return PRICES[3];
    } else if (index <= 5000) {
      return PRICES[4];
    } else if (index <= 6000) {
      return PRICES[5];
    } else {
      return PRICES[6];
    }
  }

  function _baseURI() internal view override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string memory baseURI) public onlyOwner {
    _baseTokenURI = baseURI;
  }

  function startPresale() external onlyOwner {
    saleState = 1;
  }

  function startPublicSale() external onlyOwner {
    saleState = 2;
  }

  function setDefaultRoyalty(address receiver, uint96 feeNumerator)
    public
    onlyOwner
  {
    _setDefaultRoyalty(receiver, feeNumerator);
  }

  function addToWhitelist(address[] memory wallets) external onlyOwner {
    uint256 i;
    for (i = 0; i < wallets.length; ++i) {
      whitelisted[wallets[i]] = true;
    }
  }

  function setExtension(string memory newExtension) external {
    extension = newExtension;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      'ERC721Metadata: URI query for nonexistent token'
    );
    return
      string(abi.encodePacked(_baseTokenURI, tokenId.toString(), extension));
  }

  function withdraw() external onlyOwner {
    uint256 balance = address(this).balance;
    payable(admin1).transfer((balance * 275) / 1000);
    payable(admin2).transfer((balance * 300) / 1000);
    payable(admin3).transfer((balance * 275) / 1000);
    payable(admin4).transfer((balance * 150) / 1000);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721Enumerable, ERC2981)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}
