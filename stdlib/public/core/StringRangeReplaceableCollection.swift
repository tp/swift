//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

extension String : StringProtocol, RangeReplaceableCollection {
  /// A type that represents the number of steps between two `String.Index`
  /// values, where one value is reachable from the other.
  ///
  /// In Swift, *reachability* refers to the ability to produce one value from
  /// the other through zero or more applications of `index(after:)`.
  public typealias IndexDistance = Int

  public typealias SubSequence = Substring

  /// Creates a string representing the given character repeated the specified
  /// number of times.
  ///
  /// For example, use this initializer to create a string with ten `"0"`
  /// characters in a row.
  ///
  ///     let zeroes = String(repeating: "0" as Character, count: 10)
  ///     print(zeroes)
  ///     // Prints "0000000000"
  ///
  /// - Parameters:
  ///   - repeatedValue: The character to repeat.
  ///   - count: The number of times to repeat `repeatedValue` in the
  ///     resulting string.
  @_inlineable // FIXME(sil-serialize-all)
  public init(repeating repeatedValue: Character, count: Int) {
    self.init(repeating: String(repeatedValue), count: count)
  }

  // This initializer disambiguates between the following intitializers, now
  // that String conforms to Collection:
  // - init<T>(_ value: T) where T : LosslessStringConvertible
  // - init<S>(_ characters: S) where S : Sequence, S.Element == Character

  /// Creates a new string containing the characters in the given sequence.
  ///
  /// You can use this initializer to create a new string from the result of
  /// one or more collection operations on a string's characters. For example:
  ///
  ///     let str = "The rain in Spain stays mainly in the plain."
  ///
  ///     let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
  ///     let disemvoweled = String(str.lazy.filter { !vowels.contains($0) })
  ///
  ///     print(disemvoweled)
  ///     // Prints "Th rn n Spn stys mnly n th pln."
  ///
  /// - Parameter other: A string instance or another sequence of
  ///   characters.
  @_inlineable // FIXME(sil-serialize-all)
  public init<S : Sequence & LosslessStringConvertible>(_ other: S)
  where S.Element == Character {
    self = other.description
  }

  // The defaulted argument prevents this initializer from satisfies the
  // LosslessStringConvertible conformance.  You can satisfy a protocol
  // requirement with something that's not yet available, but not with
  // something that has become unavailable. Without this, the code won't
  // compile as Swift 4.
  @_inlineable // FIXME(sil-serialize-all)
  @available(swift, obsoleted: 4, message: "String.init(_:String) is no longer failable")
  public init?(_ other: String, obsoletedInSwift4: () = ()) {
    self.init(other._guts)
  }

  /// The position of the first character in a nonempty string.
  ///
  /// In an empty string, `startIndex` is equal to `endIndex`.
  @_inlineable // FIXME(sil-serialize-all)
  public var startIndex: Index { return Index(encodedOffset: 0) }

  /// A string's "past the end" position---that is, the position one greater
  /// than the last valid subscript argument.
  ///
  /// In an empty string, `endIndex` is equal to `startIndex`.
  @_inlineable // FIXME(sil-serialize-all)
  public var endIndex: Index { return Index(encodedOffset: _guts.count) }

  @_inlineable
  @_versioned
  @inline(__always)
  internal func _boundsCheck(_ index: Index) {
    _precondition(index.encodedOffset >= 0 && index.encodedOffset < _guts.count,
      "String index is out of bounds")
  }

  @_inlineable
  @_versioned
  @inline(__always)
  internal func _boundsCheck(_ range: Range<Index>) {
    _precondition(
      range.lowerBound.encodedOffset >= 0 &&
      range.upperBound.encodedOffset <= _guts.count,
      "String index range is out of bounds")
  }

  @_inlineable
  @_versioned
  @inline(__always)
  internal func _boundsCheck(_ range: ClosedRange<Index>) {
    _precondition(
      range.lowerBound.encodedOffset >= 0 &&
      range.upperBound.encodedOffset < _guts.count,
      "String index range is out of bounds")
  }

