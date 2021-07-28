// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ITicket.sol";

contract Ticket is Ownable, ITicket {
    mapping (uint256 => address) tickets; // ticketId => buyer
    uint256 public ticketCount; // total ticket Count

    constructor() Ownable() {
    }

    /**
     * @dev create ticket function
     * @param _ticketCount totalTicketCount to create
     */
    function createTickets(uint256 _ticketCount) external override onlyOwner{
        for (uint256 i = 0; i < ticketCount; i ++)
            tickets[i] = address(0);

        ticketCount = _ticketCount;
    }

    /**
     * @dev buy ticket
     * @param _buyer address of ticket buyer
     * @param _ticketId id of ticket to buy
     */
    function buy(address _buyer, uint256 _ticketId) external override onlyOwner returns (bool) {
        if (tickets[_ticketId] != address(0))
            return false;

        tickets[_ticketId] = _buyer;
        return true;
    }

    /** 
     * @dev get ticket owner
     * @param _ticketId id of ticket
     */
    function getTicketOwner(uint256 _ticketId) public view override returns (address) {
        return tickets[_ticketId];
    }
}