extension BitSet: Sequence {
  public typealias Element = UInt

  /// Returns the exact count of the bit set.
  ///
  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public var underestimatedCount: Int {
    count
  }

  /// Returns an iterator over bitset
  public func makeIterator() -> Iterator {
    Iterator(self)
  }

  /// Returns an array containing the results of mapping the given closure
  /// over the bitset's elements.
  ///
  /// - Parameter transform: A mapping closure. `transform` accepts an
  ///   element of this bitset as its parameter and returns a transformed
  ///   value of the same or of a different type.
  /// - Returns: An array containing the transformed elements of this
  ///   bitset.
  /// - Complexity: `O(size / w)` where `w` is the size of UInt
  @inlinable public func map<T>(
    _ transform: (Self.Element) throws -> T
  ) rethrows -> [T] {
    var result: [T] = []
    var iterator = makeIterator()
    while let element = iterator.next() {
      try result.append(transform(element))
    }
    return result
  }

  /// Returns an array containing, in order, the elements of the bitset
  /// that satisfy the given predicate.
  ///
  /// - Parameter isIncluded: A closure that takes an element of the
  ///   bitset as its argument and returns a Boolean value indicating
  ///   whether the element should be included in the returned array.
  /// - Returns: An array of the elements that `isIncluded` allowed.
  /// - Complexity: `O(size / w)` where `w` is the size of UInt
  @inlinable public func filter(
    _ isIncluded: (Self.Element) throws -> Bool
  ) rethrows -> [Self.Element] {
    var result: [Self.Element] = []
    var iterator = makeIterator()
    while let element = iterator.next() {
      if try isIncluded(element) {
        result.append(element)
      }
    }
    return result
  }

  /// Calls the given closure on each element in the bitset in the same order
  /// as a `for`-`in` loop.
  ///
  /// - Parameter body: A closure that takes an element of the bitset as a
  ///   parameter.
  /// - Complexity: `O(size / w)` where `w` is the size of UInt
  @inlinable public func forEach(
    _ body: (Self.Element) throws -> Void
  ) rethrows {
    var iterator = makeIterator()
    while let element = iterator.next() {
      try body(element)
    }
  }

  /// Returns a Boolean value indicating whether the bitset contains an
  /// element that satisfies the given predicate.
  ///
  /// - Parameter predicate: A closure that takes an element of the bitset
  ///   as its argument and returns a Boolean value that indicates whether
  ///   the passed element represents a match.
  /// - Returns: `true` if the bitset contains an element that satisfies
  ///   `predicate`; otherwise, `false`.
  /// - Complexity: `O(size / w)` where `w` is the size of UInt
  @inlinable public func contains(
    where predicate: (Self.Element) throws -> Bool
  ) rethrows -> Bool {
    var iterator = makeIterator()
    while let element = iterator.next() {
      if try predicate(element) {
        return true
      }
    }
    return false
  }

  /// Returns a Boolean value indicating whether every element of a bitset
  /// satisfies a given predicate.
  ///
  /// If the bitset is empty, this method returns `true`.
  ///
  /// - Parameter predicate: A closure that takes an element of the bitset
  ///   as its argument and returns a Boolean value that indicates whether
  ///   the passed element satisfies a condition.
  /// - Returns: `true` if the bitset contains only elements that satisfy
  ///   `predicate`; otherwise, `false`.
  /// - Complexity: `O(size / w)` where `w` is the size of UInt
  @inlinable public func allSatisfy(
    _ predicate: (Self.Element) throws -> Bool
  ) rethrows -> Bool {
    var iterator = makeIterator()
    while let element = iterator.next() {
      if try !predicate(element) {
        return false
      }
    }
    return true
  }

  /// Returns the minimum element in the bitset.
  ///
  /// - Returns: The bitset's minimum element. If the bitset has no
  ///   elements, returns `nil`.
  /// - Complexity: `O(size / w + count)` where `w` is the size of UInt,
  ///   `count` - bitset elements count
  @warn_unqualified_access
  @inlinable @inline(__always) public func min() -> Self.Element? {
    // TODO: Rewrite properly
    map { $0 }.min()
  }

  /// Returns the maximum element in the bitset.
  ///
  /// - Returns: The bitset's maximum element. If the bitset has no
  ///   elements, returns `nil`.
  /// - Complexity: `O(size / w + count)` where `w` is the size of UInt,
  ///   `count` - bitset elements count
  @warn_unqualified_access
  @inlinable @inline(__always) public func max() -> Self.Element? {
    // TODO: Rewrite properly
    map { $0 }.max()
  }
}

// MARK: Iterator

extension BitSet {
  public struct Iterator: IteratorProtocol {
    public typealias Element = BitSet.Element

    internal let bitset: BitSet
    internal var index: Int
    internal var current: UInt

    @usableFromInline
    internal init(_ bitset: BitSet) {
      self.bitset = bitset
      self.index = 0
      self.current = 0
    }

    /// Advances to the next element and returns it, or `nil` if no next element
    /// exists.
    ///
    /// Repeatedly calling this method returns, in order, all the elements of the
    /// underlying sequence. As soon as the sequence has run out of elements, all
    /// subsequent calls return `nil`.
    ///
    /// You must not call this method if any other copy of this iterator has been
    /// advanced with a call to its `next()` method.
    ///
    /// The following example shows how an iterator can be used explicitly to
    /// emulate a `for`-`in` loop. First, retrieve a sequence's iterator, and
    /// then call the iterator's `next()` method until it returns `nil`.
    ///
    /// - Returns: The next element in the underlying sequence, if a next element
    ///   exists; otherwise, `nil`.
    public mutating func next() -> UInt? {
      return bitset._read { blocks in
        while index < blocks.count {
          // skip block until we find non-empty one
          guard blocks[index].nonzeroBitCount != 0 else {
            index += 1
            continue
          }

          // If `blocks[index]` has bits (elements), but `current` doesn't have,
          // then need to update `current` with new block
          if current.nonzeroBitCount == 0 {
            current = blocks[index]
          }

          // Determine the position of the nearest bit in the block.
          // Invert such bits until their number becomes zero
          let bitPosition = bitset._blockMemoryLayoutSize - current.leadingZeroBitCount - 1
          current &= ~(1 << bitPosition)

          // When we have passed all the bits in the block, i.e. `current`
          // bits number is zero, then we move to the next block
          defer { if current.nonzeroBitCount == 0 { index += 1 } }
          return UInt(index * bitset._blockMemoryLayoutSize + bitPosition)
        }
        return nil
      }
    }
  }
}
