// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IContract.sol";

/**
 * @title Contract
 * @dev Contract agreement with functionalities of IContract
 */
contract Contract is IContract {
    // Identifiers
    address private factory;
    uint private immutable contractId;
    // Descriptors
    bytes private title;
    bytes private points;
    // Session
    uint private currentSession;
    // Parties
    uint private nParties;
    // Mapping for party of contract (party, Party data)
    mapping(address => Party) private parties;
    // Mapping for external address cession request (party, bool)
    mapping(address => bool) private cessionRequest;
    // Mapping for voting sessions
    mapping(uint => VotingSession) private sessions;

    // ** Events **
    event RightCessionRequest(address indexed from, address indexed to, uint indexed time);
    event RightCession(address indexed from, address indexed to, uint indexed time);
    event RightRenounce(address indexed from, uint indexed time);

    // ** Modifiers **
    modifier rightOwner() {
        require(parties[msg.sender].isParty, "External has not right to operate");
        _;
    }
    modifier onSession() {
        require(sessions[currentSession].inProgress, "Session is not in progress");
        _;
    }
    modifier notOnSession() {
        require(!sessions[currentSession].inProgress, "Session is in progress");
        _;
    }
    modifier hasNotVoted() {
        require(!parties[msg.sender].voted[currentSession], "Party has voted");
        _;
    }
    modifier hasVoted() {
        require(parties[msg.sender].voted[currentSession], "Party has not voted");
        _;
    }
    modifier moreOneParties() {
        require(nParties > 1, "Number of parties is not greater than 1");
        _;
    }
    modifier okVotingType(VotingType _type) {
        require(_type != VotingType.None, "Voting type cannot be None");
        _;
    }
    /*
    * @dev Constructor to fill Contract data
    */
    constructor(uint _contractId, bytes memory _title, bytes memory _points, address[] memory _ids) {
        // Contract section
        factory = msg.sender;
        contractId = _contractId;
        title = _title;
        points = _points;
        // Parties section
        for (uint i = 0; i < _ids.length; i++) {
            parties[_ids[i]].isParty = true;
            parties[_ids[i]].wasParty = true;
        }
        nParties = _ids.length;
    }
    // ** Setters **
    /*
    * @dev A new session is opened
    */
    function newVotingSession(VotingType _type) external virtual override rightOwner() notOnSession() moreOneParties() okVotingType(_type)  {
        if (_type == VotingType.Majority && nParties < 3) {
            revert("Session with majority type is not allowed when number of parties is less than 3");
        }
        VotingSession storage _session = sessions[currentSession];
        _session.votingType = _type;
        _session.openDate = block.timestamp;
        _session.inProgress = true;
    }
    /*
    * @dev Add one vote count and in-favor vote if input is true.
    * Close voting if conditions apply
    */
    function increaseVotes(bool _inFavor) external virtual override rightOwner() onSession() moreOneParties() hasNotVoted() returns(bool) {
        if (_inFavor) {
            sessions[currentSession].nVotesInFavor += 1;
            parties[msg.sender].inFavor = true;
        }
        sessions[currentSession].nVotesDone += 1;
        parties[msg.sender].voted[currentSession] = true;
        _tryCloseVoting();
        return true;
    }
    /*
    * @dev Change vote to alternative
    * Close voting if conditions apply
    */
    function repeatVote(bool _inFavor) external rightOwner() onSession() moreOneParties() hasVoted() returns(bool) {
        require(parties[msg.sender].inFavor != _inFavor, "Party cannot vote the same option");
        if (_inFavor) {
            sessions[currentSession].nVotesInFavor += 1;
            parties[msg.sender].inFavor = true;
        } else {
            parties[msg.sender].inFavor = false;
        }
        _tryCloseVoting();
        return true;
    }
    /*
    * @dev Try to close the voting session (internal function)
    */
    function tryCloseVoting() external virtual override rightOwner() onSession() moreOneParties() {
        require(_tryCloseVoting(), "Session cannot be closed");
    }
    /*
    * @dev Try to close the voting session (internal function)
    */
    function _tryCloseVoting() internal returns(bool) {
        VotingSession storage _session = sessions[currentSession];
        if (_checkVotingTargetOk()) {
            _session.closeDate = block.timestamp;
            _session.inProgress = false;
            // Store closed voting session into historic
            currentSession += 1;
            return true;
        }
        return false;
    }
    /*
    * @dev Check if voting session ended successfully
    */
    function _checkVotingTargetOk() internal view returns(bool) {
        VotingSession memory _session = sessions[currentSession];
        if (_session.votingType == VotingType.All) {
            return nParties == _session.nVotesInFavor || (_session.nVotesDone - _session.nVotesInFavor) == nParties;
        } else if (_session.votingType == VotingType.Majority) {
            uint voteThreshold = nParties / 2 + nParties % 2;
            return _session.nVotesInFavor > voteThreshold || (_session.nVotesDone - _session.nVotesInFavor) > _session.nVotesInFavor;
        }
        return false;
    }
    // ** Contract getters **
    /*
    * @dev Returns factory address of the contract factory 
    * that instantiated the contract
    */
    function getFactory() external virtual override view returns(address) {
        return factory;
    }
    /*
    * @dev Returns title of the contract
    */
    function getTitle() external virtual override view returns(bytes memory) {
        return title;
    }
    /*
    * @dev Returns conditions/points of the contract
    */
    function getPoints() external virtual override view returns(bytes memory) {
        return points;
    }
    /*
    * @dev Returns number of parties
    */
    function getNParties() external virtual override view  returns(uint) {
        return nParties;
    }
    // ** Party getters **
    /*
    * @dev Returns if party have right to this contract
    */
    function getPartyAllowed(address _party) external virtual override view returns(bool) {
        return parties[_party].isParty;
    }
    /*
    * @dev Returns if party voted
    */
    function getPartyVoted(address _party) external virtual override view returns(bool) {
        return parties[_party].voted[currentSession];
    }
    /*
    * @dev Returns voting session data
    */
    function getVotingSessionData(uint _number) external virtual override view returns(VotingSession memory) {
        return sessions[_number];
    }
    /*
    * @dev Returns voting session result: notInFavor, inFavor or none
    */
    function getSessionResult(uint _number) external view notOnSession() returns(string memory) {
        VotingSession memory _session = sessions[_number];
        if (_session.votingType == VotingType.All) {
            if (_session.nVotesInFavor == 0) {
                return "notInFavor";
            } else {
                return "inFavor";
            }
        } else if (_session.votingType == VotingType.Majority) {
            if ((_session.nVotesDone - _session.nVotesInFavor) > _session.nVotesInFavor) {
                return "notInFavor";
            } else {
                return "inFavor";
            }
        } else {
            return "none";
        }
    }
    /*
    * @dev Returns number of votes done and in votes favor
    */
    /*
    function getVotes() external virtual override view returns(uint, uint) {
        return (sessions[currentSession].nVotesDone, sessions[currentSession].nVotesInFavor);
    }
    /*
    * @dev Returns open date of voting session
    */
    /*
    function getVotingOpenDate() external virtual override view returns(uint) {
        return sessions[currentSession].openDate;
    }
    /*
    * @dev Returns close date of voting session
    */
    /*
    function getVotingCloseDate() external virtual override view returns(uint) {
        return sessions[currentSession].closeDate;
    }
    /*
    * @dev External/non-party cession of rights request to party
    */
    function rightCessionRequest(address _to) external virtual override {
        require(!cessionRequest[msg.sender], "Solicitant has already requested right cession");
        require(!parties[msg.sender].isParty, "Solicitant is already a party");
        require(msg.sender != _to, "Cedant and cessionary cannot be equal");
        require(parties[_to].isParty, "Cedant is not a party");
        // Update request
        cessionRequest[msg.sender] = true;
        emit RightCessionRequest(msg.sender, _to, block.timestamp);
    }
    /*
    * @dev Cession of right to external address/addresses, hence making it/them party/parties
    */
    function rightCession(address[] calldata _toS) external virtual override rightOwner() notOnSession() {
        // Swap party right
        for (uint i = 0; i < _toS.length; i++) {
            require(cessionRequest[_toS[i]], "External has not requested any right cession");
            require(!parties[_toS[i]].isParty, "Cessionary is already a party");
            // Update right cession
            parties[_toS[i]].isParty = true;
            parties[_toS[i]].wasParty = true;
            // Update right request
            cessionRequest[_toS[i]] = false;
            // Emit right cession
            emit RightCession(msg.sender, _toS[i], block.timestamp);
        }
        parties[msg.sender].isParty = false;
        if (_toS.length > 1){
            // If right is given to more than 1 parties
            nParties += _toS.length - 1;
        }
    }
    /*
    * @dev Remove party from contract
    */
    function rightRenounce() external virtual override rightOwner() notOnSession() moreOneParties() {
        parties[msg.sender].isParty = false;
        nParties -= 1;
        emit RightRenounce(msg.sender, block.timestamp);
    }
}
