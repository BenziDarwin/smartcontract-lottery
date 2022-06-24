//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Lottery {
    address payable[] public participants;
    mapping(index => address) public participantWithPosition;
    uint256 noOfParticipants = 0;
    AggregatorV3Interface priceFeed;
    address Admin;
    uint256 entryFeeInCash;
    uint256 priceFeedEth;

    constructor(address _priceFeed) public {
        entryFeeInCash = 50;
        Admin = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function addParticipant() public payable {
        require(msg.value < getEntranceFee, "Not enough eth!");
        participants.push(msg.sender);
        participantWithPosition[noOfParticipants++] = msg.sender;
    }

    function getEntranceFee(uint256 _value) public returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        priceFeedEth = answer * (10**10);
        return ((priceFeedEth * (entryFeeInCash * (10**15))) / 10**18);
    }

    function startLottery() public {}

    function endLottery() public {}
}
