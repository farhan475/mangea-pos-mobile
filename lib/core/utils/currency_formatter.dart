/// Format angka menjadi string Rupiah, mis. 125000 -> "Rp125.000".
String formatRupiah(num amount) {
  final digits = amount.round().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final positionFromEnd = digits.length - i;
    buffer.write(digits[i]);
    final isThousandBoundary = positionFromEnd > 1 && positionFromEnd % 3 == 1;
    if (isThousandBoundary) buffer.write('.');
  }

  return 'Rp$buffer';
}
