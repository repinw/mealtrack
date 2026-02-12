// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductSuggestion {

 String get name; double get averagePrice; int get count;
/// Create a copy of ProductSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductSuggestionCopyWith<ProductSuggestion> get copyWith => _$ProductSuggestionCopyWithImpl<ProductSuggestion>(this as ProductSuggestion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductSuggestion&&(identical(other.name, name) || other.name == name)&&(identical(other.averagePrice, averagePrice) || other.averagePrice == averagePrice)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,name,averagePrice,count);

@override
String toString() {
  return 'ProductSuggestion(name: $name, averagePrice: $averagePrice, count: $count)';
}


}

/// @nodoc
abstract mixin class $ProductSuggestionCopyWith<$Res>  {
  factory $ProductSuggestionCopyWith(ProductSuggestion value, $Res Function(ProductSuggestion) _then) = _$ProductSuggestionCopyWithImpl;
@useResult
$Res call({
 String name, double averagePrice, int count
});




}
/// @nodoc
class _$ProductSuggestionCopyWithImpl<$Res>
    implements $ProductSuggestionCopyWith<$Res> {
  _$ProductSuggestionCopyWithImpl(this._self, this._then);

  final ProductSuggestion _self;
  final $Res Function(ProductSuggestion) _then;

/// Create a copy of ProductSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? averagePrice = null,Object? count = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,averagePrice: null == averagePrice ? _self.averagePrice : averagePrice // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductSuggestion].
extension ProductSuggestionPatterns on ProductSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _ProductSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _ProductSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double averagePrice,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductSuggestion() when $default != null:
return $default(_that.name,_that.averagePrice,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double averagePrice,  int count)  $default,) {final _that = this;
switch (_that) {
case _ProductSuggestion():
return $default(_that.name,_that.averagePrice,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double averagePrice,  int count)?  $default,) {final _that = this;
switch (_that) {
case _ProductSuggestion() when $default != null:
return $default(_that.name,_that.averagePrice,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _ProductSuggestion implements ProductSuggestion {
  const _ProductSuggestion({required this.name, required this.averagePrice, required this.count});
  

@override final  String name;
@override final  double averagePrice;
@override final  int count;

/// Create a copy of ProductSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductSuggestionCopyWith<_ProductSuggestion> get copyWith => __$ProductSuggestionCopyWithImpl<_ProductSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductSuggestion&&(identical(other.name, name) || other.name == name)&&(identical(other.averagePrice, averagePrice) || other.averagePrice == averagePrice)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,name,averagePrice,count);

@override
String toString() {
  return 'ProductSuggestion(name: $name, averagePrice: $averagePrice, count: $count)';
}


}

/// @nodoc
abstract mixin class _$ProductSuggestionCopyWith<$Res> implements $ProductSuggestionCopyWith<$Res> {
  factory _$ProductSuggestionCopyWith(_ProductSuggestion value, $Res Function(_ProductSuggestion) _then) = __$ProductSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String name, double averagePrice, int count
});




}
/// @nodoc
class __$ProductSuggestionCopyWithImpl<$Res>
    implements _$ProductSuggestionCopyWith<$Res> {
  __$ProductSuggestionCopyWithImpl(this._self, this._then);

  final _ProductSuggestion _self;
  final $Res Function(_ProductSuggestion) _then;

/// Create a copy of ProductSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? averagePrice = null,Object? count = null,}) {
  return _then(_ProductSuggestion(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,averagePrice: null == averagePrice ? _self.averagePrice : averagePrice // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
