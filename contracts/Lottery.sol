//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Lottery is VRFConsumerBaseV2, Ownable {
    address payable[] public participants;
    mapping(uint256 => address) public participantWithPosition;
    uint256 noOfParticipants = 0;
    AggregatorV3Interface priceFeed;
    address public Admin;
    uint256 entryFeeInCash;
    LinkTokenInterface linkToken;
    uint256 entryFeeInEth;
    // For VRFCoordinator
    address VRFCoordinator;
    VRFCoordinatorV2Interface coordinator;
    bytes32 keyHash;
    uint256[] public s_randomWords;
    uint256 public requestId;
    uint64 public subscriptionId;
    uint16 requestConfirmations = 3;
    uint32 callbackGasLimit = 100000;
    uint32 numWords = 2;
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
        address _linkTokenAddress
    ) VRFConsumerBaseV2(_VRFCoordinator) {
        VRFCoordinator = _VRFCoordinator;
        keyHash = _keyHash;
        linkToken = LinkTokenInterface(_linkTokenAddress);
        entryFeeInCash = 50 * 10**15;
        Admin = msg.sender;
        coordinator = VRFCoordinatorV2Interface(_VRFCoordinator);
        lottery_state = LOTTERY_STATE.CLOSED;
        priceFeed = AggregatorV3Interface(_priceFeed);
        createNewSubscription();
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

    function showAdminAccount() public view returns (address) {
        return Admin;
    }

    //This function sets the entrance fee, needed before being able to show the fee.
    function setEntranceFee() public returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 usedPrice = uint256(price * 10**10);
        entryFeeInEth = ((entryFeeInCash * 10**18) / usedPrice);
        return entryFeeInEth;
    }

    function createNewSubscription() private onlyAdmin {
        subscriptionId = coordinator.createSubscription();
        coordinator.addConsumer(subscriptionId, address(this));
    }

    // For VRFCoordinator
    function requestRandomWords() private onlyAdmin {
        // Will revert if subscription is not set and funded.
        requestId = coordinator.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        require(
            lottery_state == LOTTERY_STATE.CALCULATING_WINNER,
            "Lottery hasn't been concluded yet!"
        );
        require(s_randomWords[0] > 0, "Random word not found :(");
        s_randomWords = randomWords;
        uint256 indexOfWinner = randomWords[0] % participants.length;
        recentWinner = participants[indexOfWinner];
        recentWinner.transfer(address(this).balance);
        //Reseting the list
        participants = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
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
        requestRandomWords();
    }
}
