extension BitSet: CustomStringConvertible {
  /// A textual representation of this instance.
  public var description: String {
    var _description = "BitSet["
    _read { blocks in
      for (index, block) in blocks.enumerated() {
        debugPrint(block, terminator: "", to: &_description)
        if index < blocks.count - 1 {
          _description += ","
        }
      }
    }
    return _description + "]"
  }
}
