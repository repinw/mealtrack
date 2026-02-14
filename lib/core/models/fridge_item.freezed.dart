// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fridge_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FridgeItem {

 String get id; String get name;@JsonKey(fromJson: _dateTimeFromJson) DateTime get entryDate; String get storeName; int get quantity; int get initialQuantity; double get unitPrice; String? get weight; FridgeItemAmountUnit get amountUnit; double get initialAmountBase; double get remainingAmountBase; double get eatenAmountBase; double get thrownAwayAmountBase; List<DateTime> get consumptionEvents; String? get receiptId;@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? get receiptDate; String? get language; String? get brand; String? get category; Map<String, double> get discounts; bool get isDeposit; bool get isDiscount; bool get isArchived;
/// Create a copy of FridgeItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FridgeItemCopyWith<FridgeItem> get copyWith => _$FridgeItemCopyWithImpl<FridgeItem>(this as FridgeItem, _$identity);

  /// Serializes this FridgeItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FridgeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.entryDate, entryDate) || other.entryDate == entryDate)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.initialQuantity, initialQuantity) || other.initialQuantity == initialQuantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.amountUnit, amountUnit) || other.amountUnit == amountUnit)&&(identical(other.initialAmountBase, initialAmountBase) || other.initialAmountBase == initialAmountBase)&&(identical(other.remainingAmountBase, remainingAmountBase) || other.remainingAmountBase == remainingAmountBase)&&(identical(other.eatenAmountBase, eatenAmountBase) || other.eatenAmountBase == eatenAmountBase)&&(identical(other.thrownAwayAmountBase, thrownAwayAmountBase) || other.thrownAwayAmountBase == thrownAwayAmountBase)&&const DeepCollectionEquality().equals(other.consumptionEvents, consumptionEvents)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.language, language) || other.language == language)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.discounts, discounts)&&(identical(other.isDeposit, isDeposit) || other.isDeposit == isDeposit)&&(identical(other.isDiscount, isDiscount) || other.isDiscount == isDiscount)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,entryDate,storeName,quantity,initialQuantity,unitPrice,weight,amountUnit,initialAmountBase,remainingAmountBase,eatenAmountBase,thrownAwayAmountBase,const DeepCollectionEquality().hash(consumptionEvents),receiptId,receiptDate,language,brand,category,const DeepCollectionEquality().hash(discounts),isDeposit,isDiscount,isArchived]);

