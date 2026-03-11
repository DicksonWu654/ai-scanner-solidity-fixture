// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library RiskMatrix {
    struct Bucket {
        uint256 longExposure;
        uint256 shortExposure;
        uint256 liquidity;
        uint256 volatilityScore;
    }

    struct LanePressure {
        uint256 laneId;
        uint256 grossExposure;
        uint256 netExposure;
        uint256 margin;
        uint256 skew;
    }

    struct ReserveBand {
        uint256 floor;
        uint256 target;
        uint256 ceiling;
        uint256 saturation;
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

    function lanePressure(Bucket memory bucket, uint256 laneId, uint256 leverage)
        internal
        pure
        returns (LanePressure memory pressure)
    {
        uint256 margin = marginRequirement(bucket, leverage);
        uint256 netExposure = bucket.longExposure > bucket.shortExposure
            ? bucket.longExposure - bucket.shortExposure
            : bucket.shortExposure - bucket.longExposure;

        pressure = LanePressure({
            laneId: laneId,
            grossExposure: bucket.longExposure + bucket.shortExposure,
            netExposure: netExposure,
            margin: margin,
            skew: imbalance(bucket)
        });
    }

    function reserveBand(Bucket memory bucket) internal pure returns (ReserveBand memory band_) {
        uint256 grossExposure = bucket.longExposure + bucket.shortExposure;
        uint256 target = grossExposure / 5;
        band_ = ReserveBand({
            floor: target / 2,
            target: target,
            ceiling: target * 2,
            saturation: bucket.liquidity == 0 ? 0 : (grossExposure * 1e18) / bucket.liquidity
        });
    }

    function correlate(uint256[] calldata longLegs, uint256[] calldata shortLegs)
        internal
        pure
        returns (uint256 score)
    {
        uint256 len = longLegs.length < shortLegs.length ? longLegs.length : shortLegs.length;
        for (uint256 i = 0; i < len;) {
            score += (longLegs[i] * shortLegs[i]) / (i + 1);
            unchecked {
                ++i;
            }
        }
    }

    function shockScore(Bucket memory bucket, uint256 basisPoints) internal pure returns (uint256) {
        return ((bucket.longExposure + bucket.shortExposure + bucket.volatilityScore) * basisPoints) / 10_000;
    }

    function rebalanceVector(Bucket memory bucket) internal pure returns (int256) {
        if (bucket.longExposure >= bucket.shortExposure) {
            return int256(bucket.longExposure - bucket.shortExposure);
        }
        return -int256(bucket.shortExposure - bucket.longExposure);
    }

    function liquidityGap(Bucket memory bucket, uint256 targetLiquidity) internal pure returns (uint256) {
        return targetLiquidity > bucket.liquidity ? targetLiquidity - bucket.liquidity : 0;
    }
}
