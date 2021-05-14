/// This function provides the implementation of the `protocol_version` waPC
/// guest function.
///
/// - Returns: the protocol version the policy supports
public func protocolVersionCallback(payload: String) -> String {
  return "\"v1\""
}
