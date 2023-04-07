// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Contract.sol";
import "./DataStructures.sol";

/**
 * @title Contract factory
 * @dev Factory creator of contracts
 */
contract ContractFactory {
    string public factoryName;
    // ContractId => ContractDefinition
    mapping(uint => Contract) private contracts;
    // Number of contracts
    uint private nContracts;
    event newContract(address indexed creator, uint indexed id);

    // Constructor
    constructor(string memory _factoryName) {
        factoryName = _factoryName;
    }

    // ++ Functions ++

    function addNewContract(bytes calldata _title, bytes calldata _points, address[] calldata _parties) external returns(bool) {
        contracts[nContracts] = new Contract(nContracts, _title, _points, _parties);
        nContracts += 1;
        emit newContract(msg.sender, nContracts);
        return true;
    }
    // ++ Setters ++
    function newVotingSession(uint _id , VotingType _type) external {
        contracts[_id].newVotingSession(_type);
    }
    function setVote(uint _id, bool _inFavor) external {
        contracts[_id].increaseVotes(_inFavor);
    }
    function setRepeatVote(uint _id, bool _inFavor) external {
        contracts[_id].repeatVote(_inFavor);
    }
    function setRightCessionRequest(uint _id, address _to) external {
        contracts[_id].rightCessionRequest(_to);
    }
    function setRightCession(uint _id, address[] calldata _toS) external {
        contracts[_id].rightCession(_toS);
    }
    function setRightRenounce(uint _id) external {
        contracts[_id].rightRenounce();
    }
    // ++ Getters ++
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
    function getVotingSessionData(uint _id, uint _number) external view  returns(VotingSession memory) {
        return contracts[_id].getVotingSessionData(_number);
    }
    function getSessionResult(uint _id, uint _number) external view  returns(string memory) {
        return contracts[_id].getSessionResult(_number);
    }
    /*
    function getVotingOpenDate(uint _id) external view  returns(uint) {
        return contracts[_id].getVotingOpenDate();
    }
    function getVotingCloseDate(uint _id) external view  returns(uint) {
        return contracts[_id].getVotingCloseDate();
    }
    */
}