@override
String toString() {
  return 'FridgeItem(id: $id, name: $name, entryDate: $entryDate, storeName: $storeName, quantity: $quantity, initialQuantity: $initialQuantity, unitPrice: $unitPrice, weight: $weight, amountUnit: $amountUnit, initialAmountBase: $initialAmountBase, remainingAmountBase: $remainingAmountBase, eatenAmountBase: $eatenAmountBase, thrownAwayAmountBase: $thrownAwayAmountBase, consumptionEvents: $consumptionEvents, receiptId: $receiptId, receiptDate: $receiptDate, language: $language, brand: $brand, category: $category, discounts: $discounts, isDeposit: $isDeposit, isDiscount: $isDiscount, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class $FridgeItemCopyWith<$Res>  {
  factory $FridgeItemCopyWith(FridgeItem value, $Res Function(FridgeItem) _then) = _$FridgeItemCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _dateTimeFromJson) DateTime entryDate, String storeName, int quantity, int initialQuantity, double unitPrice, String? weight, FridgeItemAmountUnit amountUnit, double initialAmountBase, double remainingAmountBase, double eatenAmountBase, double thrownAwayAmountBase, List<DateTime> consumptionEvents, String? receiptId,@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? receiptDate, String? language, String? brand, String? category, Map<String, double> discounts, bool isDeposit, bool isDiscount, bool isArchived
});




}
/// @nodoc
class _$FridgeItemCopyWithImpl<$Res>
    implements $FridgeItemCopyWith<$Res> {
  _$FridgeItemCopyWithImpl(this._self, this._then);

  final FridgeItem _self;
  final $Res Function(FridgeItem) _then;

/// Create a copy of FridgeItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? entryDate = null,Object? storeName = null,Object? quantity = null,Object? initialQuantity = null,Object? unitPrice = null,Object? weight = freezed,Object? amountUnit = null,Object? initialAmountBase = null,Object? remainingAmountBase = null,Object? eatenAmountBase = null,Object? thrownAwayAmountBase = null,Object? consumptionEvents = null,Object? receiptId = freezed,Object? receiptDate = freezed,Object? language = freezed,Object? brand = freezed,Object? category = freezed,Object? discounts = null,Object? isDeposit = null,Object? isDiscount = null,Object? isArchived = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,entryDate: null == entryDate ? _self.entryDate : entryDate // ignore: cast_nullable_to_non_nullable
as DateTime,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,initialQuantity: null == initialQuantity ? _self.initialQuantity : initialQuantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as String?,amountUnit: null == amountUnit ? _self.amountUnit : amountUnit // ignore: cast_nullable_to_non_nullable
as FridgeItemAmountUnit,initialAmountBase: null == initialAmountBase ? _self.initialAmountBase : initialAmountBase // ignore: cast_nullable_to_non_nullable
as double,remainingAmountBase: null == remainingAmountBase ? _self.remainingAmountBase : remainingAmountBase // ignore: cast_nullable_to_non_nullable
as double,eatenAmountBase: null == eatenAmountBase ? _self.eatenAmountBase : eatenAmountBase // ignore: cast_nullable_to_non_nullable
as double,thrownAwayAmountBase: null == thrownAwayAmountBase ? _self.thrownAwayAmountBase : thrownAwayAmountBase // ignore: cast_nullable_to_non_nullable
as double,consumptionEvents: null == consumptionEvents ? _self.consumptionEvents : consumptionEvents // ignore: cast_nullable_to_non_nullable
as List<DateTime>,receiptId: freezed == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String?,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,discounts: null == discounts ? _self.discounts : discounts // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isDeposit: null == isDeposit ? _self.isDeposit : isDeposit // ignore: cast_nullable_to_non_nullable
as bool,isDiscount: null == isDiscount ? _self.isDiscount : isDiscount // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FridgeItem].
extension FridgeItemPatterns on FridgeItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FridgeItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FridgeItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FridgeItem value)  $default,){
final _that = this;
switch (_that) {
case _FridgeItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FridgeItem value)?  $default,){
final _that = this;
switch (_that) {
case _FridgeItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _dateTimeFromJson)  DateTime entryDate,  String storeName,  int quantity,  int initialQuantity,  double unitPrice,  String? weight,  FridgeItemAmountUnit amountUnit,  double initialAmountBase,  double remainingAmountBase,  double eatenAmountBase,  double thrownAwayAmountBase,  List<DateTime> consumptionEvents,  String? receiptId, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? receiptDate,  String? language,  String? brand,  String? category,  Map<String, double> discounts,  bool isDeposit,  bool isDiscount,  bool isArchived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FridgeItem() when $default != null:
return $default(_that.id,_that.name,_that.entryDate,_that.storeName,_that.quantity,_that.initialQuantity,_that.unitPrice,_that.weight,_that.amountUnit,_that.initialAmountBase,_that.remainingAmountBase,_that.eatenAmountBase,_that.thrownAwayAmountBase,_that.consumptionEvents,_that.receiptId,_that.receiptDate,_that.language,_that.brand,_that.category,_that.discounts,_that.isDeposit,_that.isDiscount,_that.isArchived);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _dateTimeFromJson)  DateTime entryDate,  String storeName,  int quantity,  int initialQuantity,  double unitPrice,  String? weight,  FridgeItemAmountUnit amountUnit,  double initialAmountBase,  double remainingAmountBase,  double eatenAmountBase,  double thrownAwayAmountBase,  List<DateTime> consumptionEvents,  String? receiptId, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? receiptDate,  String? language,  String? brand,  String? category,  Map<String, double> discounts,  bool isDeposit,  bool isDiscount,  bool isArchived)  $default,) {final _that = this;
switch (_that) {
case _FridgeItem():
return $default(_that.id,_that.name,_that.entryDate,_that.storeName,_that.quantity,_that.initialQuantity,_that.unitPrice,_that.weight,_that.amountUnit,_that.initialAmountBase,_that.remainingAmountBase,_that.eatenAmountBase,_that.thrownAwayAmountBase,_that.consumptionEvents,_that.receiptId,_that.receiptDate,_that.language,_that.brand,_that.category,_that.discounts,_that.isDeposit,_that.isDiscount,_that.isArchived);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(fromJson: _dateTimeFromJson)  DateTime entryDate,  String storeName,  int quantity,  int initialQuantity,  double unitPrice,  String? weight,  FridgeItemAmountUnit amountUnit,  double initialAmountBase,  double remainingAmountBase,  double eatenAmountBase,  double thrownAwayAmountBase,  List<DateTime> consumptionEvents,  String? receiptId, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? receiptDate,  String? language,  String? brand,  String? category,  Map<String, double> discounts,  bool isDeposit,  bool isDiscount,  bool isArchived)?  $default,) {final _that = this;
switch (_that) {
case _FridgeItem() when $default != null:
return $default(_that.id,_that.name,_that.entryDate,_that.storeName,_that.quantity,_that.initialQuantity,_that.unitPrice,_that.weight,_that.amountUnit,_that.initialAmountBase,_that.remainingAmountBase,_that.eatenAmountBase,_that.thrownAwayAmountBase,_that.consumptionEvents,_that.receiptId,_that.receiptDate,_that.language,_that.brand,_that.category,_that.discounts,_that.isDeposit,_that.isDiscount,_that.isArchived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FridgeItem extends FridgeItem {
  const _FridgeItem({required this.id, required this.name, @JsonKey(fromJson: _dateTimeFromJson) required this.entryDate, required this.storeName, required this.quantity, this.initialQuantity = 1, this.unitPrice = 0.0, this.weight, this.amountUnit = FridgeItemAmountUnit.gram, this.initialAmountBase = 0.0, this.remainingAmountBase = 0.0, this.eatenAmountBase = 0.0, this.thrownAwayAmountBase = 0.0, final  List<DateTime> consumptionEvents = const [], this.receiptId, @JsonKey(fromJson: _nullableDateTimeFromJson) this.receiptDate, this.language, this.brand, this.category, final  Map<String, double> discounts = const {}, this.isDeposit = false, this.isDiscount = false, this.isArchived = false}): _consumptionEvents = consumptionEvents,_discounts = discounts,super._();
  factory _FridgeItem.fromJson(Map<String, dynamic> json) => _$FridgeItemFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(fromJson: _dateTimeFromJson) final  DateTime entryDate;
@override final  String storeName;
@override final  int quantity;
@override@JsonKey() final  int initialQuantity;
@override@JsonKey() final  double unitPrice;
@override final  String? weight;
@override@JsonKey() final  FridgeItemAmountUnit amountUnit;
@override@JsonKey() final  double initialAmountBase;
@override@JsonKey() final  double remainingAmountBase;
@override@JsonKey() final  double eatenAmountBase;
@override@JsonKey() final  double thrownAwayAmountBase;
 final  List<DateTime> _consumptionEvents;
@override@JsonKey() List<DateTime> get consumptionEvents {
  if (_consumptionEvents is EqualUnmodifiableListView) return _consumptionEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_consumptionEvents);
}

@override final  String? receiptId;
@override@JsonKey(fromJson: _nullableDateTimeFromJson) final  DateTime? receiptDate;
@override final  String? language;
@override final  String? brand;
@override final  String? category;
 final  Map<String, double> _discounts;
@override@JsonKey() Map<String, double> get discounts {
  if (_discounts is EqualUnmodifiableMapView) return _discounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_discounts);
}

@override@JsonKey() final  bool isDeposit;
@override@JsonKey() final  bool isDiscount;
@override@JsonKey() final  bool isArchived;

/// Create a copy of FridgeItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FridgeItemCopyWith<_FridgeItem> get copyWith => __$FridgeItemCopyWithImpl<_FridgeItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FridgeItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FridgeItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.entryDate, entryDate) || other.entryDate == entryDate)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.initialQuantity, initialQuantity) || other.initialQuantity == initialQuantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.amountUnit, amountUnit) || other.amountUnit == amountUnit)&&(identical(other.initialAmountBase, initialAmountBase) || other.initialAmountBase == initialAmountBase)&&(identical(other.remainingAmountBase, remainingAmountBase) || other.remainingAmountBase == remainingAmountBase)&&(identical(other.eatenAmountBase, eatenAmountBase) || other.eatenAmountBase == eatenAmountBase)&&(identical(other.thrownAwayAmountBase, thrownAwayAmountBase) || other.thrownAwayAmountBase == thrownAwayAmountBase)&&const DeepCollectionEquality().equals(other._consumptionEvents, _consumptionEvents)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.language, language) || other.language == language)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._discounts, _discounts)&&(identical(other.isDeposit, isDeposit) || other.isDeposit == isDeposit)&&(identical(other.isDiscount, isDiscount) || other.isDiscount == isDiscount)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,entryDate,storeName,quantity,initialQuantity,unitPrice,weight,amountUnit,initialAmountBase,remainingAmountBase,eatenAmountBase,thrownAwayAmountBase,const DeepCollectionEquality().hash(_consumptionEvents),receiptId,receiptDate,language,brand,category,const DeepCollectionEquality().hash(_discounts),isDeposit,isDiscount,isArchived]);

@override
String toString() {
  return 'FridgeItem(id: $id, name: $name, entryDate: $entryDate, storeName: $storeName, quantity: $quantity, initialQuantity: $initialQuantity, unitPrice: $unitPrice, weight: $weight, amountUnit: $amountUnit, initialAmountBase: $initialAmountBase, remainingAmountBase: $remainingAmountBase, eatenAmountBase: $eatenAmountBase, thrownAwayAmountBase: $thrownAwayAmountBase, consumptionEvents: $consumptionEvents, receiptId: $receiptId, receiptDate: $receiptDate, language: $language, brand: $brand, category: $category, discounts: $discounts, isDeposit: $isDeposit, isDiscount: $isDiscount, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class _$FridgeItemCopyWith<$Res> implements $FridgeItemCopyWith<$Res> {
  factory _$FridgeItemCopyWith(_FridgeItem value, $Res Function(_FridgeItem) _then) = __$FridgeItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _dateTimeFromJson) DateTime entryDate, String storeName, int quantity, int initialQuantity, double unitPrice, String? weight, FridgeItemAmountUnit amountUnit, double initialAmountBase, double remainingAmountBase, double eatenAmountBase, double thrownAwayAmountBase, List<DateTime> consumptionEvents, String? receiptId,@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? receiptDate, String? language, String? brand, String? category, Map<String, double> discounts, bool isDeposit, bool isDiscount, bool isArchived
});




}
/// @nodoc
class __$FridgeItemCopyWithImpl<$Res>
    implements _$FridgeItemCopyWith<$Res> {
  __$FridgeItemCopyWithImpl(this._self, this._then);

  final _FridgeItem _self;
  final $Res Function(_FridgeItem) _then;

/// Create a copy of FridgeItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? entryDate = null,Object? storeName = null,Object? quantity = null,Object? initialQuantity = null,Object? unitPrice = null,Object? weight = freezed,Object? amountUnit = null,Object? initialAmountBase = null,Object? remainingAmountBase = null,Object? eatenAmountBase = null,Object? thrownAwayAmountBase = null,Object? consumptionEvents = null,Object? receiptId = freezed,Object? receiptDate = freezed,Object? language = freezed,Object? brand = freezed,Object? category = freezed,Object? discounts = null,Object? isDeposit = null,Object? isDiscount = null,Object? isArchived = null,}) {
  return _then(_FridgeItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,entryDate: null == entryDate ? _self.entryDate : entryDate // ignore: cast_nullable_to_non_nullable
as DateTime,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,initialQuantity: null == initialQuantity ? _self.initialQuantity : initialQuantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as String?,amountUnit: null == amountUnit ? _self.amountUnit : amountUnit // ignore: cast_nullable_to_non_nullable
as FridgeItemAmountUnit,initialAmountBase: null == initialAmountBase ? _self.initialAmountBase : initialAmountBase // ignore: cast_nullable_to_non_nullable
as double,remainingAmountBase: null == remainingAmountBase ? _self.remainingAmountBase : remainingAmountBase // ignore: cast_nullable_to_non_nullable
as double,eatenAmountBase: null == eatenAmountBase ? _self.eatenAmountBase : eatenAmountBase // ignore: cast_nullable_to_non_nullable
as double,thrownAwayAmountBase: null == thrownAwayAmountBase ? _self.thrownAwayAmountBase : thrownAwayAmountBase // ignore: cast_nullable_to_non_nullable
as double,consumptionEvents: null == consumptionEvents ? _self._consumptionEvents : consumptionEvents // ignore: cast_nullable_to_non_nullable
as List<DateTime>,receiptId: freezed == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String?,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,discounts: null == discounts ? _self._discounts : discounts // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isDeposit: null == isDeposit ? _self.isDeposit : isDeposit // ignore: cast_nullable_to_non_nullable
as bool,isDiscount: null == isDiscount ? _self.isDiscount : isDiscount // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
