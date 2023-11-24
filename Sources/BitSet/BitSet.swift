public struct BitSet {

  public let size: Int
  public var count: Int {
    @inlinable get {
      _read { blocks in
        blocks.reduce(0) { accum, block in
          accum + block.nonzeroBitCount
        }
      }
    }
  }

  @usableFromInline
  internal var _blocks: [UInt64]
  internal let _blockMemoryLayoutSize = MemoryLayout<UInt64>.size * 8

  public init(size: Int) {
    self.size = size

    let blocksCount = (size + _blockMemoryLayoutSize - 1) / _blockMemoryLayoutSize
    self._blocks = [UInt64](repeating: 0, count: blocksCount)

    _check()
  }
}

extension BitSet {
  @inlinable @inline(__always)
  @discardableResult
  internal func _read<Return>(
    _ body: (UnsafeBufferPointer<UInt64>) throws -> Return
  ) rethrows -> Return {
    try _blocks.withUnsafeBufferPointer { block in
      try body(block)
    }
  }

  @inlinable @inline(__always)
  internal mutating func _update(
    _ body: (inout UnsafeMutableBufferPointer<UInt64>) throws -> Void
  ) rethrows -> Void {
    try _blocks.withUnsafeMutableBufferPointer { block in
      try body(&block)
    }
  }

  @inline(__always)
  internal func _check() {
    precondition(size <= UInt64.max)
  }
}
