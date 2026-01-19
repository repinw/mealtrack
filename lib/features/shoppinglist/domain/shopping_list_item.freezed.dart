// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShoppingListItem {

 String get id; String get name; bool get isChecked; int get quantity; String? get brand;
/// Create a copy of ShoppingListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingListItemCopyWith<ShoppingListItem> get copyWith => _$ShoppingListItemCopyWithImpl<ShoppingListItem>(this as ShoppingListItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isChecked, isChecked) || other.isChecked == isChecked)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.brand, brand) || other.brand == brand));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,isChecked,quantity,brand);

@override
String toString() {
  return 'ShoppingListItem(id: $id, name: $name, isChecked: $isChecked, quantity: $quantity, brand: $brand)';
}


}

/// @nodoc
abstract mixin class $ShoppingListItemCopyWith<$Res>  {
  factory $ShoppingListItemCopyWith(ShoppingListItem value, $Res Function(ShoppingListItem) _then) = _$ShoppingListItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool isChecked, int quantity, String? brand
});




}
/// @nodoc
class _$ShoppingListItemCopyWithImpl<$Res>
    implements $ShoppingListItemCopyWith<$Res> {
  _$ShoppingListItemCopyWithImpl(this._self, this._then);

  final ShoppingListItem _self;
  final $Res Function(ShoppingListItem) _then;

/// Create a copy of ShoppingListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isChecked = null,Object? quantity = null,Object? brand = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isChecked: null == isChecked ? _self.isChecked : isChecked // ignore: cast_nullable_to_non_nullable
as bool,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingListItem].
extension ShoppingListItemPatterns on ShoppingListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingListItem value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingListItem value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool isChecked,  int quantity,  String? brand)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingListItem() when $default != null:
return $default(_that.id,_that.name,_that.isChecked,_that.quantity,_that.brand);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool isChecked,  int quantity,  String? brand)  $default,) {final _that = this;
switch (_that) {
case _ShoppingListItem():
return $default(_that.id,_that.name,_that.isChecked,_that.quantity,_that.brand);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool isChecked,  int quantity,  String? brand)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingListItem() when $default != null:
return $default(_that.id,_that.name,_that.isChecked,_that.quantity,_that.brand);case _:
  return null;

}
}

}

/// @nodoc


class _ShoppingListItem implements ShoppingListItem {
  const _ShoppingListItem({required this.id, required this.name, this.isChecked = false, this.quantity = 1, this.brand});
  

@override final  String id;
@override final  String name;
@override@JsonKey() final  bool isChecked;
@override@JsonKey() final  int quantity;
@override final  String? brand;

/// Create a copy of ShoppingListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingListItemCopyWith<_ShoppingListItem> get copyWith => __$ShoppingListItemCopyWithImpl<_ShoppingListItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isChecked, isChecked) || other.isChecked == isChecked)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.brand, brand) || other.brand == brand));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,isChecked,quantity,brand);

@override
String toString() {
  return 'ShoppingListItem(id: $id, name: $name, isChecked: $isChecked, quantity: $quantity, brand: $brand)';
}


}

/// @nodoc
abstract mixin class _$ShoppingListItemCopyWith<$Res> implements $ShoppingListItemCopyWith<$Res> {
  factory _$ShoppingListItemCopyWith(_ShoppingListItem value, $Res Function(_ShoppingListItem) _then) = __$ShoppingListItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool isChecked, int quantity, String? brand
});




}
/// @nodoc
class __$ShoppingListItemCopyWithImpl<$Res>
    implements _$ShoppingListItemCopyWith<$Res> {
  __$ShoppingListItemCopyWithImpl(this._self, this._then);

  final _ShoppingListItem _self;
  final $Res Function(_ShoppingListItem) _then;

/// Create a copy of ShoppingListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isChecked = null,Object? quantity = null,Object? brand = freezed,}) {
  return _then(_ShoppingListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isChecked: null == isChecked ? _self.isChecked : isChecked // ignore: cast_nullable_to_non_nullable
as bool,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
