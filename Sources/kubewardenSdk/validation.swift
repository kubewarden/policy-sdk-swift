import Foundation

/// Describes the ValidationRequest object given to the policy
/// inside of the `validate` guest function.
///
/// This structure can be used to quickly deserialize the
/// policy settings from the validation request using `JSONDecoder`.
///
/// - Important: The actual validation request object has to be extracted
///   manually. It's not possible to deserialize a dynamic JSON hash yet
///   with Swift 5. This will be possible once
///   [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) can build
///   using SwiftWasm
public struct ValidationRequest<S: Validatable & Codable > : Codable {
  public let settings: S
}

/// This structure defines the response to provide
/// when validating an admission request.
public struct ValidationResponse : Codable {
  let accepted: Bool
  let message: String?
  let code: Int?
}

/// This function accepts the admission request as valid
///
/// - Returns: A `ValidationResponse` object serialized to JSON
public func acceptRequest() -> String {
  let response = ValidationResponse(
    accepted: true,
    message: nil,
    code: nil)

  let encoder = JSONEncoder()
  let data = try! encoder.encode(response)

  return String(data: data, encoding: .utf8)!
}

/// This function rejects the admission request as invalid
///
/// - Parameter message: the optional message to provide to the user
/// - Parameter code: the optional code identifying the rejection
/// - Returns: A `ValidationResponse` object serialized to JSON
public func rejectRequest(message: String?, code: Int?) -> String {
  let response = ValidationResponse(
    accepted: false,
    message: message,
    code: code)

  let encoder = JSONEncoder()
  let data = try! encoder.encode(response)

  return String(data: data, encoding: .utf8)!
}