  @_inlineable // FIXME(sil-serialize-all)
  @_versioned // FIXME(sil-serialize-all)
  internal func _index(atEncodedOffset offset: Int) -> Index {
    if _slowPath(_guts._isOpaque) {
      return _opaqueIndex(atEncodedOffset: offset)
    }

    defer { _fixLifetime(self) }
    if _guts.isASCII {
      return _guts._unmanagedASCIIView.characterIndex(atOffset: offset)
    } else {
      return _guts._unmanagedUTF16View.characterIndex(atOffset: offset)
    }
  }

  @_versioned // @opaque
  func _opaqueIndex(atEncodedOffset offset: Int) -> Index {
    _sanityCheck(_guts._isOpaque)
    defer { _fixLifetime(self) }
    return _guts._asOpaque().characterIndex(atOffset: offset)
  }

  /// Returns the position immediately after the given index.
  ///
  /// - Parameter i: A valid index of the collection. `i` must be less than
  ///   `endIndex`.
  /// - Returns: The index value immediately after `i`.
  @_inlineable // FIXME(sil-serialize-all)
  public func index(after i: Index) -> Index {
    if _slowPath(_guts._isOpaque) {
      return _opaqueIndex(after: i)
    }

    defer { _fixLifetime(self) }
    if _guts.isASCII {
      return _guts._unmanagedASCIIView.characterIndex(after: i)
    } else {
      return _guts._unmanagedUTF16View.characterIndex(after: i)
    }
  }

  @_versioned // @opaque
  func _opaqueIndex(after i: Index) -> Index {
    _sanityCheck(_guts._isOpaque)
    defer { _fixLifetime(self) }
    return _guts._asOpaque().characterIndex(after: i)
  }

  /// Returns the position immediately before the given index.
  ///
  /// - Parameter i: A valid index of the collection. `i` must be greater than
  ///   `startIndex`.
  /// - Returns: The index value immediately before `i`.
  @_inlineable // FIXME(sil-serialize-all)
  public func index(before i: Index) -> Index {
    if _slowPath(_guts._isOpaque) {
      return _opaqueIndex(before: i)
    }

    defer { _fixLifetime(self) }
    if _guts.isASCII {
      return _guts._unmanagedASCIIView.characterIndex(before: i)
    } else {
      return _guts._unmanagedUTF16View.characterIndex(before: i)
    }
  }

  @_versioned // @opaque
  func _opaqueIndex(before i: Index) -> Index {
    _sanityCheck(_guts._isOpaque)
    defer { _fixLifetime(self) }
    return _guts._asOpaque().characterIndex(before: i)
  }

  /// Returns an index that is the specified distance from the given index.
  ///
  /// The following example obtains an index advanced four positions from a
  /// string's starting index and then prints the character at that position.
  ///
  ///     let s = "Swift"
  ///     let i = s.index(s.startIndex, offsetBy: 4)
  ///     print(s[i])
  ///     // Prints "t"
  ///
  /// The value passed as `n` must not offset `i` beyond the bounds of the
  /// collection.
  ///
  /// - Parameters:
  ///   - i: A valid index of the collection.
  ///   - n: The distance to offset `i`.
  /// - Returns: An index offset by `n` from the index `i`. If `n` is positive,
  ///   this is the same value as the result of `n` calls to `index(after:)`.
  ///   If `n` is negative, this is the same value as the result of `-n` calls
  ///   to `index(before:)`.
  ///
  /// - Complexity: O(*n*), where *n* is the absolute value of `n`.
  @_inlineable // FIXME(sil-serialize-all)
  public func index(_ i: Index, offsetBy n: IndexDistance) -> Index {
    if _slowPath(_guts._isOpaque) {
      return _opaqueIndex(i, offsetBy: n)
    }

    defer { _fixLifetime(self) }
    if _guts.isASCII {
      return _guts._unmanagedASCIIView.characterIndex(i, offsetBy: n)
    } else {
      return _guts._unmanagedUTF16View.characterIndex(i, offsetBy: n)
    }
  }

