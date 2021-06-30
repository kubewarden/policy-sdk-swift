import Foundation
import GenericJSON
import Logging
import wapc

/**
  This struct implements a custom logging backend (aka `LogHandler`)
  for the [Swift-log](https://github.com/apple/swift-log) library.

  This is an example showing how to use this logging backend:
      
      import Logging
      import kubewardenSdk
      
      // This can be done once, like inside of the `main.swift` file
      // where all the waPC callbacks are registered
      LoggingSystem.bootstrap(PolicyLogHandler.init)
      
      let logger = Logger(label: "my-policy")
      logger.info("Hello World!")
      
      let name = "world"
      logger.info("hello \(name)")
      
      logger.info("Another message",
                  metadata: [
                    "foo": "bar",
                    "number": .stringConvertible(42),
                    "more-numbers": [.stringConvertible(1), .stringConvertible(2)],
                  ])
*/
public struct PolicyLogHandler: LogHandler {

    public init(label: String) {
        self.label = label
    }

    public let label: String

    public var logLevel: Logger.Level = .info

    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    file: String, function: String, line: UInt) {
      var entry: [String: JSON] = [:]

      entry["level"] = try! JSON.init("\(level)")
      entry["message"] = {
        if let msg = try? JSON.init("\(message)") {
          return msg
        } else {
          return try! JSON.init("cannot convert message")
        }
      }()
      entry["file"] = try! JSON.init(file)
      entry["function"] = try! JSON.init(function)
      entry["line"] = try! JSON.init(line)

      if metadata != nil {
        for (k,v) in metadata! {
          entry[k] = {
            if let jv = try? JSON.init(convertMetadataValue(value: v)) {
              return jv
            } else {
              return try! JSON.init("cannot convert value of \(k) to JSON")
            }
          }()
        }
      }

      let encoder = JSONEncoder()
      let data = try! encoder.encode(entry)
      if let event = String(data: data, encoding: .utf8) {
        _ = wapc.hostCall(
          binding: "kubewarden",
          namespace: "tracing",
          operation: "log",
          payload: event
        )
      }
    }

    public var metadata = Logger.Metadata()

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }
}

func convertMetadataValue(value: Logger.MetadataValue) -> Any {
  switch value {
  case .string(let value):
    return value
  case .stringConvertible(let value):
    if let _ = try? JSON.init(value) {
      return value
    } else {
      return value.description
    }
  case .array(let value):
    return value.map { convertMetadataValue(value: $0) }
  case .dictionary(let value):
    return value.mapValues { convertMetadataValue(value: $0) }
  }
}
