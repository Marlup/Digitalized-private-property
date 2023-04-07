// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

struct VotingSession {
    VotingType votingType;
    uint openDate;
    uint closeDate;
    uint nVotesDone;
    uint nVotesInFavor;
    bool inProgress;
}
// Struct for party
struct Party {
    bool isParty;
    bool wasParty;
    bool inFavor;
    mapping(uint => bool) voted;
}
// Enum for voting types
enum VotingType {
    None,
    All,
    Majority
}