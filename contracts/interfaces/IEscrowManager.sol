// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { JobId } from "../types/JobId.sol";
import { JobKey } from "../types/JobKey.sol";
import { Job } from "../libs/Job.sol";
import { Escrow } from "../libs/Escrow.sol";
import { ArbitrationLibrary } from "../libs/Arbitration.sol";

interface IEscrowManager {
    error EscrowAlreadyExists();

    error EscrowNotCreated();

    error EscrowIsLocked();

    error EscrowNotReceived();

    error DisputeNotInitialised();

    error DisputeAlreadyExists();

    error DisputeAlreadyResolved();

    error IncorrectReleaseTime();

    error FalseJobType();

    error JobIdAlreadyExists();

    error JobNotCreated();

    error IncompatibleAddressType();

    error IncompatiblePaymentType();

    error RateIntegerOverflow();

    error AccessDenied();

    event Initialise(address indexed client, address indexed arbiter, uint128 indexed creationTime);

    event EscrowCreated(
        uint32 indexed id,
        address token,
        uint8 hpd,
        uint64 owed,
        uint64 rate,
        uint64 releaseInterval,
        uint128 releaseDate
    );

    event EscrowReleased(uint256 indexed amount);

    event DisputeCreated(address indexed caller);

    struct JobData {
        Job.State state;
        Escrow.Funds funds;
        ArbitrationLibrary.Arbitration dispute;
    }

    function getOwedAmount(uint32 id) external view returns (uint256);

    function getEscrowById(uint32 id) external view returns (Escrow.Funds memory);

    function confirmDeposit(uint32 id, uint64 additionalAmount) external returns (bool);

    function createJob(address client, address arbAddress, uint8 jobType) external returns (uint32);

    function escrowInit(
        uint32 jobId,
        address token,
        uint8 hpd,
        uint64 owed,
        uint64 rate,
        uint64 releaseInterval,
        uint128 releaseDate
    ) external returns (bool);

    function disputeInit(uint32 id, uint128 end) external returns (bool);

    function disputeResolve(uint32 jobId, ArbitrationLibrary.Status status) external returns (bool);
}
