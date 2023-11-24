extension BitSet: Equatable {
  /// Returns a Boolean value indicating whether two values are equal. Two
  /// bit sets are considered equal if they contain the same elements
  /// and have the same size
  ///
  /// - Complexity: `O(size / w)` where `w` is the size of UInt
  public static func == (lhs: BitSet, rhs: BitSet) -> Bool {
    lhs.size == rhs.size && lhs._blocks == rhs._blocks
  }
}
