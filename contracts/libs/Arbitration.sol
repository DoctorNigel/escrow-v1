// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Arbiter } from "../types/Arbiter.sol";
import { Ownable } from "../Ownable.sol";

library ArbitrationLibrary {
    enum Status {
        Inactive,
        Pending,
        Resolved
    }

    struct Arbitration {
        bool active;
        Status status;
        address initialiser;
        uint128 end;
    }

    function init(uint128 end, address initialiser) internal pure returns (Arbitration memory dispute) {
        return dispute = Arbitration({ active: true, status: Status.Pending, initialiser: initialiser, end: end });
    }
}
