// Import the contract artifacts and the assert module
const Contract = artifacts.require("Contract");
//const { VotingType } = require("./DataStructures.js");
const { assert } = require('chai');

// Start a test suite with the contract
contract('Contract', function(accounts) {
  // Define the contract instance and some useful constants
  const owner = accounts[0];
  const party1 = accounts[1];
  const party2 = accounts[2];
  const party3 = accounts[3];
  const title = "Contract Title";
  const detail = "Contract Detail";

  // Before each test, deploy a new instance of the contract
  beforeEach(async () => {
    const instance = await Contract.deployed();
    const nParties = await instance.getNParties.call()
    const returnTitle = await instance.getTitle.call()
    const returnDetail = await instance.getDetail.call()

    assert.equal(nParties, 2);
    assert.equal(web3.utils.toUtf8(returnTitle), title);
    assert.equal(web3.utils.toUtf8(returnDetail), detail);
  });

  // Test the newVotingSession function
  it('should allow owner to open a new voting session', async () => {
    const instance = await Contract.deployed();

    await instance.newVotingSession(1, {from: party1});

    const votingSession = await instance.getVotingSessionData.call(0);
    assert.equal(votingSession.nVotesDone, 0);
    assert.equal(votingSession.nVotesInFavor, 0);
    assert.equal(votingSession.closeDate, 0);
    assert.equal(votingSession.inProgress, true);
  });

  // Test the increaseVotes function
  it('should allow parties to vote and close the voting session', async () => {
    const sessionNumber = 0;
    // Take deployed Contract contract
    const instance = await Contract.deployed();
    // Open a new voting session
    //await instance.newVotingSession(1, {from: party1});
    // Party 1 votes in favor
    await instance.increaseVotes(true, {from: party2});
    // Party 2 votes against
    await instance.increaseVotes(false, {from: party1});
    // Try to close the session (should not be possible yet)
    let error;
    try {
      await instance.tryCloseVoting({from: party1});
    } catch (error) {
      console.log("Expected error:", error);
    }
    //assert.exists(error);
    // Party 2 changes its vote to in favor
    await instance.repeatVote(true, {from: party1});
    // Try to close the session again (should be possible now)
    //await instance.tryCloseVoting({from: party1});
    const session = await instance.getVotingSessionData.call(sessionNumber)
    assert.equal(session.closeDate > 0, true);
    assert.equal(session.inProgress, false);
  });

  // Test the repeatVote function
  it('should allow parties to change their votes', async () => {
    // Take deployed Contract contract
    const sessionNumber = 0;
    const instance = await Contract.deployed();
    // Open a new voting session
    await instance.newVotingSession(1, {from: party1});
    // Party 1 votes in favor
    await instance.increaseVotes(true, {from: party1});
    // Party 2 votes against
    await instance.increaseVotes(false, {from: party2});
    // Party 2 tries to change its vote to against (should not be possible)
    let error;
    try {
      await instance.repeatVote(false, {from: party2});
    } catch (error) {
      console.log("Expected error:", error);
    }
    // Party 2 changes its vote to in favor
    await instance.repeatVote(true, {from: party2});
    const sessionResult = await instance.getSessionResult(sessionNumber);
    assert.equal(sessionResult, "inFavor");
  });
});
