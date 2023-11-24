extension BitSet {
  /// Inserts the given element in the set if it is not already present.
  ///
  /// - Parameter newMember: An element to insert into the set.
  /// - Complexity: `O(1)`
  @inlinable
  public mutating func insert(_ newMember: UInt64) {
    let index = index(for: newMember)
    let mask = mask(for: newMember)
    _update { blocks in blocks[index] |= mask }
  }

  /// Removes the specified element from the set.
  ///
  /// - Parameter newMember: An element of the set to remove.
  /// - Complexity: `O(1)`
  @inlinable
  public mutating func remove(_ newMember: UInt64) {
    let index = index(for: newMember)
    let mask = mask(for: newMember)
    _update { blocks in blocks[index] &= ~mask }
  }

  /// Returns a Boolean value that indicates whether the given value exists in the set.
  ///
  /// - Parameter newMember: An element to look for in the set.
  /// - Returns: `true` if `newMember` exists in the set, otherwise, `false`.
  /// - Complexity: `O(1)`
  @inlinable
  public func contains(_ newMember: UInt64) -> Bool {
    let index = index(for: newMember)
    let mask = mask(for: newMember)
    return _read { blocks in blocks[index] & mask != 0 }
  }

  /// A subscript operation for looking for or update members in the set.
  ///
  /// This is operation is a convenience shortcut for the `contains`, `insert`
  /// and `remove` operations.
  ///
  /// - Parameter newMember: Unsigned integer value to look for or update in the set.
  /// - Returns: `true` if the bit set contains `newMember`, `false` otherwise.
  /// - Complexity: `O(1)`
  @inlinable
  public subscript(_ newMember: UInt64) -> Bool {
    get { contains(newMember) }
    set { newValue ? insert(newMember) : remove(newMember) }
  }
}

extension BitSet {
  @usableFromInline
  internal func index(for value: UInt64) -> Int {
    return Int(value) / _blockMemoryLayoutSize
  }

  @usableFromInline
  internal func mask(for value: UInt64) -> UInt64 {
    let offset = value % UInt64(_blockMemoryLayoutSize)
    return 1 << offset
  }
}
