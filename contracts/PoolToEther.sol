import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

/// TODO: DOCUMENT ALL FUNCTIONS
contract PoolToEther is Ownable, ReentrancyGuard {
    constructor() {
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
    mapping(address => uint256) balances;
    mapping(address => PoolMember) participant;
    mapping(address => uint256) participantId;
    mapping(address => PoolDeposit) depositsTracker;
    mapping(address => bool) isMember;
    mapping(address => uint256) userBalanceInPool;
    mapping(address => uint256) rewardsDeposited;
    mapping(address => uint256) rewards;
    mapping(address => uint256) internal _unlockTimestamps;

    // TODO: ADD EVENT TO DEPOSIT
    event Deposit(address indexed _from, bytes32 indexed _id, uint256 _value);
    event DepositRewards(
        address indexed _from,
        uint256 indexed _id,
        uint256 _value
    );
    uint256 currentWeekRewardsAvailable;
    uint256 totalContractRewards;
    uint256 totalPoolFunds; 
    PoolMember[] participants;
    uint256[] depositId;

    function manageMember(address member, bool newCondition) public onlyOwner {
        require(member != msg.sender,"The address must be different to the owner");
        isMember[member] = newCondition;
    }

    function isAddressTeamMember(address member) public view returns (bool) {
        return isMember[member];
    }

    function balanceOf() external view returns (uint256) {
        return address(this).balance;
    }

    function getRewardsRemaining() public view returns (uint256 totalPoolRewards) {
        return currentWeekRewardsAvailable;
    }

    function depositRewardsPool() external payable {
        require(isMember[msg.sender] == true,"Only team members can deposit rewards");

        _depositRewards(msg.value);
        uint256[] memory id = depositId;
        emit DepositRewards(msg.sender, id.length, msg.value);
    }

    function getTotalFundsInPool() public view returns (uint256){
        return totalPoolFunds;
    }

    function getUserBalance(address user) public view returns(uint256) {
        return balances[user];
    }

    function _depositRewards(uint256 ammountToDeposit) internal returns (uint256 newPoolBalance) {
        require(isMember[msg.sender] == true);

        currentWeekRewardsAvailable += ammountToDeposit;
        rewardsDeposited[msg.sender] += ammountToDeposit;

        return currentWeekRewardsAvailable;
    }

    function depositFunds() public payable returns (PoolDeposit memory newDeposit) {
        require(!isMember[msg.sender],"Team members address can't participate");
        
        // // Separate rewards. Clear deposit
        // _separateRewardsForUser(msg.sender);

        // Create new deposit
        return _newDeposit(msg.sender, msg.value);
    }

    function _newDeposit(address user, uint256 ammount) internal returns (PoolDeposit memory newDeposit) {
        require(ammount >= 0, "Invalid ammount to deposit");
        require(!isMember[user], "No team member allowed");

        // /// @dev TODO: Work on separateRewards function
        // if( userBalanceInPool[user] > 0 ){
        //     _separateRewardsForUser(user);
        // }

        /// @dev CreateNewDeposit
        depositsTracker[user] = PoolDeposit(1, block.timestamp, ammount);
        totalPoolFunds += ammount;
        balances[user] += ammount;

        return depositsTracker[user];
    }

    // function _separateRewardsForUser(address user) internal {
    //     PoolDeposit memory lastDeposit = depositsTracker[user];
    //     _calculateRewards(lastDeposit.ammount);
    // }

    // function _calculateRewards(uint256 ammountInPool) internal returns (uint256) {
    //     require(ammountInPool >= 0,"Balance invalid");

    //     // Sum the total ammount in the pool for the user, previous of deleting the actual deposit

    // }
}
