//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Lottery {
    address payable[] public participants;
    mapping(uint256 => address) public participantWithPosition;
    uint256 noOfParticipants = 0;
    AggregatorV3Interface priceFeed;
    address Admin;
    uint256 entryFeeInCash;
    uint256 priceEth;

    constructor(address _priceFeed) public {
        entryFeeInCash = 50 * 10**15;
        Admin = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function addParticipant() public payable {
        require(msg.value < getEntranceFee(), "Not enough eth!");
        participants.push(payable(msg.sender));
        participantWithPosition[noOfParticipants++] = msg.sender;
    }

    function getEntranceFee() public returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 usedPrice = uint256(price * 10**10);
        return ((entryFeeInCash * 10**17) / usedPrice);
    }

    function startLottery() public {}

    function endLottery() public {}
}
