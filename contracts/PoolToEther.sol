
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract PoolToEther is Ownable, ReentrancyGuard{

    constructor(){
        isMember[msg.sender] = true;
    }

    struct PoolMember {
        bool hasActiveDeposits;
        uint256 totalDeposits;
        uint256 rewardsToHarvest;
    }

    struct PoolDeposit {
        uint8 depositId;
        uint256 depositDateTime;
        uint256 ammount;
    }
    mapping(address => uint) balances;
    mapping(address => PoolMember) participant;
    mapping(address => uint256) participantId;
    mapping(address =>  PoolDeposit) depositsTracker;
    mapping(address => bool) isMember;
    mapping(address => uint256) userBalanceInPool;
    mapping(address => uint256) rewardsDeposited;
    mapping(address => uint256) rewards;
    mapping(address => uint256) internal _unlockTimestamps;

    // TODO: ADD EVENT TO DEPOSIT
    event Deposit(address indexed _from, bytes32 indexed _id, uint _value);
    event DepositRewards(address indexed _from, uint256 indexed _id, uint _value);
    uint256 currentWeekRewardsAvailable;
    uint256 totalContractRewards;

    PoolMember[] participants;
    uint256[] depositId;

    function manageMember(address member, bool newCondition) public onlyOwner{
        require(member != msg.sender, "The address must be different to the owner");
      
        isMember[member] = newCondition;
    }

    function isAddressTeamMember(address member) public view returns (bool){
        return isMember[member];
    }

    function balanceOf() external view returns(uint){
        return address(this).balance;
    }
    
    function depositRewardsPool() external payable {
        require(isMember[msg.sender] == true , "Only team members can deposit rewards");
        require(msg.value >= 0);
        
        _depositRewards(msg.value);
         uint256[] memory id = depositId;
         emit DepositRewards(msg.sender,id.length,msg.value);
    }

    
    function _depositRewards(uint256 ammountToDeposit) internal returns(uint256 newPoolBalance) {
        require(isMember[msg.sender] == true);

        currentWeekRewardsAvailable += ammountToDeposit;
        rewardsDeposited[msg.sender] += ammountToDeposit;

        return currentWeekRewardsAvailable;
    }

    function getRewardsRemaining() public view returns(uint256 totalPoolRewards){
        return currentWeekRewardsAvailable;
    }
}
 