//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 < 0.9.0;

contract crowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    struct Request{
        string description;
        address payable recipent;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequests;

    constructor(uint _target, uint _deadline) public {
        target = _target;
        deadline = block.timestamp+_deadline;
        minimumContribution = 100 wei;
        manager = msg.sender;
    }
    function sendEth() public payable {
        require(block.timestamp < deadline,"Deadline has passed");
        require(msg.value >= minimumContribution,"Minimum contribution is not met");
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function getContractBalance()public view returns(uint){
        return address(this).balance;
    }
    function refund() public {
        require(block.timestamp>deadline,"you are not eligible for refund because deadline is not completed");
        require(raisedAmount<target,"You are not eligible. target is not met");
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);   
        contributors[msg.sender] = 0;
    }
    modifier onlyManager(){
        require(msg.sender==manager,"Onlymanager can call this function");
        _;
    }
    function createRequest(string memory _description,address payable _recipent, uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipent = _recipent;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }
    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender]>0,"you must be a contributor first");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"you have already voted");
        thisRequest.voters[msg.sender]= true;
        thisRequest.noOfVoters++;
    }
    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target,"target is not met");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"This request have been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"majority does not support");
        thisRequest.recipent.transfer(thisRequest.value);
        thisRequest.completed = true; 
    }

}
