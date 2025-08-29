import 'package:intl/intl.dart';

class CurrencyUtils {
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(double amount) {
    try {
      return _formatter.format(amount);
    } catch (e) {
      return 'Rp ${amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
    }
  }

  static String formatWithDecimal(double amount) {
    try {
      final formatter = NumberFormat.currency(
        symbol: 'Rp ',
        decimalDigits: 2,
      );
      return formatter.format(amount);
    } catch (e) {
      return 'Rp ${amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
    }
  }
}

class DateUtils {
  static final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy');

  static String formatDate(DateTime date) {
    try {
      return _dateFormat.format(date);
    } catch (e) {
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
