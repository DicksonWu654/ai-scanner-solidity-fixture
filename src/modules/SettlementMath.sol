// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library SettlementMath {
    struct Window {
        uint256 grossOut;
        uint256 netOut;
        uint256 feeAmount;
        uint256 reserveRatio;
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
}