  @_versioned // @opaque
  func _opaqueIndex(_ i: Index, offsetBy n: IndexDistance) -> Index {
    _sanityCheck(_guts._isOpaque)
    defer { _fixLifetime(self) }
    return _guts._asOpaque().characterIndex(i, offsetBy: n)
  }

  /// Returns an index that is the specified distance from the given index,
  /// unless that distance is beyond a given limiting index.
  ///
  /// The following example obtains an index advanced four positions from a
  /// string's starting index and then prints the character at that position.
  /// The operation doesn't require going beyond the limiting `s.endIndex`
  /// value, so it succeeds.
  ///
  ///     let s = "Swift"
  ///     if let i = s.index(s.startIndex, offsetBy: 4, limitedBy: s.endIndex) {
  ///         print(s[i])
  ///     }
  ///     // Prints "t"
  ///
  /// The next example attempts to retrieve an index six positions from
  /// `s.startIndex` but fails, because that distance is beyond the index
  /// passed as `limit`.
  ///
  ///     let j = s.index(s.startIndex, offsetBy: 6, limitedBy: s.endIndex)
  ///     print(j)
  ///     // Prints "nil"
  ///
  /// The value passed as `n` must not offset `i` beyond the bounds of the
  /// collection, unless the index passed as `limit` prevents offsetting
  /// beyond those bounds.
  ///
  /// - Parameters:
  ///   - i: A valid index of the collection.
  ///   - n: The distance to offset `i`.
  ///   - limit: A valid index of the collection to use as a limit. If `n > 0`,
  ///     a limit that is less than `i` has no effect. Likewise, if `n < 0`, a
  ///     limit that is greater than `i` has no effect.
  /// - Returns: An index offset by `n` from the index `i`, unless that index
  ///   would be beyond `limit` in the direction of movement. In that case,
  ///   the method returns `nil`.
  ///
  /// - Complexity: O(*n*), where *n* is the absolute value of `n`.
  @_inlineable // FIXME(sil-serialize-all)
  public func index(
    _ i: Index, offsetBy n: IndexDistance, limitedBy limit: Index
  ) -> Index? {
    if _slowPath(_guts._isOpaque) {
      return _opaqueIndex(i, offsetBy: n, limitedBy: limit)
    }

    defer { _fixLifetime(self) }
    if _guts.isASCII {
      return _guts._unmanagedASCIIView.characterIndex(
        i, offsetBy: n, limitedBy: limit)
    } else {
      return _guts._unmanagedUTF16View.characterIndex(
        i, offsetBy: n, limitedBy: limit)
    }
  }

  @_versioned // @opaque
  func _opaqueIndex(
    _ i: Index, offsetBy n: IndexDistance, limitedBy limit: Index
  ) -> Index? {
    _sanityCheck(_guts._isOpaque)
    defer { _fixLifetime(self) }
    return _guts._asOpaque().characterIndex(i, offsetBy: n, limitedBy: limit)
  }

  /// Returns the distance between two indices.
  ///
  /// - Parameters:
  ///   - start: A valid index of the collection.
  ///   - end: Another valid index of the collection. If `end` is equal to
  ///     `start`, the result is zero.
  /// - Returns: The distance between `start` and `end`.
  ///
  /// - Complexity: O(*n*), where *n* is the resulting distance.
  @_inlineable // FIXME(sil-serialize-all)
  public func distance(from start: Index, to end: Index) -> IndexDistance {
    if _slowPath(_guts._isOpaque) {
      return _opaqueDistance(from: start, to: end)
    }

    defer { _fixLifetime(self) }
    if _guts.isASCII {
      return _guts._unmanagedASCIIView.characterDistance(from: start, to: end)
    } else {
      return _guts._unmanagedUTF16View.characterDistance(from: start, to: end)
    }
  }

  @_versioned // @opaque
  func _opaqueDistance(from start: Index, to end: Index) -> IndexDistance {
    _sanityCheck(_guts._isOpaque)
    defer { _fixLifetime(self) }
    return _guts._asOpaque().characterDistance(from: start, to: end)
  }

