import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/calories/data/off_product_cache_repository.dart';
import 'package:mealtrack/features/calories/domain/off_product_candidate.dart';
import 'package:mealtrack/features/calories/domain/nutrition_per100.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

final openFoodFactsService = Provider<OpenFoodFactsService>((ref) {
  final cache = ref.watch(offProductCacheRepository);
  return OpenFoodFactsService(cacheRepository: cache);
});

class OpenFoodFactsException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const OpenFoodFactsException(this.message, {this.statusCode, this.cause});

  @override
  String toString() {
    if (statusCode != null) {
      return 'OpenFoodFactsException($statusCode): $message';
    }
    return 'OpenFoodFactsException: $message';
  }
}

class OpenFoodFactsService {
  final OffProductCacheRepository? _cacheRepository;
  final Future<List<OffProductCandidate>> Function(String barcode)?
  _searchByCodeOverride;
  final Future<OffProductCandidate?> Function(String barcode)?
  _fetchSingleProductOverride;

  static const List<ProductField> _fields = [
    ProductField.BARCODE,
    ProductField.NAME,
    ProductField.GENERIC_NAME,
    ProductField.BRANDS,
    ProductField.QUANTITY,
    ProductField.SERVING_SIZE,
    ProductField.IMAGE_FRONT_SMALL_URL,
    ProductField.IMAGE_FRONT_URL,
    ProductField.NUTRIMENTS,
  ];

  OpenFoodFactsService({
    OffProductCacheRepository? cacheRepository,
    Future<List<OffProductCandidate>> Function(String barcode)?
    searchByCodeOverride,
    Future<OffProductCandidate?> Function(String barcode)?
    fetchSingleProductOverride,
  }) : _cacheRepository = cacheRepository,
       _searchByCodeOverride = searchByCodeOverride,
       _fetchSingleProductOverride = fetchSingleProductOverride {
    _ensureApiConfigured();
  }

  Future<List<OffProductCandidate>> lookupByBarcode(String barcode) async {
    final normalizedBarcode = _normalizeBarcode(barcode);
    if (normalizedBarcode.isEmpty) return const <OffProductCandidate>[];

    try {
      final cached = await _readFromCache(normalizedBarcode);
      if (cached.isNotEmpty) {
        return _sortAndDedupe(cached);
      }

      final searchProducts = await _searchByCode(normalizedBarcode);
      List<OffProductCandidate> resolved;
      if (searchProducts.isNotEmpty) {
        resolved = _sortAndDedupe(searchProducts);
      } else {
        final product = await _fetchSingleProduct(normalizedBarcode);
        if (product == null) return const <OffProductCandidate>[];
        resolved = <OffProductCandidate>[product];
      }

      await _writeToCache(barcode: normalizedBarcode, candidates: resolved);
      return resolved;
    } on OpenFoodFactsException {
      rethrow;
    } catch (e) {
      throw OpenFoodFactsException('Open Food Facts lookup failed', cause: e);
    }
  }

  Future<List<OffProductCandidate>> _readFromCache(String barcode) async {
    final cacheRepository = _cacheRepository;
    if (cacheRepository == null) return const <OffProductCandidate>[];

    try {
      return await cacheRepository.getByBarcode(barcode) ??
          const <OffProductCandidate>[];
    } catch (_) {
      return const <OffProductCandidate>[];
    }
  }

  Future<void> _writeToCache({
    required String barcode,
    required List<OffProductCandidate> candidates,
  }) async {
    final cacheRepository = _cacheRepository;
    if (cacheRepository == null || candidates.isEmpty) return;

    try {
      await cacheRepository.saveByBarcode(barcode, candidates);
    } catch (_) {
      // Cache write failures must not break lookup flow.
    }
  }

  Future<List<OffProductCandidate>> _searchByCode(String barcode) async {
    final override = _searchByCodeOverride;
    if (override != null) {
      return override(barcode);
    }

    final configuration = ProductSearchQueryConfiguration(
      parametersList: [BarcodeParameter(barcode), const PageSize(size: 20)],
      language: OpenFoodFactsLanguage.GERMAN,
      fields: _fields,
      version: ProductQueryVersion.v3,
    );

    final result = await OpenFoodAPIClient.searchProducts(null, configuration);
    final products = result.products ?? const <Product>[];
    return products.map(_toCandidate).whereType<OffProductCandidate>().toList();
  }

  Future<OffProductCandidate?> _fetchSingleProduct(String barcode) async {
    final override = _fetchSingleProductOverride;
    if (override != null) {
      return override(barcode);
    }

    final configuration = ProductQueryConfiguration(
      barcode,
      language: OpenFoodFactsLanguage.GERMAN,
      fields: _fields,
      version: ProductQueryVersion.v3,
    );

    final result = await OpenFoodAPIClient.getProductV3(configuration);
    final status = result.status;
    if (status != ProductResultV3.statusSuccess &&
        status != ProductResultV3.statusWarning) {
      return null;
    }

    final product = result.product;
    if (product == null) return null;
    return _toCandidate(product);
  }

