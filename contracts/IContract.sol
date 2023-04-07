// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DataStructures.sol";

/**
 * @title IContract
 * @dev Interface for basic agreement contract functionality
 */
interface IContract {
    // ++ Setters ++
    function newVotingSession(VotingType _type) external;
    function increaseVotes(bool _inFavor) external returns(bool);
    function tryCloseVoting() external;
    // Contract getters
    function getFactory() external view returns(address);
    function getTitle() external view returns(bytes memory);
    function getPoints() external view returns(bytes memory);
    // Party getters
    function getNParties() external view returns(uint);
    function getPartyAllowed(address _party) external view returns(bool);
    function getPartyVoted(address _party) external view returns(bool);
    // Voting getters
    function getVotingSessionData(uint _number) external view returns(VotingSession memory);
    //function getVotes() external view returns(uint, uint);
    //function getVotingOpenDate() external view returns(uint);
    //function getVotingCloseDate() external view returns(uint);
    // Right access functions
    function rightCessionRequest(address _from) external;
    function rightCession(address[] calldata _toS) external;
    function rightRenounce() external;
}
