import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  await initializeDateFormatting('id_ID', null);

  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(now);
  print(formattedDate);
}
