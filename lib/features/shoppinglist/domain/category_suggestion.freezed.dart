// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategorySuggestion {

 String get name; double get averagePrice;
/// Create a copy of CategorySuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorySuggestionCopyWith<CategorySuggestion> get copyWith => _$CategorySuggestionCopyWithImpl<CategorySuggestion>(this as CategorySuggestion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorySuggestion&&(identical(other.name, name) || other.name == name)&&(identical(other.averagePrice, averagePrice) || other.averagePrice == averagePrice));
}


@override
int get hashCode => Object.hash(runtimeType,name,averagePrice);

@override
String toString() {
  return 'CategorySuggestion(name: $name, averagePrice: $averagePrice)';
}


}

/// @nodoc
abstract mixin class $CategorySuggestionCopyWith<$Res>  {
  factory $CategorySuggestionCopyWith(CategorySuggestion value, $Res Function(CategorySuggestion) _then) = _$CategorySuggestionCopyWithImpl;
@useResult
$Res call({
 String name, double averagePrice
});




}
/// @nodoc
class _$CategorySuggestionCopyWithImpl<$Res>
    implements $CategorySuggestionCopyWith<$Res> {
  _$CategorySuggestionCopyWithImpl(this._self, this._then);

  final CategorySuggestion _self;
  final $Res Function(CategorySuggestion) _then;

/// Create a copy of CategorySuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? averagePrice = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,averagePrice: null == averagePrice ? _self.averagePrice : averagePrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CategorySuggestion].
extension CategorySuggestionPatterns on CategorySuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategorySuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategorySuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategorySuggestion value)  $default,){
final _that = this;
switch (_that) {
case _CategorySuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategorySuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _CategorySuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double averagePrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorySuggestion() when $default != null:
return $default(_that.name,_that.averagePrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double averagePrice)  $default,) {final _that = this;
switch (_that) {
case _CategorySuggestion():
return $default(_that.name,_that.averagePrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double averagePrice)?  $default,) {final _that = this;
switch (_that) {
case _CategorySuggestion() when $default != null:
return $default(_that.name,_that.averagePrice);case _:
  return null;

}
}

}

/// @nodoc


class _CategorySuggestion implements CategorySuggestion {
  const _CategorySuggestion({required this.name, required this.averagePrice});
  

@override final  String name;
@override final  double averagePrice;

/// Create a copy of CategorySuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorySuggestionCopyWith<_CategorySuggestion> get copyWith => __$CategorySuggestionCopyWithImpl<_CategorySuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorySuggestion&&(identical(other.name, name) || other.name == name)&&(identical(other.averagePrice, averagePrice) || other.averagePrice == averagePrice));
}


@override
int get hashCode => Object.hash(runtimeType,name,averagePrice);

@override
String toString() {
  return 'CategorySuggestion(name: $name, averagePrice: $averagePrice)';
}


}

/// @nodoc
abstract mixin class _$CategorySuggestionCopyWith<$Res> implements $CategorySuggestionCopyWith<$Res> {
  factory _$CategorySuggestionCopyWith(_CategorySuggestion value, $Res Function(_CategorySuggestion) _then) = __$CategorySuggestionCopyWithImpl;
@override @useResult
$Res call({
 String name, double averagePrice
});




}
/// @nodoc
class __$CategorySuggestionCopyWithImpl<$Res>
    implements _$CategorySuggestionCopyWith<$Res> {
  __$CategorySuggestionCopyWithImpl(this._self, this._then);

  final _CategorySuggestion _self;
  final $Res Function(_CategorySuggestion) _then;

/// Create a copy of CategorySuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? averagePrice = null,}) {
  return _then(_CategorySuggestion(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,averagePrice: null == averagePrice ? _self.averagePrice : averagePrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
