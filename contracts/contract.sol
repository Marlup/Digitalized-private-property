// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./DataStructures.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Contract is DataStructures {
    // Contract states
    address private factory;
    uint private immutable contId;
    bytes private title;
    bytes private points;
    uint private immutable openDate;
    uint private closeDate;
    VotingType votingType;
    uint private sessionNumber;
    uint nVotesDone;
    uint nVotesInFavor;
    uint votingOpenDate;
    uint votingCloseDate;
    uint public nParties;
    // Voted mapping
    mapping(address => bool) isParty;
    mapping(address => bool) partyVoted;
    // Transfer permission: solicitant => party => permission
    mapping(address => mapping(address => bool)) permission;
    //mapping(uint => Party) parties;
    modifier onSession() {
        require(votingType != VotingType.StandBy, "Session is not active.");
        _;
    }
    modifier isAllowed(address _party) {
        require(isParty[_party], "Party is not allowed");
        _;
    }
    modifier hasNotVoted(address _party) {
        require(!partyVoted[_party], "Party has voted");
        _;
    }
    modifier sessionComplete() {
        require(nParties == nVotesDone, "At least one party has not voted");
        _;
    }

    constructor (uint _id, bytes memory _title, bytes memory _points, address[] memory _parties, VotingType _votingType) {
        // Contract section
        uint timestamp = block.timestamp;
        factory = msg.sender;
        contId = _id;
        title = _title;
        points = _points;
        // Parties section
        for (uint i = 0; i < _parties.length; i++) {
            isParty[_parties[i]] = true;
        }
        nParties = _parties.length;
        openDate = timestamp;
        // Voting session section
        votingType = VotingType.StandBy;
        if (_votingType != VotingType.StandBy) {
            votingType = _votingType;
            votingOpenDate = timestamp;
        }
    }
    // ++ Setters ++
    function openVoting(address _party, VotingType _type) external isAllowed(_party) hasNotVoted(_party) {
        require(_type == VotingType.StandBy, "Voting type cannot be in stand by");
        votingType = _type;
        votingOpenDate = block.timestamp;
    }
    function increaseVotes(address _party, bool _inFavor) external isAllowed(_party) hasNotVoted(_party) returns(bool) {
        if (_inFavor) {
            nVotesInFavor += 1;
        }
        nVotesDone += 1;
        partyVoted[_party] = true;
        _tryCloseVoting();
        return true;
    }
    function _tryCloseVoting() private sessionComplete() returns (bool) {
        if (_checkVotingTargetOk()) {
            closeDate = block.timestamp;
            return true;
        }
        return false;
    }
    function _checkVotingTargetOk() private view returns (bool) {
        if (votingType == VotingType.All) {
            return nVotesDone == nVotesInFavor;
        } else if (votingType == VotingType.Majority) {
            uint voteThreshold = nVotesDone / 2 + 1;//_total % 2;
            return nVotesInFavor > voteThreshold;
        }
        return false;
    }
    // Contract getters
    function getFactory() external view returns(address) {
        return factory;
    }
    function getTitle() external view returns(bytes memory) {
        return title;
    }
    function getPoints() external view returns(bytes memory) {
        return points;
    }
    function getOpenDate() external view returns(uint) {
        return openDate;
    }
    function getCloseDate() external view returns(uint) {
        return closeDate;
    }
    function getVotes() external view returns(uint, uint) {
        return (nVotesDone, nVotesInFavor);
    }
    function getNParties() external view returns(uint) {
        return nParties;
    }
    // Party getters
    function getPartyAllowed(address _party) external view returns(bool) {
        return isParty[_party];
    }
    function getPartyVoted(address _party) external view returns(bool) {
        return partyVoted[_party];
    }
    // Voting getters
    function getVotingOpenDate() external view returns(uint) {
        return votingOpenDate;
    }
    function getVotingCloseDate() external view returns(uint) {
        return votingCloseDate;
    }
    // Solicitate transfer permission
    function requestTransfer(address _from) external {
        permission[msg.sender][_from] = true;
    }
    // Transfer party right to third
    function transferRight(address _to) external isAllowed(msg.sender) {
        require(votingType == VotingType.StandBy, "Voting session in progress");
        require(permission[_to][msg.sender], "Solicitant not found");
        require(!isParty[_to], "Solicitant is already a party");
        permission[_to][msg.sender] = false;
        isParty[_to] = true;
        isParty[msg.sender] = false;
        if (partyVoted[msg.sender])
            partyVoted[msg.sender] = false;
    }
    // Renounce party
    function renounceRight() external isAllowed(msg.sender) {
        require(votingType == VotingType.StandBy, "Voting session in progress");
        isParty[msg.sender] = false;
        if (partyVoted[msg.sender])
            partyVoted[msg.sender] = false;
        nParties -= 1;
    }
}
