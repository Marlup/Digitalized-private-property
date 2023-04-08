// Import the contract artifacts and the assert module
const Contract = artifacts.require("Contract");
//const { VotingType } = require("./DataStructures.js");
const { assert } = require('chai');

// Start a test suite with the contract
contract('Contract', function(accounts) {
  // Define the contract instance and some useful constants
  const party1 = accounts[1];
  const party2 = accounts[2];
  const party3 = accounts[3];
  const party4 = accounts[4];
  const party5 = accounts[5];
  const party6 = accounts[6];
  const external = accounts[0];
  const title = "Contract Title";
  const points = "Contract Points";

  // Before each test, deploy a new instance of the contract
  beforeEach(async () => {
    const instance = await Contract.deployed();
  });
  // Test the newVotingSession function
  it('should allow external to request right cession to party2', async () => {
    const instance = await Contract.deployed();

    await instance.rightCessionRequest(party2, {from: external});
    const RightCessionRequestEvent = await instance.getPastEvents('RightCessionRequest', { fromBlock: 0, toBlock: 'latest' } );
    console.log("Number of events:", RightCessionRequestEvent.length);
    console.log("Event:", RightCessionRequestEvent[0]);
    console.log("Event:", RightCessionRequestEvent[1]);
    });
  // Test the increaseVotes function
  it('should not allow external to request right cession to party2 twice', async () => {
    const instance = await Contract.deployed();

    // request right cession (should not be possible)
    let error;
    try {
      await instance.rightCessionRequest(party1, {from: external});
    } catch (error) {
      console.log("2 2 Expected error:", error);
      assert.exists(error);
    }
  });

  // Test the repeatVote function
  it('should allow party 2 to cesate its right', async () => {
    // Take deployed Contract contract
    const sessionNumber = 0;
    const instance = await Contract.deployed();
    await instance.rightCession([external], {from: party1});

    let error;
    try {
      await instance.repeatVote(false, {from: party2});
    } catch (error) {
      console.log("2 3 Expected error:", error);
    }
    // Party 2 changes its vote to in favor
    await instance.repeatVote(true, {from: party2});
    const sessionResult = await instance.getSessionResult(sessionNumber);
    assert.equal(sessionResult, "inFavor");
  });
});
