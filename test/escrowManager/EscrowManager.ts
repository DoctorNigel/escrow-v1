import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";

import type { Signers } from "../types";
import { escrowManagerBehaviour } from "./EscrowManager.behavior";
import { deployEscrowManagerFixture } from "./EscrowManager.fixture";

describe("Unit tests", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers = await ethers.getSigners();
    this.signers.admin = signers[0];

    this.loadFixture = loadFixture;
  });

  describe("EscrowManager Behaviour", function () {
    beforeEach(async function () {
      const { escrowManager } = await this.loadFixture(deployEscrowManagerFixture);
      this.escrowManager = escrowManager;
    });

    escrowManagerBehaviour();
  });
});
