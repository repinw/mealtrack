// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_flow_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShareFlowState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareFlowState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ShareFlowState()';
}


}

/// @nodoc
class $ShareFlowStateCopyWith<$Res>  {
$ShareFlowStateCopyWith(ShareFlowState _, $Res Function(ShareFlowState) __);
}


/// Adds pattern-matching-related methods to [ShareFlowState].
extension ShareFlowStatePatterns on ShareFlowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _ConfirmationPending value)?  confirmationPending,TResult Function( _Analyzing value)?  analyzing,TResult Function( _Success value)?  success,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _ConfirmationPending() when confirmationPending != null:
return confirmationPending(_that);case _Analyzing() when analyzing != null:
return analyzing(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _ConfirmationPending value)  confirmationPending,required TResult Function( _Analyzing value)  analyzing,required TResult Function( _Success value)  success,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _ConfirmationPending():
return confirmationPending(_that);case _Analyzing():
return analyzing(_that);case _Success():
return success(_that);case _Error():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _ConfirmationPending value)?  confirmationPending,TResult? Function( _Analyzing value)?  analyzing,TResult? Function( _Success value)?  success,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _ConfirmationPending() when confirmationPending != null:
return confirmationPending(_that);case _Analyzing() when analyzing != null:
return analyzing(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( XFile file)?  confirmationPending,TResult Function()?  analyzing,TResult Function()?  success,TResult Function( Object error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _ConfirmationPending() when confirmationPending != null:
return confirmationPending(_that.file);case _Analyzing() when analyzing != null:
return analyzing();case _Success() when success != null:
return success();case _Error() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( XFile file)  confirmationPending,required TResult Function()  analyzing,required TResult Function()  success,required TResult Function( Object error)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _ConfirmationPending():
return confirmationPending(_that.file);case _Analyzing():
return analyzing();case _Success():
return success();case _Error():
return error(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( XFile file)?  confirmationPending,TResult? Function()?  analyzing,TResult? Function()?  success,TResult? Function( Object error)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _ConfirmationPending() when confirmationPending != null:
return confirmationPending(_that.file);case _Analyzing() when analyzing != null:
return analyzing();case _Success() when success != null:
return success();case _Error() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ShareFlowState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ShareFlowState.initial()';
}


}




/// @nodoc


class _ConfirmationPending implements ShareFlowState {
  const _ConfirmationPending(this.file);
  

 final  XFile file;

/// Create a copy of ShareFlowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmationPendingCopyWith<_ConfirmationPending> get copyWith => __$ConfirmationPendingCopyWithImpl<_ConfirmationPending>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmationPending&&(identical(other.file, file) || other.file == file));
}


@override
int get hashCode => Object.hash(runtimeType,file);

@override
String toString() {
  return 'ShareFlowState.confirmationPending(file: $file)';
}


}

/// @nodoc
abstract mixin class _$ConfirmationPendingCopyWith<$Res> implements $ShareFlowStateCopyWith<$Res> {
  factory _$ConfirmationPendingCopyWith(_ConfirmationPending value, $Res Function(_ConfirmationPending) _then) = __$ConfirmationPendingCopyWithImpl;
@useResult
$Res call({
 XFile file
});




}
/// @nodoc
class __$ConfirmationPendingCopyWithImpl<$Res>
    implements _$ConfirmationPendingCopyWith<$Res> {
  __$ConfirmationPendingCopyWithImpl(this._self, this._then);

  final _ConfirmationPending _self;
  final $Res Function(_ConfirmationPending) _then;

/// Create a copy of ShareFlowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? file = null,}) {
  return _then(_ConfirmationPending(
null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as XFile,
  ));
}


}

/// @nodoc


class _Analyzing implements ShareFlowState {
  const _Analyzing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Analyzing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ShareFlowState.analyzing()';
}


}




/// @nodoc


class _Success implements ShareFlowState {
  const _Success();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ShareFlowState.success()';
}


}




/// @nodoc


class _Error implements ShareFlowState {
  const _Error(this.error);
  

 final  Object error;

/// Create a copy of ShareFlowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(error));

@override
String toString() {
  return 'ShareFlowState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $ShareFlowStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 Object error
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of ShareFlowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_Error(
null == error ? _self.error : error ,
  ));
}


}

// dart format on
