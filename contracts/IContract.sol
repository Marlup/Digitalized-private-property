// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./DataStructures.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
abstract contract IContract is DataStructures {
    // Identifiers
    address private factory;
    uint private contId;
    bytes private contractCode;
    // Descriptors
    bytes private title;
    bytes private points;
    // Dates
    uint private openDate;
    uint private closeDate;
    // Voting states
    VotingType private votingType;
    uint private nVotesDone;
    uint private nVotesInFavor;
    uint private votingOpenDate;
    uint private votingCloseDate;
    uint private sessionNumber;
    // Party states
    uint public nParties;
    // Voted mapping
    mapping(address => bool) private isParty;
    // session to party to hasVoted
    mapping(uint => mapping(address => bool)) private partyVoted;
    // ++ Setters ++
    function openVoting(address _party, VotingType _type) external virtual;
    function increaseVotes(address _party, bool _inFavor) external virtual;
    function _tryCloseVoting() external virtual returns (bool);
    function _checkVotingTargetOk() external virtual view returns (bool);
    // Contract getters
    function getFactory() external virtual view returns(address);
    function getTitle() external virtual view returns(bytes memory);
    function getPoints() external virtual view returns(bytes memory);
    function getOpenDate() external virtual view returns(uint);
    function getCloseDate() external virtual view returns(uint);
    function getVotes() external virtual view returns(uint, uint);
    function getNParties() external virtual view returns(uint);
    // Party getters
    function getPartyAllowed(address _party) external virtual view returns(bool);
    function getPartyVoted(address _party) external virtual view returns(bool);
    // Voting getters
    function getVotingOpenDate() external virtual view returns(uint);
    function transferRighToParty(address _to) external virtual;
    function renounceRight() external virtual;
}
