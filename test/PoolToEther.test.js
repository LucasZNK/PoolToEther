const { expect } = require("chai");

describe("Members tests", () => {
  let PoolContract, poolContract, owner, addr1, addr2;

  beforeEach(async () => {
    PoolContract = await ethers.getContractFactory("PoolToEther");
    poolContract = await PoolContract.deploy();
    [owner, addr1, addr2] = await ethers.getSigners();
  });

  describe("Deployment and team members", async () => {
    it("should set the right owner", async () => {
      expect(await poolContract.owner()).to.equal(owner.address);
    });

    it("shoul can set new team members", async () => {
      await poolContract.manageMember(addr1.address, true);
      expect(await poolContract.isAddressTeamMember(addr1.address)).to.be.true;
    });

    it("shoul can remove team members", async () => {
      await poolContract.manageMember(addr1.address, false);
      expect(await poolContract.isAddressTeamMember(addr1.address)).to.be.false;
    });
  });

  describe("Rewards deposits", async () => {
    it("should owner can deposit ether and impact in rewawrds pool", async () => {
      await poolContract.depositRewardsPool({
        from: owner.address,
        value: ethers.utils.parseEther("30"),
      });

      const rewards = await poolContract.getRewardsRemaining();

      const formattedRewards = await ethers.utils.formatEther(rewards);
      expect(formattedRewards).to.be.equal("30.0");
    });

    it("should team members can deposit ether and impact in rewawrds pool", async () => {
      await poolContract.manageMember(addr1.address, true);

      await poolContract.connect(addr1).depositRewardsPool({
        value: ethers.utils.parseEther("30"),
      });

      const rewards = await poolContract.getRewardsRemaining();

      const formattedRewards = await ethers.utils.formatEther(rewards);
      expect(formattedRewards).to.be.equal("30.0");
    });

    it("should fail if no team meber try to add rewards", async () => {
      await poolContract.manageMember(addr1.address, false);

      await expect(
        poolContract.connect(addr1).depositRewardsPool({
          value: ethers.utils.parseEther("30"),
        })
      ).to.be.revertedWith("Only team members can deposit rewards");
    });
  });
});

describe("Users tests", () => {
  let PoolContract, poolContract, owner, addr1, addr2;

  beforeEach(async () => {
    PoolContract = await ethers.getContractFactory("PoolToEther");
    poolContract = await PoolContract.deploy();
    [owner, addr1, addr2] = await ethers.getSigners();
  });

  describe("User deposits", () => {
    it("should team members can't deposit in the reward pools", async () => {
      await poolContract.manageMember(addr1.address, true);
      await expect(
        poolContract.connect(addr1).depositFunds({
          value: ethers.utils.parseEther("30"),
        })
      ).to.be.revertedWith("Team members address can't participate");
    });

    it("should users can deposit funds", async () => {
      await poolContract.manageMember(addr1.address, false);
      await expect(
        poolContract.connect(addr1).depositFunds({
          value: ethers.utils.parseEther("30"),
        })
      ).to.be.not.reverted;
    });

    it("should deposit be reflecred on the user ammount", async () => {
      await poolContract.connect(addr1).depositFunds({
        value: ethers.utils.parseEther("15.2"),
      });
      const balance = await poolContract.getUserBalance(addr1.address);
      const formattedUserBalance =  await ethers.utils.formatEther(balance);
       expect(formattedUserBalance ).to.be.equal("15.2");
    });

    it("should deposit be reflected in the total pool ammount", async () => {
      await poolContract.connect(addr1).depositFunds({
        value: ethers.utils.parseEther("15"),
      });
      await poolContract.connect(addr2).depositFunds({
        value: ethers.utils.parseEther("15"),
      });

      const balance = await poolContract.getTotalFundsInPool();

      const formattedPoolBalance =  await ethers.utils.formatEther(balance);
       expect(formattedPoolBalance ).to.be.equal("30.0");
    });
  });
});
