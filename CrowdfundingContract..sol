// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <=0.9.0;

contract CrowdFunding {
    string public name; // name of the fund
    address public owner; // address which raised the crowdfunding
    uint256 public amountToBeRaised; // Max amount needed in the crowdfunding
    uint256 public donorCount; // No of Donors
    //uint256 public noOfVotes; //votes by donor
    uint256 public amountRaised; // amount raised by Donors
    uint256 public moneyNeeded; // Money needed by the crowdfund owner
    // bool public allowedToWithdraw = false; // Crowd fund owner is allowed to withdraw or not
    mapping(address => uint256) public donor; // value donated by the donor
    mapping(address => bool) isDonor; // To check donor
    mapping(uint256 => address) public DonorNo;
    mapping(string => bool) public checkReq;
   
   struct WithdrawRequest{
     string reason;
     uint256 amountNeeded;
     uint256 noOfVotes;
     mapping(address=>bool) voters;
     bool isComplete ;
   }


    uint256 public numRequests;
    mapping(uint256 => WithdrawRequest) public requests;
     
    constructor(
        string memory _name,
        address _owner,
        uint256 _amountToBeRaised
    ) payable {
        name = _name;
        owner = _owner;
        // amountToBeRaised = _amountToBeRaised ;
        amountToBeRaised = _amountToBeRaised * 10**18;
    }

    function donateAmount() public payable {
        require(msg.value > 0 ether, "please thoda paisa dedo");
        donor[msg.sender] += msg.value;
        amountRaised += msg.value;
        isDonor[msg.sender] = true;
        DonorNo[donorCount] = msg.sender;
        donorCount++;
    }
 
    function getBalanceUpdate() public view returns (uint256) {
        uint256 balance = address(this).balance / 10**18;
        return balance;
    }

    function withdrawReq(string memory _reason, uint256 amountNeeded) public {
        require(owner == msg.sender, "You are not allowed to req");
        require(!checkReq[_reason], "You've already requested for this reason");
        // moneyNeeded = amountNeeded * 10**18; // taking value from argument for further use;
        WithdrawRequest storage newRequest = requests[numRequests++];
        newRequest.reason = _reason;
        newRequest.amountNeeded = amountNeeded; 
        checkReq[_reason] == true;

    }

    function withdraw(uint256 requestId) public payable {
        require(owner == msg.sender, "You are not allowed to withdraw");
        require(requests[requestId].amountNeeded < amountRaised, "Insufficient balance");
        require(donorCount/2<=requests[requestId].noOfVotes, "You do not have enough Votes");
        require(!requests[requestId].isComplete , "You have already withdrawn for this request");
        

        payable(msg.sender).transfer(requests[requestId].amountNeeded);
        requests[requestId].isComplete = true;


    }

    function voteForWithdraw(uint256 requestId) public { 
        require(isDonor[msg.sender], "You are not a Donor");
         require(!requests[requestId].voters[msg.sender], "You have already voted");
         require(!requests[requestId].isComplete, "This request is no longer active");
        //  require(requests[requestId],"id does not exist");
        //  require(requests[requestId],"there is no such request");
        require(requests[requestId].amountNeeded !=0 , "This id does not exist");
        requests[requestId].noOfVotes++; 

        requests[requestId].voters[msg.sender] = true;


        // if (donorCount / 2 < noOfVotes) {
        //     allowedToWithdraw = true;
        // }
        // else{
        //     allowedToWithdraw = false;
        // }
     
    }
}

contract Factory {
    //Deploy crowd funding contract from this contract
    CrowdFunding[] public cfAddress;

    function createAndSendEther(
        string memory _name,
        address _owner,
        uint256 _amountToBeRaised
    ) public  {
        CrowdFunding obj = new CrowdFunding(_name, _owner, _amountToBeRaised);
        cfAddress.push(obj);    

    }
}


//can add limit the withrawn amount

//can restrict withdrawing for the same reason again 