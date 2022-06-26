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
    uint256 entryFeeInEth;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;

    constructor(address _priceFeed) public {
        entryFeeInCash = 50 * 10**15;
        Admin = msg.sender;
        lottery_state = LOTTERY_STATE.CLOSED;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    modifier participantCheck() {
        require(
            lottery_state == LOTTERY_STATE.OPEN,
            "The lottery hasn't started yet!"
        );
        require(msg.value >= setEntranceFee(), "Not enough eth!");
        _;
    }

    function addParticipant() public payable participantCheck {
        participants.push(payable(msg.sender));
        participantWithPosition[noOfParticipants++] = msg.sender;
    }

    //This function sets the entrance fee, needed before being able to show the fee.
    function setEntranceFee() public returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 usedPrice = uint256(price * 10**10);
        entryFeeInEth = ((entryFeeInCash * 10**18) / usedPrice);
        return entryFeeInEth;
    }

    function showEntranceFee() public view returns (uint256) {
        return entryFeeInEth;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == Admin,
            "Only the admin can start/stop the lottery!"
        );
        _;
    }

    function startLottery() public onlyAdmin {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "A lottery is still on going!"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyAdmin {
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
    }
}
