// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_list_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShoppingListStats {

 double get totalValue; int get scanCount; int get articleCount;
/// Create a copy of ShoppingListStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingListStatsCopyWith<ShoppingListStats> get copyWith => _$ShoppingListStatsCopyWithImpl<ShoppingListStats>(this as ShoppingListStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingListStats&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.scanCount, scanCount) || other.scanCount == scanCount)&&(identical(other.articleCount, articleCount) || other.articleCount == articleCount));
}


@override
int get hashCode => Object.hash(runtimeType,totalValue,scanCount,articleCount);

@override
String toString() {
  return 'ShoppingListStats(totalValue: $totalValue, scanCount: $scanCount, articleCount: $articleCount)';
}


}

/// @nodoc
abstract mixin class $ShoppingListStatsCopyWith<$Res>  {
  factory $ShoppingListStatsCopyWith(ShoppingListStats value, $Res Function(ShoppingListStats) _then) = _$ShoppingListStatsCopyWithImpl;
@useResult
$Res call({
 double totalValue, int scanCount, int articleCount
});




}
/// @nodoc
class _$ShoppingListStatsCopyWithImpl<$Res>
    implements $ShoppingListStatsCopyWith<$Res> {
  _$ShoppingListStatsCopyWithImpl(this._self, this._then);

  final ShoppingListStats _self;
  final $Res Function(ShoppingListStats) _then;

/// Create a copy of ShoppingListStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalValue = null,Object? scanCount = null,Object? articleCount = null,}) {
  return _then(_self.copyWith(
totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as double,scanCount: null == scanCount ? _self.scanCount : scanCount // ignore: cast_nullable_to_non_nullable
as int,articleCount: null == articleCount ? _self.articleCount : articleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingListStats].
extension ShoppingListStatsPatterns on ShoppingListStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingListStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingListStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingListStats value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingListStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingListStats value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingListStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalValue,  int scanCount,  int articleCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingListStats() when $default != null:
return $default(_that.totalValue,_that.scanCount,_that.articleCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalValue,  int scanCount,  int articleCount)  $default,) {final _that = this;
switch (_that) {
case _ShoppingListStats():
return $default(_that.totalValue,_that.scanCount,_that.articleCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalValue,  int scanCount,  int articleCount)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingListStats() when $default != null:
return $default(_that.totalValue,_that.scanCount,_that.articleCount);case _:
  return null;

}
}

}

/// @nodoc


class _ShoppingListStats implements ShoppingListStats {
  const _ShoppingListStats({required this.totalValue, required this.scanCount, required this.articleCount});
  

@override final  double totalValue;
@override final  int scanCount;
@override final  int articleCount;

/// Create a copy of ShoppingListStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingListStatsCopyWith<_ShoppingListStats> get copyWith => __$ShoppingListStatsCopyWithImpl<_ShoppingListStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingListStats&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.scanCount, scanCount) || other.scanCount == scanCount)&&(identical(other.articleCount, articleCount) || other.articleCount == articleCount));
}


@override
int get hashCode => Object.hash(runtimeType,totalValue,scanCount,articleCount);

@override
String toString() {
  return 'ShoppingListStats(totalValue: $totalValue, scanCount: $scanCount, articleCount: $articleCount)';
}


}

/// @nodoc
abstract mixin class _$ShoppingListStatsCopyWith<$Res> implements $ShoppingListStatsCopyWith<$Res> {
  factory _$ShoppingListStatsCopyWith(_ShoppingListStats value, $Res Function(_ShoppingListStats) _then) = __$ShoppingListStatsCopyWithImpl;
@override @useResult
$Res call({
 double totalValue, int scanCount, int articleCount
});




}
/// @nodoc
class __$ShoppingListStatsCopyWithImpl<$Res>
    implements _$ShoppingListStatsCopyWith<$Res> {
  __$ShoppingListStatsCopyWithImpl(this._self, this._then);

  final _ShoppingListStats _self;
  final $Res Function(_ShoppingListStats) _then;

/// Create a copy of ShoppingListStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalValue = null,Object? scanCount = null,Object? articleCount = null,}) {
  return _then(_ShoppingListStats(
totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as double,scanCount: null == scanCount ? _self.scanCount : scanCount // ignore: cast_nullable_to_non_nullable
as int,articleCount: null == articleCount ? _self.articleCount : articleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
