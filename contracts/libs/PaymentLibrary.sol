// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20Minimal } from "../interfaces/external/IERC20Minimal.sol";

library PaymentLibrary {
    error HourlyPaymentLimitReached();

    enum Status {
        Unpaid,
        Paid,
        Partial
    }

    struct Payment {
        Status status;
        uint8 hpd;
        uint64 rate;
        uint64 releaseInterval;
    }

    function safeTransfer(address token, address to, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Minimal(address(this)).transfer.selector, to, amount)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TF");
    }
}
