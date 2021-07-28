const Ticket = artifacts.require("Ticket");
const Lottery = artifacts.require("Lottery");

module.exports = async function (deployer) {
  await deployer.deploy(Ticket);
  const ticketInstance = await Ticket.deployed();
  deployer.deploy(Lottery, ticketInstance.address);
};