  /// Accesses the character at the given position.
  ///
  /// You can use the same indices for subscripting a string and its substring.
  /// For example, this code finds the first letter after the first space:
  ///
  ///     let str = "Greetings, friend! How are you?"
  ///     let firstSpace = str.index(of: " ") ?? str.endIndex
  ///     let substr = str[firstSpace...]
  ///     if let nextCapital = substr.index(where: { $0 >= "A" && $0 <= "Z" }) {
  ///         print("Capital after a space: \(str[nextCapital])")
  ///     }
  ///     // Prints "Capital after a space: H"
  ///
  /// - Parameter i: A valid index of the string. `i` must be less than the
  ///   string's end index.
  @_inlineable // FIXME(sil-serialize-all)
  public subscript(i: Index) -> Character {
    if _slowPath(_guts._isOpaque) {
      return _opaqueSubscript(i)
    }

    defer { _fixLifetime(self) }
    if _guts.isASCII {
      return _guts._unmanagedASCIIView.character(at: i)
    } else {
      return _guts._unmanagedUTF16View.character(at: i)
    }
  }

  @_versioned // @opaque
  func _opaqueSubscript(_ i: Index) -> Character {
    _sanityCheck(_guts._isOpaque)
    defer { _fixLifetime(self) }
    return _guts._asOpaque().character(at: i)
  }
}

extension String {
  /// Creates a new string containing the characters in the given sequence.
  ///
  /// You can use this initializer to create a new string from the result of
  /// one or more collection operations on a string's characters. For example:
  ///
  ///     let str = "The rain in Spain stays mainly in the plain."
  ///
  ///     let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
  ///     let disemvoweled = String(str.lazy.filter { !vowels.contains($0) })
  ///
  ///     print(disemvoweled)
  ///     // Prints "Th rn n Spn stys mnly n th pln."
  ///
  /// - Parameter characters: A string instance or another sequence of
  ///   characters.
  @_inlineable // FIXME(sil-serialize-all)
  public init<S : Sequence>(_ characters: S)
    where S.Iterator.Element == Character {
    self = ""
    self.append(contentsOf: characters)
  }

  /// Reserves enough space in the string's underlying storage to store the
  /// specified number of ASCII characters.
  ///
  /// Because each character in a string can require more than a single ASCII
  /// character's worth of storage, additional allocation may be necessary
  /// when adding characters to a string after a call to
  /// `reserveCapacity(_:)`.
  ///
  /// - Parameter n: The minimum number of ASCII character's worth of storage
  ///   to allocate.
  ///
  /// - Complexity: O(*n*)
  @_inlineable // FIXME(sil-serialize-all)
  public mutating func reserveCapacity(_ n: Int) {
    _guts.reserveCapacity(n)
  }

  /// Appends the given character to the string.
  ///
  /// The following example adds an emoji globe to the end of a string.
  ///
  ///     var globe = "Globe "
  ///     globe.append("🌍")
  ///     print(globe)
  ///     // Prints "Globe 🌍"
  ///
  /// - Parameter c: The character to append to the string.
  @_inlineable // FIXME(sil-serialize-all)
  public mutating func append(_ c: Character) {
    if let small = c._smallUTF16 {
      _guts.append(contentsOf: small)
    } else {
      _guts.append(c._largeUTF16!.unmanagedView)
      _fixLifetime(c)
    }
  }

  @_inlineable // FIXME(sil-serialize-all)
  public mutating func append(contentsOf newElements: String) {
    append(newElements)
  }

  @_inlineable // FIXME(sil-serialize-all)
  public mutating func append(contentsOf newElements: Substring) {
    _guts.append(
      newElements._wholeString._guts,
      range: newElements._encodedOffsetRange)
  }

  /// Appends the characters in the given sequence to the string.
  ///
  /// - Parameter newElements: A sequence of characters.
  @_inlineable // FIXME(sil-serialize-all)
  public mutating func append<S : Sequence>(contentsOf newElements: S)
    where S.Iterator.Element == Character {
    if _fastPath(newElements is _SwiftStringView) {
      let v = newElements as! _SwiftStringView
      _guts.append(v._wholeString._guts, range: v._encodedOffsetRange)
      return
    }
    _guts.reserveUnusedCapacity(
      newElements.underestimatedCount,
      ascii: _guts.isASCII)
    for c in newElements { self.append(c) }
  }

