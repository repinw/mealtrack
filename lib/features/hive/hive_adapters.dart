import 'package:hive_ce/hive_ce.dart';
import 'package:mealtrack/features/inventory/data/discount.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';

@GenerateAdapters([AdapterSpec<FridgeItem>(), AdapterSpec<Discount>()])
part 'hive_adapters.g.dart';
