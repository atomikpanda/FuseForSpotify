//
//  Array+Batch.swift
//  Fuse
//
//  Created by Bailey Seymour on 10/30/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import Foundation

extension Array {
    /// Splits an array into batches or chunks
    func batches(by chunkSize: Int) -> [[Element]] {
        var batches = [[Element]]()

        // Find out how many batches we need and append
        for _ in 0 ..< Int(ceil(Double(count) / Double(chunkSize))) {
            batches.append([])
        }

        var batchIdx = 0
        for (i, item) in enumerated() {
            // Determine when we should start adding the items to the next batch
            if i % chunkSize == 0 && i != 0 {
                batchIdx += 1
            }
            batches[batchIdx].append(item)
        }

        return batches
    }
}
