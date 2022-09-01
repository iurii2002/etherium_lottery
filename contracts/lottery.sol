// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";


contract Lottery is VRFConsumerBase, Ownable {
    address payable[] public players;
    uint256 public usdEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    // 0
    // 1
    // 2

    LOTTERY_STATE public lottery_state;

    constructor(address _priceFeed, address _vrfCoordinator, address _link) public VRFConsumerBase(_vrfCoordinator,_link) {
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeed);
        usdEntryFee = 50 * (10**18);


        
        lottery_state = LOTTERY_STATE.CLOSED;
    }


    

    function enter() public payable {
        // $50 minimum
        require(lottery_state == LOTTERY_STATE.OPEN);
        require(msg.value >= getEntranceFee(), "Not enough ETH!");
        players.push(payable(msg.sender));
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 ethPrice = getETHPrice();
        uint256 costToEnter = (usdEntryFee * (10**18)) / ethPrice; //extra 10*18 to cancel out 18 decimals of eth price
        return costToEnter;
    }

    function getETHPrice() public view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        return uint256(price) * (10**10); // has originally 8 decimals, now will have 18
    }

    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Can start new lottery yet"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner {
        // uint256(
        //     keccak256(
        //         abi.encodePacked(
        //             nonce, 
        //             msg.sender, 
        //             block.difficulty, 
        //             block.timestamp
        //         )
        //     )
        // ) % players.length;

        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;

    }
}


06:35:13