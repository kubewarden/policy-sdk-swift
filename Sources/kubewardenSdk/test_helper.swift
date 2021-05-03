import GenericJSON
import Foundation

/// Helper function to be used while writing unit tests
///
///    let reservedRuntimes: Set<String> = ["runC"]
///    let settings = Settings(
///      reservedRuntimes: reservedRuntimes,
///      defaultRuntimeReserved: true,
///      fallbackRuntime: "kata")
///    let validation_payload = make_validate_payload(
///      request: PodRequestWithoutRuntime,
///      settings: settings)
///
///    let response_payload = validate(payload: validation_payload)
///
///  - Parameter s: Your policy settings class
///  - Parameter request: A string that holds the JSON request
///  - Returns: A String holding the validation payload to give to the `validate` function
public func make_validate_payload<S: Validatable & Codable>(request: String, settings: S) -> String {
  let reqData = request.data(using: .utf8)!
  let reqJSONObj = try! JSONSerialization.jsonObject(with: reqData, options: [])
  let reqDict = reqJSONObj as! [String: Any]

  let payload: JSON = [
    "settings": try! JSON(encodable: settings),
    "request": try! JSON.init(reqDict),
  ]

  let encoder = JSONEncoder()
  encoder.keyEncodingStrategy = .convertToSnakeCase
  let data = try! encoder.encode(payload)

  return String(data: data, encoding: .utf8)!
}
