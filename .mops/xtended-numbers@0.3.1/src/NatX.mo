import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Util "./Util";
import Prelude "mo:base/Prelude";

module {

  public type Format = { #binary; #decimal; #hexadecimal };

  /// Converts text representation of a decimal natural number to a Nat.
  ///
  /// ```motoko
  /// let result = NatX.fromText("123");
  /// switch (result) {
  ///   case (null) { /* Invalid input */ };
  ///   case (?value) { /* value is 123 */ };
  /// };
  /// ```
  public func fromText(value : Text) : ?Nat {
    fromTextAdvanced(value, #decimal, null);
  };

  /// Converts text representation of a natural number in a specified format to a Nat.
  ///
  /// ```motoko
  /// let result = NatX.fromTextAdvanced("1010", #binary, null);
  /// switch (result) {
  ///   case (null) { /* Invalid input */ };
  ///   case (?value) { /* value is 10 */ };
  /// };
  /// ```
  public func fromTextAdvanced(value : Text, format : Format, seperator : ?Char) : ?Nat {
    if (value == "") {
      return null;
    };

    let maxCharScalarValue = switch (format) {
      case (#binary) 1;
      case (#decimal) 9;
      case (#hexadecimal) 15;
    };
    let baseScalar = switch (format) {
      case (#binary) 2;
      case (#decimal) 10;
      case (#hexadecimal) 16;
    };

    var nat : Nat = 0;
    label f for (c in value.chars()) {
      let charScalarValue = switch (c) {
        case ('0') 0;
        case ('1') 1;
        case ('2') 2;
        case ('3') 3;
        case ('4') 4;
        case ('5') 5;
        case ('6') 6;
        case ('7') 7;
        case ('8') 8;
        case ('9') 9;

        // TODO toLower?
        case ('a') 10;
        case ('A') 10;

        case ('b') 11;
        case ('B') 11;

        case ('c') 12;
        case ('C') 12;

        case ('d') 13;
        case ('D') 13;

        case ('e') 14;
        case ('E') 14;

        case ('f') 15;
        case ('F') 15;
        case (c) {
          if (?c == seperator) {
            continue f; // Skip seperator
          };
          return null;
        };
      };
      if (charScalarValue > maxCharScalarValue) {
        // Invalid character such as 'A' being in
        return null;
      };
      // Shift scalar over to left by 1 (multiple by base)
      // then add current digit
      nat := (nat * baseScalar) + charScalarValue;
    };
    ?nat;
  };

  /// Converts a Nat to its decimal text representation.
  ///
  /// ```motoko
  /// let text = NatX.toText(123);
  /// // text is "123"
  /// ```
  public func toText(value : Nat) : Text {
    toTextAdvanced(value, #decimal);
  };

  /// Converts a Nat to its text representation in a specified format.
  ///
  /// ```motoko
  /// let text = NatX.toTextAdvanced(10, #binary);
  /// // text is "1010"
  /// ```
  public func toTextAdvanced(value : Nat, format : Format) : Text {
    if (value == 0) {
      return "0";
    };

    let baseScalar = switch (format) {
      case (#binary) 2;
      case (#decimal) 10;
      case (#hexadecimal) 16;
    };

    var buffer = Buffer.Buffer<Char>(5);
    var remainingValue = value;
    while (remainingValue > 0) {
      let charScalarValue = remainingValue % baseScalar; // Get last digit
      let c = switch (charScalarValue) {
        case (0) '0';
        case (1) '1';
        case (2) '2';
        case (3) '3';
        case (4) '4';
        case (5) '5';
        case (6) '6';
        case (7) '7';
        case (8) '8';
        case (9) '9';

        case (10) 'A';
        case (11) 'B';
        case (12) 'C';
        case (13) 'D';
        case (14) 'E';
        case (15) 'F';
        case (_) Prelude.unreachable();
      };
      buffer.add(c);
      remainingValue := remainingValue / baseScalar; // Remove last digit
    };
    Buffer.reverse(buffer); // Reverse because digits are from least to most significant
    Text.fromIter(buffer.vals());
  };

  /// Converts Nat64 to Nat8. Traps on overflow.
  ///
  /// ```motoko
  /// let value : Nat64 = 255;
  /// let result : Nat8 = NatX.from64To8(value);
  /// // result is 255
  /// ```
  public func from64To8(value : Nat64) : Nat8 {
    Nat8.fromNat(Nat64.toNat(value));
  };

  /// Converts Nat64 to Nat16. Traps on overflow.
  ///
  /// ```motoko
  /// let value : Nat64 = 65535;
  /// let result : Nat16 = NatX.from64To16(value);
  /// // result is 65535
  /// ```
  public func from64To16(value : Nat64) : Nat16 {
    Nat16.fromNat(Nat64.toNat(value));
  };

  /// Converts Nat64 to Nat32. Traps on overflow.
  ///
  /// ```motoko
  /// let value : Nat64 = 4294967295;
  /// let result : Nat32 = NatX.from64To32(value);
  /// // result is 4294967295
  /// ```
  public func from64To32(value : Nat64) : Nat32 {
    Nat32.fromNat(Nat64.toNat(value));
  };

  /// Converts Nat64 to Nat.
  ///
  /// ```motoko
  /// let value : Nat64 = 18446744073709551615;
  /// let result : Nat = NatX.from64ToNat(value);
  /// // result is 18446744073709551615
  /// ```
  public func from64ToNat(value : Nat64) : Nat {
    Nat64.toNat(value);
  };

  /// Converts Nat32 to Nat8. Traps on overflow.
  ///
  /// ```motoko
  /// let value : Nat32 = 255;
  /// let result : Nat8 = NatX.from32To8(value);
  /// // result is 255
  /// ```
  public func from32To8(value : Nat32) : Nat8 {
    Nat8.fromNat(Nat32.toNat(value));
  };

  /// Converts Nat32 to Nat16. Traps on overflow.
  ///
  /// ```motoko
  /// let value : Nat32 = 65535;
  /// let result : Nat16 = NatX.from32To16(value);
  /// // result is 65535
  /// ```
  public func from32To16(value : Nat32) : Nat16 {
    Nat16.fromNat(Nat32.toNat(value));
  };

  /// Converts Nat32 to Nat64.
  ///
  /// ```motoko
  /// let value : Nat32 = 4294967295;
  /// let result : Nat64 = NatX.from32To64(value);
  /// // result is 4294967295
  /// ```
  public func from32To64(value : Nat32) : Nat64 {
    Nat64.fromNat(Nat32.toNat(value));
  };

  /// Converts Nat32 to Nat.
  ///
  /// ```motoko
  /// let value : Nat32 = 4294967295;
  /// let result : Nat = NatX.from32ToNat(value);
  /// // result is 4294967295
  /// ```
  public func from32ToNat(value : Nat32) : Nat {
    Nat32.toNat(value);
  };

  /// Converts Nat16 to Nat8. Traps on overflow.
  ///
  /// ```motoko
  /// let value : Nat16 = 255;
  /// let result : Nat8 = NatX.from16To8(value);
  /// // result is 255
  /// ```
  public func from16To8(value : Nat16) : Nat8 {
    Nat8.fromNat(Nat16.toNat(value));
  };

  /// Converts Nat16 to Nat32.
  ///
  /// ```motoko
  /// let value : Nat16 = 65535;
  /// let result : Nat32 = NatX.from16To32(value);
  /// // result is 65535
  /// ```
  public func from16To32(value : Nat16) : Nat32 {
    Nat32.fromNat(Nat16.toNat(value));
  };

  /// Converts Nat16 to Nat64.
  ///
  /// ```motoko
  /// let value : Nat16 = 65535;
  /// let result : Nat64 = NatX.from16To64(value);
  /// // result is 65535
  /// ```
  public func from16To64(value : Nat16) : Nat64 {
    Nat64.fromNat(Nat16.toNat(value));
  };

  /// Converts Nat16 to Nat.
  ///
  /// ```motoko
  /// let value : Nat16 = 65535;
  /// let result : Nat = NatX.from16ToNat(value);
  /// // result is 65535
  /// ```
  public func from16ToNat(value : Nat16) : Nat {
    Nat16.toNat(value);
  };

  /// Converts Nat8 to Nat16.
  ///
  /// ```motoko
  /// let value : Nat8 = 255;
  /// let result : Nat16 = NatX.from8To16(value);
  /// // result is 255
  /// ```
  public func from8To16(value : Nat8) : Nat16 {
    Nat16.fromNat(Nat8.toNat(value));
  };

  /// Converts Nat8 to Nat32.
  ///
  /// ```motoko
  /// let value : Nat8 = 255;
  /// let result : Nat32 = NatX.from8To32(value);
  /// // result is 255
  /// ```
  public func from8To32(value : Nat8) : Nat32 {
    Nat32.fromNat(Nat8.toNat(value));
  };

  /// Converts Nat8 to Nat64.
  ///
  /// ```motoko
  /// let value : Nat8 = 255;
  /// let result : Nat64 = NatX.from8To64(value);
  /// // result is 255
  /// ```
  public func from8To64(value : Nat8) : Nat64 {
    Nat64.fromNat(Nat8.toNat(value));
  };

  /// Converts Nat8 to Nat.
  ///
  /// ```motoko
  /// let value : Nat8 = 255;
  /// let result : Nat = NatX.from8ToNat(value);
  /// // result is 255
  /// ```
  public func from8ToNat(value : Nat8) : Nat {
    Nat8.toNat(value);
  };

  /// Encodes a Nat to a byte buffer using unsigned LEB128 encoding.
  ///
  /// ```motoko
  /// let buffer = Buffer.Buffer<Nat8>(8);
  /// NatX.encodeNat(buffer, 123, #unsignedLEB128);
  /// // buffer now contains the encoded bytes
  /// ```
  public func encodeNat(buffer : Buffer.Buffer<Nat8>, value : Nat, encoding : { #unsignedLEB128 }) {
    switch (encoding) {
      case (#unsignedLEB128) {
        if (value == 0) {
          buffer.add(0);
          return;
        };
        // Unsigned LEB128 - https://en.wikipedia.org/wiki/LEB128#Unsigned_LEB128
        //       10011000011101100101  In raw binary
        //      010011000011101100101  Padded to a multiple of 7 bits
        //  0100110  0001110  1100101  Split into 7-bit groups
        // 00100110 10001110 11100101  Add high 1 bits on all but last (most significant) group to form bytes
        let bits : [Bool] = Util.natToLeastSignificantBits(value, 7, false);

        Util.invariableLengthBytesEncode(buffer, bits);
      };
    };
  };

  /// Encodes a Nat8 to a byte buffer.
  ///
  /// ```motoko
  /// let buffer = Buffer.Buffer<Nat8>(1);
  /// NatX.encodeNat8(buffer, 123);
  /// // buffer now contains the encoded byte
  /// ```
  public func encodeNat8(buffer : Buffer.Buffer<Nat8>, value : Nat8) {
    buffer.add(value);
  };

  /// Encodes a Nat16 to a byte buffer.
  ///
  /// ```motoko
  /// let buffer = Buffer.Buffer<Nat8>(2);
  /// NatX.encodeNat16(buffer, 12345, #lsb);
  /// // buffer now contains the encoded bytes
  /// ```
  public func encodeNat16(buffer : Buffer.Buffer<Nat8>, value : Nat16, encoding : { #lsb; #msb }) {
    encodeNatX(buffer, Nat64.fromNat(Nat16.toNat(value)), encoding, #b16);
  };

  /// Encodes a Nat32 to a byte buffer.
  ///
  /// ```motoko
  /// let buffer = Buffer.Buffer<Nat8>(4);
  /// NatX.encodeNat32(buffer, 1234567890, #lsb);
  /// // buffer now contains the encoded bytes
  /// ```
  public func encodeNat32(buffer : Buffer.Buffer<Nat8>, value : Nat32, encoding : { #lsb; #msb }) {
    encodeNatX(buffer, Nat64.fromNat(Nat32.toNat(value)), encoding, #b32);
  };

  /// Encodes a Nat64 to a byte buffer.
  ///
  /// ```motoko
  /// let buffer = Buffer.Buffer<Nat8>(8);
  /// NatX.encodeNat64(buffer, 1234567890123456789, #lsb);
  /// // buffer now contains the encoded bytes
  /// ```
  public func encodeNat64(buffer : Buffer.Buffer<Nat8>, value : Nat64, encoding : { #lsb; #msb }) {
    encodeNatX(buffer, value, encoding, #b64);
  };

  /// Decodes a Nat from a byte iterator using unsigned LEB128 encoding.
  ///
  /// ```motoko
  /// let bytes : [Nat8] = [0xE5, 0x8E, 0x26]; // 624485 in unsigned LEB128
  /// let result = NatX.decodeNat(bytes.vals(), #unsignedLEB128);
  /// switch (result) {
  ///   case (null) { /* Decoding error */ };
  ///   case (?value) { /* value is 624485 */ };
  /// };
  /// ```
  public func decodeNat(bytes : Iter.Iter<Nat8>, _ : { #unsignedLEB128 }) : ?Nat {
    do ? {
      var v : Nat = 0;
      var i : Nat = 0;
      label l loop {
        let byte : Nat8 = bytes.next()!;
        v += Nat8.toNat(byte & 0x7f) * Nat.pow(2, 7 * i); // Shift over 7 * i bits to get value to add, ignore first bit
        i += 1;
        let hasNextByte = (byte & 0x80) == 0x80; // If starts with a 1, there is another byte
        if (not hasNextByte) {
          break l;
        };
      };
      v;
    };
  };

  /// Decodes a Nat8 from a byte iterator.
  ///
  /// ```motoko
  /// let bytes : [Nat8] = [123];
  /// let result = NatX.decodeNat8(bytes.vals(), #lsb);
  /// switch (result) {
  ///   case (null) { /* Decoding error */ };
  ///   case (?value) { /* value is 123 */ };
  /// };
  /// ```
  public func decodeNat8(bytes : Iter.Iter<Nat8>, _ : { #lsb; #msb }) : ?Nat8 {
    bytes.next();
  };

  /// Decodes a Nat16 from a byte iterator.
  ///
  /// ```motoko
  /// let bytes : [Nat8] = [0x39, 0x30]; // 12345 in little-endian
  /// let result = NatX.decodeNat16(bytes.vals(), #lsb);
  /// switch (result) {
  ///   case (null) { /* Decoding error */ };
  ///   case (?value) { /* value is 12345 */ };
  /// };
  /// ```
  public func decodeNat16(bytes : Iter.Iter<Nat8>, encoding : { #lsb; #msb }) : ?Nat16 {
    do ? {
      let value : Nat64 = decodeNatX(bytes, encoding, #b16)!;
      from64To16(value);
    };
  };

  /// Decodes a Nat32 from a byte iterator.
  ///
  /// ```motoko
  /// let bytes : [Nat8] = [0xD2, 0x02, 0x96, 0x49]; // 1234567890 in little-endian
  /// let result = NatX.decodeNat32(bytes.vals(), #lsb);
  /// switch (result) {
  ///   case (null) { /* Decoding error */ };
  ///   case (?value) { /* value is 1234567890 */ };
  /// };
  /// ```
  public func decodeNat32(bytes : Iter.Iter<Nat8>, encoding : { #lsb; #msb }) : ?Nat32 {
    do ? {
      let value : Nat64 = decodeNatX(bytes, encoding, #b32)!;
      from64To32(value);
    };
  };

  /// Decodes a Nat64 from a byte iterator.
  ///
  /// ```motoko
  /// let bytes : [Nat8] = [0x15, 0x81, 0xE9, 0x7D, 0xF4, 0x10, 0x22, 0x11]; // 1234567890123456789 in little-endian
  /// let result = NatX.decodeNat64(bytes.vals(), #lsb);
  /// switch (result) {
  ///   case (null) { /* Decoding error */ };
  ///   case (?value) { /* value is 1234567890123456789 */ };
  /// };
  /// ```
  public func decodeNat64(bytes : Iter.Iter<Nat8>, encoding : { #lsb; #msb }) : ?Nat64 {
    decodeNatX(bytes, encoding, #b64);
  };

  private func decodeNatX(bytes : Iter.Iter<Nat8>, encoding : { #lsb; #msb }, size : { #b16; #b32; #b64 }) : ?Nat64 {
    do ? {
      let byteLength : Nat64 = getByteLength(size);
      var nat64 : Nat64 = 0;
      for (i in Iter.range(0, Nat64.toNat(byteLength) - 1)) {
        let b = from8To64(bytes.next()!);
        let byteOffset : Nat64 = switch (encoding) {
          case (#lsb) Nat64.fromNat(i);
          case (#msb) Nat64.fromNat(Nat64.toNat(byteLength -1) - i);
        };
        nat64 |= b << (byteOffset * 8);
      };
      nat64;
    };
  };

  private func encodeNatX(buffer : Buffer.Buffer<Nat8>, value : Nat64, encoding : { #lsb; #msb }, size : { #b16; #b32; #b64 }) {
    let byteLength : Nat64 = getByteLength(size);
    for (i in Iter.range(0, Nat64.toNat(byteLength) - 1)) {
      let byteOffset : Nat64 = switch (encoding) {
        case (#lsb) Nat64.fromNat(i);
        case (#msb) Nat64.fromNat(Nat64.toNat(byteLength -1) - i);
      };
      let byte : Nat8 = from64To8((value >> (byteOffset * 8)) & 0xff);
      buffer.add(byte);
    };
  };

  private func getByteLength(size : { #b16; #b32; #b64 }) : Nat64 {
    switch (size) {
      case (#b16) 2;
      case (#b32) 4;
      case (#b64) 8;
    };
  };
};
