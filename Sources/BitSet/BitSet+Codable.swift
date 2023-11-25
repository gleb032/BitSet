extension BitSet: Codable {
  /// Encodes the elements of this bitset into the given encoder in an unkeyed container.
  ///
  /// This function throws an error if any values are invalid for the given
  /// encoder's format.
  ///
  /// - Parameter encoder: The encoder to write data to.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(_blocks)
  }

  /// Creates a new bitset by decoding from the given decoder.
  ///
  /// This initializer throws an error if reading from the decoder fails,
  /// or if the data read is corrupted or otherwise invalid.
  ///
  /// - Parameter decoder: The decoder to read data from.
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    _blocks = []
    var _size = 0
    while container.isAtEnd {
      let block = try container.decode(UInt.self)
      _blocks.append(block)
      _size = max(_size, Int(block))
    }
    size = _size
  }
}
