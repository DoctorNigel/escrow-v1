// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Arbiter } from "../types/Arbiter.sol";

library Job {
    error JobAlreadyConcluded();

    enum JobType {
        Single,
        Hourly,
        Milestone
    }

    struct State {
        JobType jobType;
        address client;
        address arb;
    }

    function initialize(JobType jobType, address client, address arbAddress) internal pure returns (State memory) {
        State memory self = State({ jobType: jobType, client: client, arb: arbAddress });
        return self;
    }
}