  /// Replaces the text within the specified bounds with the given characters.
  ///
  /// Calling this method invalidates any existing indices for use with this
  /// string.
  ///
  /// - Parameters:
  ///   - bounds: The range of text to replace. The bounds of the range must be
  ///     valid indices of the string.
  ///   - newElements: The new characters to add to the string.
  ///
  /// - Complexity: O(*m*), where *m* is the combined length of the string and
  ///   `newElements`. If the call to `replaceSubrange(_:with:)` simply
  ///   removes text at the end of the string, the complexity is O(*n*), where
  ///   *n* is equal to `bounds.count`.
  @_inlineable // FIXME(sil-serialize-all)
  public mutating func replaceSubrange<C>(
    _ bounds: Range<Index>,
    with newElements: C
  ) where C : Collection, C.Iterator.Element == Character {
    let offsetRange: Range<Int> =
      bounds.lowerBound.encodedOffset ..< bounds.upperBound.encodedOffset
    let lazyUTF16 = newElements.lazy.flatMap { $0.utf16 }
    _guts.replaceSubrange(offsetRange, with: lazyUTF16)
  }

  /// Inserts a new character at the specified position.
  ///
  /// Calling this method invalidates any existing indices for use with this
  /// string.
  ///
  /// - Parameters:
  ///   - newElement: The new character to insert into the string.
  ///   - i: A valid index of the string. If `i` is equal to the string's end
  ///     index, this methods appends `newElement` to the string.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the string.
  @_inlineable // FIXME(sil-serialize-all)
  public mutating func insert(_ newElement: Character, at i: Index) {
    let offset = i.encodedOffset
    _guts.replaceSubrange(offset..<offset, with: newElement.utf16)
  }

  /// Inserts a collection of characters at the specified position.
  ///
  /// Calling this method invalidates any existing indices for use with this
  /// string.
  ///
  /// - Parameters:
  ///   - newElements: A collection of `Character` elements to insert into the
  ///     string.
  ///   - i: A valid index of the string. If `i` is equal to the string's end
  ///     index, this methods appends the contents of `newElements` to the
  ///     string.
  ///
  /// - Complexity: O(*n*), where *n* is the combined length of the string and
  ///   `newElements`.
  @_inlineable // FIXME(sil-serialize-all)
  public mutating func insert<S : Collection>(
    contentsOf newElements: S, at i: Index
  ) where S.Iterator.Element == Character {
    let offset = i.encodedOffset
    let utf16 = newElements.lazy.flatMap { $0.utf16 }
    _guts.replaceSubrange(offset..<offset, with: utf16)
  }

  /// Removes and returns the character at the specified position.
  ///
  /// All the elements following `i` are moved to close the gap. This example
  /// removes the hyphen from the middle of a string.
  ///
  ///     var nonempty = "non-empty"
  ///     if let i = nonempty.index(of: "-") {
  ///         nonempty.remove(at: i)
  ///     }
  ///     print(nonempty)
  ///     // Prints "nonempty"
  ///
  /// Calling this method invalidates any existing indices for use with this
  /// string.
  ///
  /// - Parameter i: The position of the character to remove. `i` must be a
  ///   valid index of the string that is not equal to the string's end index.
  /// - Returns: The character that was removed.
  @_inlineable // FIXME(sil-serialize-all)
  @discardableResult
  public mutating func remove(at i: Index) -> Character {
    let offset = i.encodedOffset
    let stride = _stride(of: i)
    let range: Range<Int> = offset ..< offset + stride
    let old = Character(_unverified: _guts, range: range)
    _guts.replaceSubrange(range, with: EmptyCollection())
    return old
  }

  @_inlineable // FIXME(sil-serialize-all)
  @_versioned // FIXME(sil-serialize-all)
  internal func _stride(of i: Index) -> Int {
    if case .character(let stride) = i._cache {
      // TODO: should _fastPath the case somehow
      _sanityCheck(stride > 0)
      return Int(stride)
    }
    if _slowPath(_guts._isOpaque) {
      return _opaqueStride(of: i)
    }

    let offset = i.encodedOffset
    defer { _fixLifetime(self) }
    if _guts.isASCII {
      return _guts._unmanagedASCIIView.characterStride(atOffset: offset)
    } else {
      return _guts._unmanagedUTF16View.characterStride(atOffset: offset)
    }
  }

