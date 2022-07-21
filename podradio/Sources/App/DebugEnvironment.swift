//
//  IsRunningPreviews.swift
//  podradio
//
//  Created by Joakim Stien on 13/07/2022.
//

import Foundation

func isRunningPreviews() -> Bool {
    let val = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
    return val == "1"
}

func isRunningOnSimulator() -> Bool {
#if targetEnvironment(simulator)
    return true
#else
    if isRunningPreviews() {
        return true
    }

    return false
#endif
}
