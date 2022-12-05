Create a solidity nft smart contract that queries the latest round data from https://etherscan.io/address/0xb49f677943bc038e9857d61e7d053caa2c1734c1#readContract#F10, and if the answer int256 value is above 100000000, then change the dynamic metadata of the nft to eu.jpg, else change the metadata to us.jpg using a chainlink cron job to check the price every 24 hours with this code: https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/factories/CronUpkeepFactory.sol

pragma solidity ^0.5.16;

import "./ERC721.sol";
import "./ERC721Metadata.sol";
import "./CronUpkeepFactory.sol";

contract NFT is ERC721, ERC721Metadata {
    constructor() public ERC721("NFT", "NFT") {
        _mint(msg.sender, 0, "https://example.com/eu.jpg");
        _mint(msg.sender, 1, "https://example.com/us.jpg");
    }
    
    // Chainlink Oracle address
    address private oracle = 0xb49f677943bc038e9857d61e7d053caa2c1734c1;

    // Create a new CronUpkeepFactory for updating the metadata
    CronUpkeepFactory private cronFactory;

    // Callback to set the NFT metadata based on the response from the Chainlink oracle
    function callback(uint256 _answer) public {
        if (_answer > 100000000) {
            _setTokenURI(0, "https://example.com/eu.jpg");
        } else {
            _setTokenURI(1, "https://example.com/us.jpg");
        }
    }

    // Constructor to set up the cron job to query the oracle every 24 hours
    constructor(address _link) public {
        // Create a new CronUpkeepFactory with the Chainlink oracle address
        cronFactory = new CronUpkeepFactory(_link);
        // Create a new cron job and set the callback function
        cronFactory.createJob(oracle, this.callback, 24 hours);
    }
}
