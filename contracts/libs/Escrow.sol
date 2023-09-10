// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { JobId } from "../types/JobId.sol";
import { PaymentLibrary } from "../libs/PaymentLibrary.sol";

library Escrow {
    uint128 private constant zero = 0;
    uint256 private constant hour_to_milli = 3600000;

    struct Funds {
        bool isActive;
        address token;
        PaymentLibrary.Payment payment;
        uint64 owed;
        uint64 confirmedAmount;
        uint64 released;
        uint128 releaseDate;
        uint128 start;
    }

    function escrowInit(
        address token,
        uint8 hpd,
        uint64 owed,
        uint64 rate,
        uint64 releaseInterval,
        uint128 releaseDate
    ) internal pure returns (Funds memory funds) {
        if (hpd >= 9) revert PaymentLibrary.HourlyPaymentLimitReached();

        return
            funds = Funds({
                token: token,
                isActive: true,
                payment: PaymentLibrary.Payment({
                    rate: rate,
                    hpd: hpd,
                    status: PaymentLibrary.Status(0),
                    releaseInterval: releaseInterval
                }),
                owed: owed,
                confirmedAmount: uint64(zero),
                released: uint64(zero),
                releaseDate: releaseDate,
                start: zero
            });
    }

    function calculatePayment(Funds memory funds) internal view returns (uint256) {
        uint256 elapsedTime = block.timestamp - funds.start;
        uint256 x = elapsedTime / hour_to_milli;
        uint256 due = funds.payment.hpd * x * funds.payment.rate - (funds.confirmedAmount);

        return due;
    }

    function releaseable(Funds memory funds) internal view returns (uint256) {
        if (funds.payment.hpd == 0) {
            if (funds.releaseDate >= block.timestamp) return zero;
            return funds.confirmedAmount - funds.released;
        } else {
            uint256 elapsedTime = block.timestamp - funds.start;

            // Too short releaseInterval is potentially problematic!
            uint256 factor = 24 / funds.payment.hpd;
            uint256 hours_per_epoch = funds.payment.releaseInterval / hour_to_milli;
            uint256 workableHours = hours_per_epoch / factor;
            uint256 epochs = elapsedTime / hours_per_epoch;
            uint256 salary_per_epoch = (funds.payment.rate * funds.payment.hpd) * workableHours;
            return epochs * salary_per_epoch - funds.confirmedAmount;
        }
    }

    function completePayment(address receiver, Funds memory funds) internal returns (uint256 amount) {
        amount = releaseable(funds);
        PaymentLibrary.safeTransfer(funds.token, receiver, amount);

        return amount;
    }
}