  List<OffProductCandidate> _sortAndDedupe(List<OffProductCandidate> input) {
    final byCode = <String, OffProductCandidate>{};
    for (final item in input) {
      final existing = byCode[item.code];
      if (existing == null ||
          item.completenessScore > existing.completenessScore) {
        byCode[item.code] = item;
      }
    }

    final sorted = byCode.values.toList()
      ..sort((a, b) {
        final scoreDiff = b.completenessScore.compareTo(a.completenessScore);
        if (scoreDiff != 0) return scoreDiff;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return sorted;
  }

  static String _normalizeBarcode(String raw) {
    return raw.trim().replaceAll(RegExp(r'[^0-9]'), '');
  }

  OffProductCandidate? _toCandidate(Product product) {
    final code = (product.barcode ?? '').trim();
    if (code.isEmpty) return null;

    final kcal = _readKcalPer100(product.nutriments);
    final protein = product.nutriments?.getValue(
      Nutrient.proteins,
      PerSize.oneHundredGrams,
    );
    final carbs = product.nutriments?.getValue(
      Nutrient.carbohydrates,
      PerSize.oneHundredGrams,
    );
    final fat = product.nutriments?.getValue(
      Nutrient.fat,
      PerSize.oneHundredGrams,
    );
    final sugar = product.nutriments?.getValue(
      Nutrient.sugars,
      PerSize.oneHundredGrams,
    );
    final salt = product.nutriments?.getValue(
      Nutrient.salt,
      PerSize.oneHundredGrams,
    );
    final saturatedFat = product.nutriments?.getValue(
      Nutrient.saturatedFat,
      PerSize.oneHundredGrams,
    );
    final polyunsaturatedFat = product.nutriments?.getValue(
      Nutrient.polyunsaturatedFat,
      PerSize.oneHundredGrams,
    );
    final fiber = product.nutriments?.getValue(
      Nutrient.fiber,
      PerSize.oneHundredGrams,
    );

    final hasKcal = kcal != null;
    final hasProtein = protein != null;
    final hasCarbs = carbs != null;
    final hasFat = fat != null;
    final hasSugar = sugar != null;
    final hasSalt = salt != null;
    final hasSaturatedFat = saturatedFat != null;
    final hasPolyunsaturatedFat = polyunsaturatedFat != null;
    final hasFiber = fiber != null;
    final hasName =
        (product.productName?.trim().isNotEmpty ?? false) ||
        (product.genericName?.trim().isNotEmpty ?? false);

    return OffProductCandidate(
      code: code,
      name: _firstNonEmpty([product.productName, product.genericName], code),
      brand: _nullableTrim(product.brands),
      quantityLabel: _nullableTrim(product.quantity),
      servingSizeLabel: _nullableTrim(product.servingSize),
      imageUrl: _nullableTrim(
        product.imageFrontSmallUrl ?? product.imageFrontUrl,
      ),
      per100: NutritionPer100(
        kcal: kcal ?? 0,
        protein: protein ?? 0,
        carbs: carbs ?? 0,
        fat: fat ?? 0,
        sugar: sugar ?? 0,
        salt: salt ?? 0,
        saturatedFat: saturatedFat,
        polyunsaturatedFat: polyunsaturatedFat,
        fiber: fiber,
      ),
      hasKcal: hasKcal,
      hasProtein: hasProtein,
      hasCarbs: hasCarbs,
      hasFat: hasFat,
      hasSugar: hasSugar,
      hasSalt: hasSalt,
      hasSaturatedFat: hasSaturatedFat,
      hasPolyunsaturatedFat: hasPolyunsaturatedFat,
      hasFiber: hasFiber,
      completenessScore: _computeScore(
        hasName: hasName,
        hasKcal: hasKcal,
        hasProtein: hasProtein,
        hasCarbs: hasCarbs,
        hasFat: hasFat,
        hasSugar: hasSugar,
        hasSalt: hasSalt,
      ),
    );
  }

  static double? _readKcalPer100(Nutriments? nutriments) {
    if (nutriments == null) return null;
    final kcal = nutriments.getValue(
      Nutrient.energyKCal,
      PerSize.oneHundredGrams,
    );
    if (kcal != null) return kcal;
    final kJ = nutriments.getValue(Nutrient.energyKJ, PerSize.oneHundredGrams);
    if (kJ == null) return null;
    return kJ / 4.184;
  }

  static String _firstNonEmpty(List<String?> values, String fallback) {
    for (final value in values) {
      final normalized = _nullableTrim(value);
      if (normalized != null) return normalized;
    }
    return fallback;
  }

  static String? _nullableTrim(String? input) {
    final value = input?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static double _computeScore({
    required bool hasName,
    required bool hasKcal,
    required bool hasProtein,
    required bool hasCarbs,
    required bool hasFat,
    required bool hasSugar,
    required bool hasSalt,
  }) {
    final dimensions = <bool>[
      hasName,
      hasKcal,
      hasProtein,
      hasCarbs,
      hasFat,
      hasSugar,
      hasSalt,
    ];
    final hits = dimensions.where((value) => value).length;
    return hits / dimensions.length;
  }

  static void _ensureApiConfigured() {
    if (OpenFoodAPIConfiguration.userAgent != null) return;
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'MealTrack',
      version: '1.0.0',
      comment: 'contact: repin@mailbox.org',
    );
  }
}
