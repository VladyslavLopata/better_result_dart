/// Used instead of `void` as a return statement for a function
/// when no value is to be returned.
///
/// There is only one value of type [Unit].
final class Unit {
  const Unit._instance();

  static const Unit _unit = Unit._instance();

  @override
  String toString() => '()';
}

/// Used instead of `void` as a return statement for a function when
///  no value is to be returned.
const unit = Unit._unit;
