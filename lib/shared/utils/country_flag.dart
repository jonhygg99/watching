/// Returns the emoji flag for a given ISO country code.
String countryFlag(String code) => String.fromCharCodes(
  code.toUpperCase().codeUnits.map((c) => 0x1F1E6 - 65 + c),
);
