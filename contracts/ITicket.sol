// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface ITicket {
    function createTickets(uint256 _ticketCount) external;
    function buy(address _buyer, uint256 _ticketId) external returns (bool);
    function getTicketOwner(uint256 _ticketId) external returns (address);
}