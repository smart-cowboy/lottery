// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "./ITicket.sol";

contract Lottery {
    ITicket public ticket; // ticket address
    uint256 public ticketPrice;
    bool public isMiddleOfLottery;
    uint256 public prize;
    address lotteryCreator;
    uint256 public ticketCount;
    uint256 public ticketCountSold;

    event LotteryEnded(address winner);

    constructor (ITicket _ticket) {
        ticket = _ticket;
    }

    /** 
     * @dev start lottery function
     * @param _ticketCount ticket count to create
     * @param _ticketPrice price of ticket 
     */
    function startLottery(uint256 _ticketCount, uint256 _ticketPrice) public {
        require(!isMiddleOfLottery);

        ticket.createTickets(_ticketCount);
        ticketPrice = _ticketPrice;
        ticketCount = _ticketCount;
        uint256 ticketNumber = uint256(keccak256(abi.encodePacked(block.difficulty, block.number, "ticketNumber"))) % _ticketCount;
        ticket.buy(msg.sender, ticketNumber);
        lotteryCreator = msg.sender;
        ticketCountSold = 1;
    }

    /**
     * @dev buy ticket
     * @param _ticketCount number Of tokens to buy
     * @param _ticketIds id of ticket to buy
     */
    function buy(uint256 _ticketCount, uint256[] memory _ticketIds) public payable returns (uint256){
        uint256 change = msg.value;
        uint256 boughtCount = 0;
        require(change >= ticketPrice * _ticketCount);

        uint256 i;
        for (i = 0; i < _ticketCount; i ++) {
            if (ticket.buy(msg.sender, _ticketIds[i]) == true) {
                change -= ticketPrice;
                boughtCount ++;
                ticketCountSold ++;
            }
        }

        address payable sender = payable(msg.sender);
        sender.transfer(change);
        return boughtCount;
    }

    /**
     * @dev end lottery
     */
    function endLottery() public isLotteryCreator {
        require(ticketCount == ticketCountSold);
        uint256 ticketNumber = uint256(keccak256(abi.encodePacked(block.difficulty, block.number, "ticketNumber"))) % ticketCount;
        address payable ticketOwner = payable(ticket.getTicketOwner(ticketNumber));
        ticketOwner.transfer(prize);

        emit LotteryEnded(ticketOwner);
    }

    modifier isLotteryCreator() {
        require(lotteryCreator == msg.sender);
        _;
    }
}