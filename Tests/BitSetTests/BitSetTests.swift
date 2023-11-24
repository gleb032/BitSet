import XCTest
@testable import BitSet

final class BitSetTests: XCTestCase {

  private var bitset: BitSet!

  override func setUp() {
    bitset = BitSet(size: 100)
  }

  override func tearDown() {
    bitset = nil
  }

  func testInsertSingle() throws {
    bitset.insert(12)
    (UInt64(0)...100).forEach {
      if $0 == 12 {
        assert(bitset.contains($0))
      } else {
        assert(!bitset.contains($0))
      }
    }
  }

  func testInsertSeveral() throws {
    let arr: [UInt64] = [1, 5, 20, 40, 77]
    arr.forEach {
      bitset.insert($0)
    }
    (UInt64(0)...100).forEach {
      if arr.contains($0) {
        assert(bitset.contains($0))
      } else {
        assert(!bitset.contains($0))
      }
    }
  }

  func testEqualWithSameSize() throws {
    var bitset1 = BitSet(size: 10)
    var bitset2 = BitSet(size: 10)
    assert(bitset1 == bitset2)

    bitset1.insert(1)
    assert(bitset1 != bitset2)

    bitset2.insert(1)
    assert(bitset1 == bitset2)
  }

  func testNotEqualWithSameSize() throws {
    var bitset1 = BitSet(size: 10)
    var bitset2 = BitSet(size: 11)
    assert(bitset1 != bitset2)

    bitset1.insert(1)
    assert(bitset1 != bitset2)
  }

  
}
