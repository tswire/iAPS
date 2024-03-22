import Foundation

protocol ExponentialSmoothable {
    var value: Double { get set }
    var timestamp: Date { get set }
}

private class IsSmoothable: ExponentialSmoothable {
    var value: Double = 0.0
    var timestamp = Date()

    init(withValue value: Double = 0.0, timestamp: Date = Date()) {
        self.value = value
        self.timestamp = timestamp
    }
}

/**
 *  TSUNAMI DATA SMOOTHING CORE from AAPS
 *
 *  Calculated a weighted average of 1st and 2nd order exponential smoothing functions
 *  to reduce the effect of sensor noise on APS performance. The weighted average
 *  is a compromise between the fast response to changing BGs at the cost of smoothness
 *  as offered by 1st order exponential smoothing, and the predictive, trend-sensitive but
 *  slower-to-respond smoothing as offered by 2nd order functions.
 *
 */

extension Array where Element: ExponentialSmoothable {
    mutating func applyExponentialSmoothing() {
        // Ensure the array is sorted by timestamp in ascending order for correct processing
        sort(by: { $0.timestamp < $1.timestamp })

        let sizeRecords = count
        var o1_sBG: [Double] = [] // 1st order Smoothed Glucose
        var o2_sBG: [Double] = [] // 2nd order Smoothed Glucose
        var o2_sD: [Double] = [] // 2nd order Smoothed Deltas
        var ssBG: [Double] = [] // Weighted averaged, doubly smoothed Glucose

        // Smoothing factors and weights, as provided
        var windowSize = sizeRecords
        let o1_weight = 0.4
        let o1_a = 0.5
        let o2_a = 0.4
        let o2_b = 1.0

        var insufficientSmoothingData = false

        // Adjust window size based on the validity of readings and specific conditions
        if sizeRecords <= windowSize {
            windowSize = Swift.max(sizeRecords - 1, 0) // Adjust for at least one older value as a buffer
        }

        // Further adjust if a gap > 12 mins is detected or if any reading is 38 mg/dL (error state)
        for i in 0 ..< windowSize {
            if i + 1 < sizeRecords && self[i].timestamp.timeIntervalSince(self[i + 1].timestamp) >= 12 * 60 ||
                self[i].value == 38.0
            {
                windowSize = i + (self[i].value == 38.0 ? 0 : 1)
                break
            }
        }

        // Check if there's sufficient data after adjustments
        if windowSize >= 4 {
            // Initialize smoothing with the oldest valid data point
            o1_sBG.append(self[sizeRecords - windowSize].value)
            o2_sBG.append(self[sizeRecords - windowSize].value)
            o2_sD.append(0) // Start with a delta of 0 for 2nd order

            // Apply smoothing calculations
            for i in 1 ..< windowSize {
                let index = sizeRecords - windowSize + i
                o1_sBG.append(o1_a * self[index].value + (1 - o1_a) * o1_sBG.last!)
                o2_sBG.append(o2_a * self[index].value + (1 - o2_a) * (o2_sBG.last! + o2_sD.last!))
                o2_sD.append(o2_b * (o2_sBG.last! - o2_sBG[o2_sBG.count - 2]) + (1 - o2_b) * o2_sD.last!)
            }

            // Calculate weighted averages for doubly smoothed values
            for i in 0 ..< o1_sBG.count {
                ssBG.append(o1_weight * o1_sBG[i] + (1 - o1_weight) * o2_sBG[i])
            }

            // Update only the 10 most recent values in the original data array
            let startUpdateIndex = Swift.max(0, sizeRecords - 10)
            for i in startUpdateIndex ..< sizeRecords {
                let ssBGIndex = i - (sizeRecords - ssBG.count)
                if ssBGIndex >= 0, ssBGIndex < ssBG.count {
                    self[i].value = Swift.max(ssBG[ssBGIndex], 39.0)
                    // Assuming a method to update .trendArrow or similar property if applicable
                }
            }
        } else {
            for i in 0 ..< windowSize {
                if i + 1 < sizeRecords && self[i].timestamp.timeIntervalSince(self[i + 1].timestamp) >= 12 * 60 ||
                    self[i].value == 38.0
                {
                    windowSize = i + (self[i].value == 38.0 ? 0 : 1)
                    break
                }
            }
        }
    }
}
