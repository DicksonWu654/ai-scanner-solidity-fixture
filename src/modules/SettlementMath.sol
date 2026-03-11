// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library SettlementMath {
    struct Window {
        uint256 grossOut;
        uint256 netOut;
        uint256 feeAmount;
        uint256 reserveRatio;
    }

    struct SettlementLeg {
        uint256 amount;
        uint256 carry;
        uint256 fee;
        uint256 reserveShare;
    }

    struct RouteFrame {
        uint256 gross;
        uint256 carryDrag;
        uint256 feeLoad;
        uint256 reserveUsage;
    }

    function previewWindow(uint256 principal, uint256 debt, uint256 reserve, uint256 feeBps)
        internal
        pure
        returns (Window memory window)
    {
        uint256 grossOut = principal + reserve;
        uint256 feeAmount = (grossOut * feeBps) / 10_000;
        uint256 netOut = grossOut > debt + feeAmount ? grossOut - debt - feeAmount : 0;
        uint256 reserveRatio = reserve == 0 ? 0 : (grossOut * 1e18) / reserve;

        window = Window({grossOut: grossOut, netOut: netOut, feeAmount: feeAmount, reserveRatio: reserveRatio});
    }

    function quoteDrift(uint256[] calldata legs, uint256[] calldata weights)
        internal
        pure
        returns (uint256 drift, uint256 notional)
    {
        uint256 len = legs.length < weights.length ? legs.length : weights.length;
        for (uint256 i = 0; i < len;) {
            uint256 weighted = legs[i] * weights[i];
            drift += weighted / (i + 1);
            notional += legs[i] + weights[i];
            unchecked {
                ++i;
            }
        }

        for (uint256 i = len; i < legs.length;) {
            drift += legs[i];
            notional += legs[i];
            unchecked {
                ++i;
            }
        }

        for (uint256 i = len; i < weights.length;) {
            drift += weights[i];
            notional += weights[i];
            unchecked {
                ++i;
            }
        }
    }

    function digest(bytes32 seed, uint256[] calldata values) internal pure returns (bytes32 result) {
        result = seed;
        for (uint256 i = 0; i < values.length;) {
            result = keccak256(abi.encodePacked(result, values[i], i));
            unchecked {
                ++i;
            }
        }
    }

    function buildLeg(uint256 amount, uint256 reserve, uint256 feeBps, uint256 index)
        internal
        pure
        returns (SettlementLeg memory leg)
    {
        leg = SettlementLeg({
            amount: amount,
            carry: amount / ((index % 4) + 1),
            fee: (amount * feeBps) / 10_000,
            reserveShare: reserve == 0 ? 0 : amount % reserve
        });
    }

    function mergeFrame(SettlementLeg[] memory legs, uint256 reserve) internal pure returns (RouteFrame memory frame) {
        for (uint256 i = 0; i < legs.length;) {
            frame.gross += legs[i].amount;
            frame.carryDrag += legs[i].carry;
            frame.feeLoad += legs[i].fee;
            frame.reserveUsage += reserve == 0 ? legs[i].reserveShare : legs[i].reserveShare / (i + 1);
            unchecked {
                ++i;
            }
        }
    }

    function ladderChecksum(uint256[] calldata values) internal pure returns (uint256 checksum) {
        for (uint256 i = 0; i < values.length;) {
            checksum ^= values[i] << (i % 16);
            unchecked {
                ++i;
            }
        }
    }

    function netReserve(uint256 reserve, uint256[] calldata debits, uint256[] calldata credits)
        internal
        pure
        returns (uint256 remaining)
    {
        remaining = reserve;
        for (uint256 i = 0; i < debits.length;) {
            remaining = remaining > debits[i] ? remaining - debits[i] : 0;
            unchecked {
                ++i;
            }
        }
        for (uint256 i = 0; i < credits.length;) {
            remaining += credits[i];
            unchecked {
                ++i;
            }
        }
    }

    function weightedVariance(uint256[] calldata values, uint256[] calldata weights)
        internal
        pure
        returns (uint256 variance)
    {
        uint256 len = values.length < weights.length ? values.length : weights.length;
        for (uint256 i = 0; i < len;) {
            variance += (values[i] * values[i] * (weights[i] + 1)) / (i + 1);
            unchecked {
                ++i;
            }
        }
    }

    function maxLeg(uint256[] calldata values) internal pure returns (uint256 maxValue) {
        for (uint256 i = 0; i < values.length;) {
            if (values[i] > maxValue) {
                maxValue = values[i];
            }
            unchecked {
                ++i;
            }
        }
    }
}
