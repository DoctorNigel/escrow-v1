import { ethers } from "hardhat";

import type { EscrowManager } from "../../types/EscrowManager";
import type { EscrowManager__factory } from "../../types/factories/EscrowManager__factory";

export async function deployEscrowManagerFixture(): Promise<{ escrowManager: EscrowManager }> {
  const signers = await ethers.getSigners();
  const admin = signers[0];

  const string = "0x9DC9d92f1E447ed2E5AFE3F39fAcEa3fdc6dB11F";
  const escrowMangerFactory = await ethers.getContractFactory("EscrowManager");
  const escrowManager = await escrowMangerFactory.connect(admin).deploy(string);
  await escrowManager.waitForDeployment();

  return { escrowManager };
}
