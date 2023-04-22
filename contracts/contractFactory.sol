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

    function addNewContract(bytes calldata _title, bytes calldata _detail, uint nTotalShares, address[] calldata _parties) external returns(bool) {
        contracts[nContracts] = new Contract(nContracts, _title, _detail, nTotalShares, _parties);
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
    function setShareCessionRequest(uint _id, address _to, uint _amount) external {
        contracts[_id].shareCessionRequest(_to, _amount);
    }
    function setShareCession(uint _id, address _to, uint _amount) external {
        contracts[_id].shareCession(_to, _amount);
    }
    function setshareRenounce(uint _id) external {
        contracts[_id].shareRenounce();
    }
    // ++ Getters ++
    function getTitle(uint _id) external view returns(bytes memory) {
        return contracts[_id].getTitle();
    }
    function getDetail(uint _id) external view returns(bytes memory) {
        return contracts[_id].getDetail();
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
}
