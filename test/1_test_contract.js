const Contract = artifacts.require("Contract");
const { VotingType } = require("./DataStructures.js");

contract("Contract", accounts => {
  let contractInstance;
  const creator = accounts[0];
  const parties = [accounts[1], accounts[2], accounts[3]];

  before(async () => {
    contractInstance = await Contract.new(
      0,
      "Title",
      "Points",
      parties,
      VotingType.Majority
    );
  });

  it("should allow parties to vote", async () => {
    await contractInstance.increaseVotes(parties[0], true);
    await contractInstance.increaseVotes(parties[1], true);
    await contractInstance.increaseVotes(parties[2], false);

    const [nVotesDone, nVotesInFavor] = await contractInstance.getVotes();
    assert.equal(nVotesDone, 3);
    assert.equal(nVotesInFavor, 2);
  });

  it("should not allow a party to vote twice", async () => {
    try {
      await contractInstance.increaseVotes(parties[0], true);
      assert.fail("The transaction should have thrown an error");
    } catch (error) {
      assert(error.message.includes("Party has voted"));
    }
  });

  it("should not allow parties to vote before voting opens", async () => {
    const creator = accounts[0];
    const newParty = accounts[4];
    try {
      await contractInstance.increaseVotes(newParty, true, { from: creator });
      assert.fail("The transaction should have thrown an error");
    } catch (error) {
      assert(error.message.includes("Session is not active."));
    }
  });

  it("should close the voting session when the majority has voted in favor", async () => {
    await contractInstance.increaseVotes(parties[0], true);
    await contractInstance.increaseVotes(parties[1], true);

    const votingCloseDate = await contractInstance.getVotingCloseDate();
    assert(votingCloseDate > 0);
  });

  it("should not allow parties to transfer rights during a voting session", async () => {
    const newParty = accounts[4];
    try {
      await contractInstance.requestTransfer(parties[0], { from: newParty });
      await contractInstance.transferRight(newParty, { from: parties[0] });
      assert.fail("The transaction should have thrown an error");
    } catch (error) {
      assert(error.message.includes("Voting session in progress"));
    }
  });
});
