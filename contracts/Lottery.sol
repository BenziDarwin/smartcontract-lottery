//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable {
    address payable[] public participants;
    mapping(uint256 => address) public participantWithPosition;
    uint256 public noOfParticipants = 0;
    AggregatorV3Interface priceFeed;
    uint256 entryFeeInCash;
    uint256 entryFeeInEth;
    bytes32 public keyHash;
    uint256 public fee;
    bytes32 requestId;
    uint256 public randomness;
    //uint64 public subscriptionId = 0xaae46f4106bfe1a85c68e3bf85e5fb96b7eac5c1;
    address payable public recentWinner;

    //address VRFCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    LOTTERY_STATE public lottery_state;

    constructor(
        address _priceFeed,
        address _VRFCoordinator,
        bytes32 _keyHash,
        address _linkTokenAddress,
        uint256 _fee
    ) VRFConsumerBase(_VRFCoordinator, _linkTokenAddress) {
        entryFeeInCash = 50 * 10**15;
        keyHash = _keyHash;
        fee = _fee;
        lottery_state = LOTTERY_STATE.CLOSED;
        priceFeed = AggregatorV3Interface(_priceFeed);
        setEntranceFee();
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
    function setEntranceFee() internal returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 usedPrice = uint256(price * 10**10);
        entryFeeInEth = ((entryFeeInCash * 10**18) / usedPrice);
        return entryFeeInEth;
    }

    function showRecentEntry() public view returns (address) {
        return participants[noOfParticipants - 1];
    }

    function showEntranceFee() public view returns (uint256) {
        return entryFeeInEth;
    }

    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "A lottery is still on going!"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner {
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        requestId = requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        internal
        override
    {
        require(
            lottery_state == LOTTERY_STATE.CALCULATING_WINNER,
            "State not changed successfully..."
        );
        require(_randomness > 0, "Random number is not found!");
        uint256 indexOfWinner = _randomness % participants.length;
        recentWinner = participants[indexOfWinner];
        recentWinner.transfer(address(this).balance);
        //Resetting the list
        participants = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
        randomness = _randomness;
    }
}