  @_versioned // @opaque
  func _opaqueStride(of i: Index) -> Int {
    _sanityCheck(_guts._isOpaque)
    defer { _fixLifetime(self) }
    let offset = i.encodedOffset
    return _guts._asOpaque().characterStride(atOffset: offset)
  }

  /// Removes the characters in the given range.
  ///
  /// Calling this method invalidates any existing indices for use with this
  /// string.
  ///
  /// - Parameter bounds: The range of the elements to remove. The upper and
  ///   lower bounds of `bounds` must be valid indices of the string and not
  ///   equal to the string's end index.
  /// - Parameter bounds: The range of the elements to remove. The upper and
  ///   lower bounds of `bounds` must be valid indices of the string.
  @_inlineable // FIXME(sil-serialize-all)
  public mutating func removeSubrange(_ bounds: Range<Index>) {
    let start = bounds.lowerBound.encodedOffset
    let end = bounds.upperBound.encodedOffset
    _guts.replaceSubrange(start..<end, with: EmptyCollection())
  }

  /// Replaces this string with the empty string.
  ///
  /// Calling this method invalidates any existing indices for use with this
  /// string.
  ///
  /// - Parameter keepCapacity: Pass `true` to prevent the release of the
  ///   string's allocated storage. Retaining the storage can be a useful
  ///   optimization when you're planning to grow the string again. The
  ///   default value is `false`.
  @_inlineable // FIXME(sil-serialize-all)
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    if keepCapacity {
      _guts.replaceSubrange(0..<_guts.count, with: EmptyCollection())
    } else {
      _guts = _StringGuts()
    }
  }
}

extension String {
  // This is needed because of the issue described in SR-4660 which causes
  // source compatibility issues when String becomes a collection
  @_inlineable // FIXME(sil-serialize-all)
  @_transparent
  public func max<T : Comparable>(_ x: T, _ y: T) -> T {
    return Swift.max(x,y)
  }

  // This is needed because of the issue described in SR-4660 which causes
  // source compatibility issues when String becomes a collection
  @_inlineable // FIXME(sil-serialize-all)
  @_transparent
  public func min<T : Comparable>(_ x: T, _ y: T) -> T {
    return Swift.min(x,y)
  }
}

//===----------------------------------------------------------------------===//
// The following overloads of flatMap are carefully crafted to allow the code
// like the following:
//   ["hello"].flatMap { $0 }
// return an array of strings without any type context in Swift 3 mode, at the
// same time allowing the following code snippet to compile:
//   [0, 1].flatMap { x in
//     if String(x) == "foo" { return "bar" } else { return nil }
//   }
// Note that the second overload is declared on a more specific protocol.
// See: test/stdlib/StringFlatMap.swift for tests.
extension Sequence {
  @_inlineable // FIXME(sil-serialize-all)
  @available(swift, obsoleted: 4)
  public func flatMap(
    _ transform: (Element) throws -> String
  ) rethrows -> [String] {
    return try map(transform)
  }
}

extension Collection {
  @available(swift, deprecated: 4.1, renamed: "compactMap(_:)",
    message: "Please use compactMap(_:) for the case where closure returns an optional value")
  @inline(__always)
  public func flatMap(
    _ transform: (Element) throws -> String?
  ) rethrows -> [String] {
    return try _compactMap(transform)
  }
}
//===----------------------------------------------------------------------===//

extension Sequence where Element == String {
  @available(*, unavailable, message: "Operator '+' cannot be used to append a String to a sequence of strings")
  public static func + (lhs: Self, rhs: String) -> Never {
    fatalError()
  }

  @available(*, unavailable, message: "Operator '+' cannot be used to append a String to a sequence of strings")
  public static func + (lhs: String, rhs: Self) -> Never {
    fatalError()
  }
}
