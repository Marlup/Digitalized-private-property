// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./DataStructures.sol";
import "./Contract.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract ContractFactory is DataStructures {
    // ContractId => ContractDefinition
    mapping(uint => Contract) private contracts;
    // Number of contracts
    uint private nContracts;
    event newContract(address indexed creator, uint indexed id);

    function addNewContract(bytes calldata _title, bytes calldata _points, address[] calldata _parties, VotingType _votingType) external returns(bool) {
        contracts[nContracts] = new Contract(nContracts, _title, _points, _parties, _votingType);
        nContracts += 1;
        emit newContract(msg.sender, nContracts);
        return true;
    }
    // Setters
    function openVoting(uint _id, address _party, VotingType _type) external {
        contracts[_id].openVoting(_party, _type);
    }
    function setVote(uint _id, address _party, bool _inFavor) external {
        contracts[_id].increaseVotes(_party, _inFavor);
    }

    function getTitle(uint _id) external view returns(bytes memory) {
        return contracts[_id].getTitle();
    }
    function getPoints(uint _id) external view returns(bytes memory) {
        return contracts[_id].getPoints();
    }
    function getPartyAllowed(uint _id, address _party) external view returns(bool) {
        return contracts[_id].getPartyAllowed(_party);
    }
    function getPartyVoted(uint _id, address _party) public view returns(bool) {
        return contracts[_id].getPartyVoted(_party);
    }
    function getNParties(uint _id) external view  returns(uint) {
        return contracts[_id].getNParties();
    }
    function getOpenDate(uint _id) external view  returns(uint) {
        return contracts[_id].getOpenDate();
    }
    function getCloseDate(uint _id) external view  returns(uint) {
        return contracts[_id].getCloseDate();
    }
    function getVotingOpenDate(uint _id) external view  returns(uint) {
        return contracts[_id].getVotingOpenDate();
    }
    function getVotingCloseDate(uint _id) external view  returns(uint) {
        return contracts[_id].getVotingCloseDate();
    }
}
