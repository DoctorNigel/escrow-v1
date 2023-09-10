import { expect } from "chai";
import { ethers } from "hardhat";

export function escrowManagerBehaviour(): void {
  it("should return the contract owner address", async function () {
    const address = await this.escrowManager.connect(this.signers.admin).contractOwner();
    expect(address).to.equal("0x9DC9d92f1E447ed2E5AFE3F39fAcEa3fdc6dB11F");
  });

  it("should insert a new job", async function () {
    const state = await this.escrowManager
      .connect(this.signers.admin)
      .createJob("0xD9029756587A8e86B5f15bC557b11Bf5299DEe0f", "0xF294aa5c0fe51A85011E970B69Feff4eF4F7F32C", 0);
    expect(state).to.not.null;
  });

  it("should dissallow duplicate job keys for createJob function", async function () {
    expect(
      await this.escrowManager
        .connect(this.signers.admin)
        .createJob(
          ethers.getAddress("0xD9029756587A8e86B5f15bC557b11Bf5299DEe0f"),
          ethers.getAddress("0xF294aa5c0fe51A85011E970B69Feff4eF4F7F32C"),
          0,
        ),
    ).to.revertedWith("JobIdAlreadyExists");
  });
  /*
  it("should fetch the jobData by ID", async function () {
    await this.escrowManager
      .connect(this.signers.admin)
      .createJob(
        ethers.getAddress("0x9DC9d92f1E447ed2E5AFE3F39fAcEa3fdc6dB11F"),
        ethers.getAddress("0xbe42c1119CBE64ba4120B9bcC47768761831749d"),
        0,
      );
    const jobData = await this.escrowManager.connect(this.signers.admin).getJobDataById(0);
    console.log(jobData);
    expect(jobData).to.not.null;
  });*/

  it("should return pending jobs", async function () {
    // Add a few new jobs
    await this.escrowManager
      .connect(this.signers.admin)
      .createJob("0xD9029756587A8e86B5f15bC557b11Bf5299DEe0f", "0xF294aa5c0fe51A85011E970B69Feff4eF4F7F32C", 0);
    await this.escrowManager
      .connect(this.signers.admin)
      .createJob("0xD9029756587A8e86B5f15bC557b11Bf5299DEe0f", "0xF294aa5c0fe51A85011E970B69Feff4eF4F7F32C", 0);
    await this.escrowManager
      .connect(this.signers.admin)
      .createJob("0xD9029756587A8e86B5f15bC557b11Bf5299DEe0f", "0xF294aa5c0fe51A85011E970B69Feff4eF4F7F32C", 0);

    const pendingJobs = await this.escrowManager.connect(this.signers.admin).getJobs();
    console.log(pendingJobs);
    expect(pendingJobs).to.not.null;
  });

  it("should create a new escrow", async function () {
    await this.escrowManager
      .connect(this.signers.admin)
      .createJob(
        ethers.getAddress("0xD9029756587A8e86B5f15bC557b11Bf5299DEe0f"),
        ethers.getAddress("0xF294aa5c0fe51A85011E970B69Feff4eF4F7F32C"),
        0,
      );

    expect(
      await this.escrowManager
        .connect(this.signers.admin)
        .escrowInit(0, "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", 0, 10000, 0, 2629800000, 1723211868),
    ).to.not.null;
  });

  it("should return escrow by id", async function () {
    await this.escrowManager
      .connect(this.signers.admin)
      .createJob(
        ethers.getAddress("0xD9029756587A8e86B5f15bC557b11Bf5299DEe0f"),
        ethers.getAddress("0xF294aa5c0fe51A85011E970B69Feff4eF4F7F32C"),
        0,
      );

    await this.escrowManager
      .connect(this.signers.admin)
      .escrowInit(0, "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", 0, 10000, 0, 2629800000, 1723211868);
    const funds = await this.escrowManager.connect(this.signers.admin).getEscrowById(0);
    console.log(funds);
    expect(funds).to.not.null;
  });

  it("should return correct owed amount", async function () {
    await this.escrowManager
      .connect(this.signers.admin)
      .createJob(
        ethers.getAddress("0xD9029756587A8e86B5f15bC557b11Bf5299DEe0f"),
        ethers.getAddress("0xF294aa5c0fe51A85011E970B69Feff4eF4F7F32C"),
        0,
      );

    await this.escrowManager
      .connect(this.signers.admin)
      .escrowInit(0, "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", 0, 10000, 0, 2629800000, 1723211868);

    expect(await this.escrowManager.connect(this.signers.admin).getOwedAmount(0)).to.equal(10000);
  });

  it("should revert the already concluded job", async function () {});
}
