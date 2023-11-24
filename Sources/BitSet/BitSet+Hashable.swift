extension BitSet: Hashable {
  /// Hashes the essential components of this value by feeding them
  /// into the given hasher.
  ///
  /// - Complexity: `O(size / w)` where `w` is the size of UInt
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_blocks)
    hasher.combine(size)
  }
}
