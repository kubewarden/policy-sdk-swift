import Foundation

/// Errors raised when policy's settings validation fails
public enum SettingsValidationError: Error {
  /// Raised when the policy validation fails
  ///
  /// - Parameter message: the message to show to the end user
  case validationFailure(message: String)
}

/// Protocol that must be implemented by Kubewarden policies
/// in order to be used by `SettingsValidator`
public protocol Validatable {

  /// Function that validates the policy settings
  ///
  /// - Returns: nothing when the settings are valid
  /// - Throws: `SettingsValidationError` when the settings are not valid
  func validate() throws
  var debugDescription: String { get }
}

/// Helper structure that performs settings validation
///
/// This can be used inside of your policy `main.swift` file
/// to simplify the registration of the `validate_settings` guest function:
///
///     let settingsValidator = SettingsValidator<MyPolicySettings>()
///     wapc.registerFunction(name: "validate_settings", fn: settingsValidator.validate)
///
/// - Parameter S: Your policy settings class
public struct SettingsValidator<S: Validatable & Codable> {

  public init() {}

  /// This method instantiates the generic settings class defined at construction
  /// time using the provided payload. Then it invokes the `validate()` method
  /// provided by it and build a `SettingsValidationResponse` object
  ///
  /// - Parameter payload: A JSON dictionary holding the settings
  /// - Returns: A `SettingsValidationResponse` serialized to JSON
  public func validate(payload: String) -> String {
    let settings: S
    do {
      settings = try JSONDecoder().decode( S.self, from: Data(payload.utf8))
    } catch let DecodingError.dataCorrupted(context) {
        return rejectSettings(message: "Data corrupted: \(context)")
    } catch let DecodingError.keyNotFound(key, context) {
        return rejectSettings(
          message: "Key '\(key)' not found: '\(context.debugDescription)' - codingPath: '\(context.codingPath)'")
    } catch let DecodingError.valueNotFound(value, context) {
        return rejectSettings(
          message: "Value '\(value)' not found: '\(context.debugDescription)' - codingPath: '\(context.codingPath)'")
    } catch let DecodingError.typeMismatch(type, context)  {
        return rejectSettings(
          message: "Type '\(type)' mismatch: '\(context.debugDescription)' - codingPath: '\(context.codingPath)'")
    } catch {
        return rejectSettings(message: "Unknown error: \(error)")
    }

    do {
      try settings.validate()
    } catch let SettingsValidationError.validationFailure(message) {
      return rejectSettings(message: message)
    } catch {
      return rejectSettings(message: "Unknown error: \(error)")
    }

    return acceptSettings()
  }

}

/// This structure defines the response to provide
/// when validating settings.
public struct SettingsValidationResponse : Codable {
  let valid: Bool
  let message: String?
}

/// This function accepts the Settings as valid
///
/// - Returns: A `SettingsValidationResponse` object serialized to JSON
public func acceptSettings() -> String {
  let response = SettingsValidationResponse(
    valid: true,
    message: nil)

  let encoder = JSONEncoder()
  let data = try! encoder.encode(response)

  return String(data: data, encoding: .utf8)!
}

/// This function rejects the Settings as invalid
///
/// - Parameter message: the message to provide to the user to explain the validation failure
/// - Returns: A `SettingsValidationResponse` object serialized to JSON
public func rejectSettings(message: String?) -> String {
  let response = SettingsValidationResponse(
    valid: false,
    message: message)

  let encoder = JSONEncoder()
  let data = try! encoder.encode(response)

  return String(data: data, encoding: .utf8)!
}
