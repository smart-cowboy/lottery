const Ticket = artifacts.require("Ticket");
const Lottery = artifacts.require("Lottery");
const { expectRevert } = require("@openzeppelin/test-helpers");

const { toWei, toBN } = web3.utils;

contract("Lottery", ([owner, creator, alice]) => {
    before(async () => {
        this.ticket = await Ticket.new({ from: owner });
        this.lottery = await Lottery.new(this.ticket.address, { from: owner});
        this.ticket.transferOwnership(this.lottery.address);
    });

    describe("startLottery", () => {
        it("success to start lottery", async () => {
            const ticketCount = 4;
            const creatorTicket = toBN('2');
            const ticketPrice = toWei('0.1');
            await this.lottery.startLottery(ticketCount, ticketPrice, { from: creator });
            const res = await this.lottery.buy(1, [creatorTicket], { from: creator, value: ticketPrice });
            
            console.log(res.toString());
            const ownership = await this.ticket.getTicketOwner(creatorTicket);
            assert.equal(ownership, creator);
        });

        it("fail if in the middle of lottery", async () => {
            const ticketCount = 4;
            const ticketPrice = toWei('0.1');
            await expectRevert.unspecified(
                this.lottery.startLottery(ticketCount, ticketPrice, { from: creator })
            );
        });
    });

    describe("buy", () => {
        it("success to buy", async () => {
            const cost = toWei("0.2");
            const aliceTickets = [toBN(0), toBN(1)];
            await this.lottery.buy(2, aliceTickets, { from: alice, value: cost });
            const ownershipTicket1 = await this.ticket.getTicketOwner(aliceTickets[1]);
            assert.equal(ownershipTicket1, alice);
        });

        it("fail if cost is insufficient", async () => {
            const cost = toWei("0.1");
            const aliceTickets = [toBN(0), toBN(1)];
            await expectRevert.unspecified(
                this.lottery.buy(2, aliceTickets, { from: alice, value: cost })
            );
        });
    });

    describe("endLottery", () => {
        it("fail if whole tickets are not sold", async () => {
            await expectRevert.unspecified(
                this.lottery.endLottery({ from: creator })
            );
        });

        it("success to buy left ones", async () => {
            const cost = toWei("0.1");
            const aliceTickets = [toBN(3)];
            await this.lottery.buy(1, aliceTickets, { from: alice, value: cost });
        });

        it("success end lottery", async () => {
            await this.lottery.endLottery({ from: creator });
        });
    });
})