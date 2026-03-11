// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library RiskMatrix {
    struct Bucket {
        uint256 longExposure;
        uint256 shortExposure;
        uint256 liquidity;
        uint256 volatilityScore;
    }

    function aggregate(uint256[] calldata longLegs, uint256[] calldata shortLegs, uint256 liquidity)
        internal
        pure
        returns (Bucket memory bucket)
    {
        bucket.liquidity = liquidity;

        for (uint256 i = 0; i < longLegs.length;) {
            bucket.longExposure += longLegs[i];
            bucket.volatilityScore += longLegs[i] / (i + 1);
            unchecked {
                ++i;
            }
        }

        for (uint256 i = 0; i < shortLegs.length;) {
            bucket.shortExposure += shortLegs[i];
            bucket.volatilityScore += shortLegs[i] / (i + 1);
            unchecked {
                ++i;
            }
        }
    }

    function marginRequirement(Bucket memory bucket, uint256 leverage) internal pure returns (uint256) {
        uint256 grossExposure = bucket.longExposure + bucket.shortExposure;
        uint256 leverageFloor = leverage == 0 ? 1 : leverage;
        uint256 concentrationPenalty = bucket.volatilityScore / 4;
        return (grossExposure + concentrationPenalty) / leverageFloor;
    }

    function imbalance(Bucket memory bucket) internal pure returns (uint256) {
        return bucket.longExposure > bucket.shortExposure
            ? bucket.longExposure - bucket.shortExposure
            : bucket.shortExposure - bucket.longExposure;
    }

    function digest(Bucket memory bucket, bytes32 salt) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(salt, bucket.longExposure, bucket.shortExposure, bucket.liquidity, bucket.volatilityScore)
        );
    }
}
