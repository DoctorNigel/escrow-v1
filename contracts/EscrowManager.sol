// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "./Ownable.sol";
import { PaymentLibrary } from "./libs/PaymentLibrary.sol";
import { ArbitrationLibrary } from "./libs/Arbitration.sol";
import { JobId, JobIdLibrary } from "./types/JobId.sol";
import { JobKey } from "./types/JobKey.sol";
import { Job } from "./libs/Job.sol";
import { Escrow } from "./libs/Escrow.sol";
import { IEscrowManager } from "./interfaces/IEscrowManager.sol";

contract EscrowManager is IEscrowManager, Ownable {
    using Job for *;
    using JobIdLibrary for JobKey;
    using Escrow for Escrow.Funds;
    using ArbitrationLibrary for ArbitrationLibrary.Arbitration;

    uint32 private jobNumber;

    mapping(JobId => JobData) private jobs;

    constructor(address _freelancer) Ownable(_freelancer) {}

    function contractOwner() public view returns (address) {
        return _msgSender();
    }

    function getJobId(uint32 jobId) private pure returns (JobId) {
        JobKey memory key = JobKey(jobId);
        JobId id = key.getId();
        return id;
    }

    function getJobs() external view returns (Job.State[] memory) {
        Job.State[] memory pending = new Job.State[](jobNumber);
        for (uint32 i; i <= jobNumber - 1; ++i) {
            JobKey memory key = JobKey(i);
            Job.State memory state = jobs[key.getId()].state;
            pending[i] = state;
        }
        return pending;
    }

    function getOwedAmount(uint32 jobId) external view override returns (uint256) {
        JobData memory jobData = getJobDataById(jobId);
        if (uint8(jobData.funds.payment.status) == 1) return 0;
        Escrow.Funds memory funds = jobData.funds;
        uint8 jobType = uint8(jobData.state.jobType);
        if (jobType == 0) {
            return funds.owed - funds.confirmedAmount;
        } else if (jobType == 1) {
            return funds.calculatePayment();
        } else {
            return 0;
        }
    }

    function getJobDataById(uint32 jobId) private view returns (JobData memory jobData) {
        jobData = jobs[getJobId(jobId)];
        if (jobData.state.client == address(0)) revert JobNotCreated();

        return jobData;
    }

    function getEscrowById(uint32 jobId) public view returns (Escrow.Funds memory escrow) {
        escrow = jobs[getJobId(jobId)].funds;
        if (!escrow.isActive) revert EscrowNotCreated();

        return escrow;
    }

    function arbiterOrOwner(JobData memory jobData) private view {
        if (msg.sender != jobData.state.arb || msg.sender != contractOwner()) {
            revert AccessDenied();
        }
    }

    function confirmDeposit(uint32 jobId, uint64 additionalAmount) external override returns (bool) {
        JobData memory jobData = getJobDataById(jobId);
        arbiterOrOwner(jobData);

        JobData storage oldData = jobs[getJobId(jobId)];

        oldData.funds.confirmedAmount = jobData.funds.confirmedAmount + additionalAmount;

        return true;
    }

    function pay(uint32 jobId) external returns (bool) {
        JobData memory jobData = getJobDataById(jobId);
        arbiterOrOwner(jobData);
        if (jobData.dispute.active == true || jobData.dispute.status != ArbitrationLibrary.Status.Resolved)
            revert EscrowIsLocked();

        uint256 amount = Escrow.completePayment(contractOwner(), jobData.funds);

        emit EscrowReleased(amount);

        return true;
    }

    function createJob(address client, address arbAddress, uint8 jobType) external override returns (uint32) {
        if (jobType >= 3) revert FalseJobType();
        if (client == address(0) || arbAddress == address(0)) revert IncompatibleAddressType();
        Job.State storage currentState = jobs[getJobId(jobNumber)].state;
        if (currentState.client != address(0)) revert JobIdAlreadyExists();

        Job.State memory state = Job.initialize(Job.JobType(jobType), client, arbAddress);

        ++jobNumber;

        currentState.jobType = state.jobType;
        currentState.client = state.client;
        currentState.arb = state.arb;

        emit Initialise(client, arbAddress, uint128(block.timestamp));

        return jobNumber;
    }

    function escrowInit(
        uint32 jobId,
        address token,
        uint8 hpd,
        uint64 owed,
        uint64 rate,
        uint64 releaseInterval,
        uint128 releaseDate
    ) external override returns (bool) {
        JobData storage jobData = jobs[getJobId(jobId)];
        if (rate > type(uint64).max) revert RateIntegerOverflow();
        if (releaseDate <= uint64(block.timestamp)) revert IncorrectReleaseTime();
        if (jobData.state.client == address(0)) revert JobNotCreated();
        if (jobData.funds.isActive) revert EscrowAlreadyExists();
        uint8 jobType = uint8(jobData.state.jobType);
        if ((jobType == 0 && hpd != 0) || (jobType != 0 && hpd == 0)) revert IncompatiblePaymentType();

        Escrow.Funds memory escrow = Escrow.escrowInit(token, hpd, owed, rate, releaseInterval, releaseDate);
        jobData.funds.token = escrow.token;
        jobData.funds.owed = escrow.owed;
        jobData.funds.isActive = escrow.isActive;
        jobData.funds.payment = escrow.payment;
        jobData.funds.releaseDate = escrow.releaseDate;
        jobData.funds.start = uint128(block.timestamp);

        emit EscrowCreated(jobId, token, hpd, owed, rate, releaseInterval, releaseDate);

        return true;
    }

    function arbiterOrOwnerOrClient(JobData memory jobData) private view {
        if (msg.sender != jobData.state.arb || msg.sender != contractOwner() || msg.sender != jobData.state.client) {
            revert AccessDenied();
        }
    }

    function onlyArbiter(JobData memory jobData) private view {
        if (msg.sender != jobData.state.arb) {
            revert AccessDenied();
        }
    }

    function disputeInit(uint32 jobId, uint128 end) external override returns (bool) {
        JobData storage jobData = jobs[getJobId(jobId)];
        if (jobData.dispute.initialiser != address(0)) revert DisputeAlreadyExists();
        arbiterOrOwnerOrClient(jobData);

        ArbitrationLibrary.Arbitration memory dispute = ArbitrationLibrary.init(end, msg.sender);
        jobData.dispute.active = dispute.active;
        jobData.dispute.status = dispute.status;
        jobData.dispute.initialiser = dispute.initialiser;
        jobData.dispute.end = dispute.end;

        emit DisputeCreated(msg.sender);

        return true;
    }

    function disputeResolve(uint32 jobId, ArbitrationLibrary.Status status) external override returns (bool) {
        JobData storage jobData = jobs[getJobId(jobId)];
        onlyArbiter(jobData);
        if (jobData.dispute.status == ArbitrationLibrary.Status.Resolved) revert DisputeAlreadyResolved();

        jobData.dispute.status = status;

        return true;
    }
}
