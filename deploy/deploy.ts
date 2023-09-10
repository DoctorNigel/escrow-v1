import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const greeter = await deploy("EscrowManager", {
    from: deployer,
    args: ["0x9DC9d92f1E447ed2E5AFE3F39fAcEa3fdc6dB11Fe"],
    log: true,
  });

  console.log(`EscrowManager contract: `, greeter.address);
};
export default func;
func.id = "deploy_escrowmanager"; // id required to prevent reexecution
func.tags = ["EscrowManager"];
