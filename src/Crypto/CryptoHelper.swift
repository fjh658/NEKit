import Foundation

public struct CryptoHelper {
    public static let infoDictionary: [CryptoAlgorithm:(Int, Int)] = [
        .AES128CFB: (16, 16),
        .AES192CFB: (24, 16),
        .AES256CFB: (32, 16),
        .CHACHA20: (32, 8),
        .SALSA20: (32, 8),
        .RC4MD5: (16, 16)
        ]

    public static func getKeyLength(methodType: CryptoAlgorithm) -> Int {
        return infoDictionary[methodType]!.0
    }

    public static func getIVLength(methodType: CryptoAlgorithm) -> Int {
        return infoDictionary[methodType]!.1
    }

    public static func getIV(methodType: CryptoAlgorithm) -> NSData {
        let IV = NSMutableData(length: getIVLength(methodType))!
        SecRandomCopyBytes(kSecRandomDefault, IV.length, UnsafeMutablePointer<UInt8>(IV.mutableBytes))
        return IV
    }

    public static func getKey(password: String, methodType: CryptoAlgorithm) -> NSData {
        let result = NSMutableData(length: getIVLength(methodType) + getKeyLength(methodType))!
        let passwordData = password.dataUsingEncoding(NSUTF8StringEncoding)!
        var md5result = MD5Hash.final(password)
        let extendPasswordData = NSMutableData(length: passwordData.length + md5result.length)!
        passwordData.getBytes(extendPasswordData.mutableBytes + md5result.length, length: passwordData.length)
        var length = 0
        repeat {
            let copyLength = min(result.length - length, md5result.length)
            md5result.getBytes(result.mutableBytes + length, length: copyLength)
            extendPasswordData.replaceBytesInRange(NSRange(location: 0, length: md5result.length), withBytes: md5result.bytes)
            md5result = MD5Hash.final(extendPasswordData)
            length += copyLength
        } while length < result.length
        return result.subdataWithRange(NSRange(location: 0, length: getKeyLength(methodType)))
    }
}
