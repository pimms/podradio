import Foundation

extension String {
    var stableHash: UInt64 {
        var result = UInt64(5381)
        let buf = [UInt8](utf8)
        for b in buf {
            result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
        }
        return result
    }
}
