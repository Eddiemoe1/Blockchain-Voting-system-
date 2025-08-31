// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Voting {
    address public admin;
    bool public votingStarted;
    bool public votingEnded;

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }


    mapping(uint => Candidate) public candidates;
    uint public candidatesCount;

    mapping(address => bool) public voters;
    mapping(address => bool) public hasVoted;

    event CandidateAdded(uint candidateId, string name);
    event VoteCast(address voter, uint candidateId);
    event VotingStarted();
    event VotingEnded();

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    constructor() {
        admin = msg.sender;

    }

    function addCandidate(string memory _name) public onlyAdmin {
        require(!votingStarted, "Cannot add candidate after voting started");
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }
    

    function startVoting() public onlyAdmin {
        require(!votingStarted, "Voting already started");
        votingStarted = true;
        emit VotingStarted();
        
    }
    

    function endVoting() public onlyAdmin {
        require(votingStarted, "Voting not started yet");
        require(!votingEnded, "Voting already ended");
        votingEnded = true;
        emit VotingEnded();
    }

    function registerVoter(address _voter) public onlyAdmin {
        require(!votingStarted, "Cannot register after voting started");
        voters[_voter] = true;
    }

    function vote(uint _candidateId) public {
        require(votingStarted && !votingEnded, "Voting is not active");
        require(voters[msg.sender], "You are not registered to vote");
        require(!hasVoted[msg.sender], "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate");

        candidates[_candidateId].voteCount++;
        hasVoted[msg.sender] = true;

        emit VoteCast(msg.sender, _candidateId);
    }

    function getWinner() public view returns (string memory winnerName, uint winnerVotes) {
        require(votingEnded, "Voting not ended yet");

        uint maxVotes = 0;
        uint winningCandidateId = 0;

        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }

        winnerName = candidates[winningCandidateId].name;
        winnerVotes = candidates[winningCandidateId].voteCount;
    }
}
