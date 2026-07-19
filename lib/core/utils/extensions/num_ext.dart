import 'package:intl/intl.dart';

extension NumExt on num {
  String toNaira([int decimalDigits = 0]) {
    final format = NumberFormat.currency(
      name: 'NGN',
      symbol: '₦',
      decimalDigits: decimalDigits,
    );
    return format.format(this);
  }
}
