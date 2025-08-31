const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VotingSystem", function () {
  let Voting, voting, admin, voter1;

  beforeEach(async () => {
    [admin, voter1] = await ethers.getSigners(); // Get test accounts
    Voting = await ethers.getContractFactory("Voting");
    voting = await Voting.deploy(["Alice", "Bob"]); // Deploy with candidates
  });

  it("Should prevent double voting", async function () {
    await voting.connect(voter1).vote(0); // Vote for Alice (id: 0)
    await expect(voting.connect(voter1).vote(0)).to.be.revertedWith("Already voted");
  });

  it("Should tally votes correctly", async function () {
    await voting.connect(voter1).vote(0);
    await voting.endVoting(); // Only admin can call this
    const candidate = await voting.candidates(0);
    expect(candidate.voteCount).to.equal(1);
  });
});

