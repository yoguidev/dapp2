// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract Voting is Ownable {

    uint[] winningProposalsID;
    Proposal[] winningProposals;
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    enum  WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus public workflowStatus;
    Proposal[] proposalsArray;
    mapping (address => Voter) voters;


    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    modifier onlyVoters() {
        require(voters[msg.sender].isRegistered, "You're not a voter");
        _;
    }
    
    // on peut faire un modifier pour les états

    // ::::::::::::: GETTERS ::::::::::::: //

    function getVoter(address _addr) external onlyVoters view returns (Voter memory) {
        return voters[_addr];
    }
    
    function getOneProposal(uint _id) external onlyVoters view returns (Proposal memory) {
        return proposalsArray[_id];
    }

 
    // ::::::::::::: REGISTRATION ::::::::::::: // 

    function addVoter(address _addr) external onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Voters registration is not open yet');
        require(voters[_addr].isRegistered != true, 'Already registered');
    
        voters[_addr].isRegistered = true;
        emit VoterRegistered(_addr);
    }
 
    
    function deleteVoter(address _addr) external onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Voters registration is not open yet');
        require(voters[_addr].isRegistered == true, 'Not registered.');
        voters[_addr].isRegistered = false;
        emit VoterRegistered(_addr);
    }

    // ::::::::::::: PROPOSAL ::::::::::::: // 

    function addProposal(string memory _desc) external onlyVoters {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, 'Proposals are not allowed yet');
        require(keccak256(abi.encode(_desc)) != keccak256(abi.encode("")), 'Vous ne pouvez pas ne rien proposer'); // facultatif
        // voir que desc est different des autres

        Proposal memory proposal;
        proposal.description = _desc;
        proposalsArray.push(proposal);
        emit ProposalRegistered(proposalsArray.length-1);
    }

    // ::::::::::::: VOTE ::::::::::::: //

    function setVote( uint _id) external onlyVoters {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, 'Voting session havent started yet');
        require(voters[msg.sender].hasVoted != true, 'You have already voted');
        require(_id < proposalsArray.length, 'Proposal not found'); // pas obligé, et pas besoin du >0 car uint

        voters[msg.sender].votedProposalId = _id;
        voters[msg.sender].hasVoted = true;
        proposalsArray[_id].voteCount++;

        emit Voted(msg.sender, _id);
    }

    // ::::::::::::: STATE ::::::::::::: //

    modifier checkWorkflowStatus(uint  _num) {
        require (workflowStatus==WorkflowStatus(uint(_num)-1), "bad workflowstatus");
        require (_num != 5, "il faut lancer tally votes");
        _;
      }
    
    function setWorkflowStatus(uint _num) external checkWorkflowStatus(_num) onlyOwner {
        WorkflowStatus old = workflowStatus;
        workflowStatus = WorkflowStatus(_num);
        emit WorkflowStatusChange(old, workflowStatus);
       } 
    
        

    function tallyVotesDraw() external onlyOwner {
       require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Current status is not voting session ended");
        uint highestCount;
        uint[5]memory winners; // egalite entre 5 personnes max
        uint nbWinners;
        for (uint i = 0; i < proposalsArray.length; i++) {
            if (proposalsArray[i].voteCount == highestCount) {
                winners[nbWinners]=i;
                nbWinners++;
            }
            if (proposalsArray[i].voteCount > highestCount) {
                delete winners;
                winners[0]= i;
                highestCount = proposalsArray[i].voteCount;
                nbWinners=1;
            }
        }
        for(uint j=0;j<nbWinners;j++){
            winningProposalsID.push(winners[j]);
            winningProposals.push(proposalsArray[winners[j]]);
        }
        workflowStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
    }



}
