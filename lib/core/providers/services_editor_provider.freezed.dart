// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'services_editor_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServicesEditorState implements DiagnosticableTreeMixin {

 Set<String> get selected; Set<String> get unSelected;
/// Create a copy of ServicesEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServicesEditorStateCopyWith<ServicesEditorState> get copyWith => _$ServicesEditorStateCopyWithImpl<ServicesEditorState>(this as ServicesEditorState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ServicesEditorState'))
    ..add(DiagnosticsProperty('selected', selected))..add(DiagnosticsProperty('unSelected', unSelected));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServicesEditorState&&const DeepCollectionEquality().equals(other.selected, selected)&&const DeepCollectionEquality().equals(other.unSelected, unSelected));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selected),const DeepCollectionEquality().hash(unSelected));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ServicesEditorState(selected: $selected, unSelected: $unSelected)';
}


}

/// @nodoc
abstract mixin class $ServicesEditorStateCopyWith<$Res>  {
  factory $ServicesEditorStateCopyWith(ServicesEditorState value, $Res Function(ServicesEditorState) _then) = _$ServicesEditorStateCopyWithImpl;
@useResult
$Res call({
 Set<String> selected, Set<String> unSelected
});




}
/// @nodoc
class _$ServicesEditorStateCopyWithImpl<$Res>
    implements $ServicesEditorStateCopyWith<$Res> {
  _$ServicesEditorStateCopyWithImpl(this._self, this._then);

  final ServicesEditorState _self;
  final $Res Function(ServicesEditorState) _then;

/// Create a copy of ServicesEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selected = null,Object? unSelected = null,}) {
  return _then(_self.copyWith(
selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as Set<String>,unSelected: null == unSelected ? _self.unSelected : unSelected // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ServicesEditorState].
extension ServicesEditorStatePatterns on ServicesEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServicesEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServicesEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServicesEditorState value)  $default,){
final _that = this;
switch (_that) {
case _ServicesEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServicesEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _ServicesEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<String> selected,  Set<String> unSelected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServicesEditorState() when $default != null:
return $default(_that.selected,_that.unSelected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<String> selected,  Set<String> unSelected)  $default,) {final _that = this;
switch (_that) {
case _ServicesEditorState():
return $default(_that.selected,_that.unSelected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<String> selected,  Set<String> unSelected)?  $default,) {final _that = this;
switch (_that) {
case _ServicesEditorState() when $default != null:
return $default(_that.selected,_that.unSelected);case _:
  return null;

}
}

}

/// @nodoc


class _ServicesEditorState extends ServicesEditorState with DiagnosticableTreeMixin {
  const _ServicesEditorState({final  Set<String> selected = const <String>{}, final  Set<String> unSelected = const <String>{}}): _selected = selected,_unSelected = unSelected,super._();
  

 final  Set<String> _selected;
@override@JsonKey() Set<String> get selected {
  if (_selected is EqualUnmodifiableSetView) return _selected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selected);
}

 final  Set<String> _unSelected;
@override@JsonKey() Set<String> get unSelected {
  if (_unSelected is EqualUnmodifiableSetView) return _unSelected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_unSelected);
}


/// Create a copy of ServicesEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServicesEditorStateCopyWith<_ServicesEditorState> get copyWith => __$ServicesEditorStateCopyWithImpl<_ServicesEditorState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ServicesEditorState'))
    ..add(DiagnosticsProperty('selected', selected))..add(DiagnosticsProperty('unSelected', unSelected));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServicesEditorState&&const DeepCollectionEquality().equals(other._selected, _selected)&&const DeepCollectionEquality().equals(other._unSelected, _unSelected));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selected),const DeepCollectionEquality().hash(_unSelected));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ServicesEditorState(selected: $selected, unSelected: $unSelected)';
}


}

/// @nodoc
abstract mixin class _$ServicesEditorStateCopyWith<$Res> implements $ServicesEditorStateCopyWith<$Res> {
  factory _$ServicesEditorStateCopyWith(_ServicesEditorState value, $Res Function(_ServicesEditorState) _then) = __$ServicesEditorStateCopyWithImpl;
@override @useResult
$Res call({
 Set<String> selected, Set<String> unSelected
});




}
/// @nodoc
class __$ServicesEditorStateCopyWithImpl<$Res>
    implements _$ServicesEditorStateCopyWith<$Res> {
  __$ServicesEditorStateCopyWithImpl(this._self, this._then);

  final _ServicesEditorState _self;
  final $Res Function(_ServicesEditorState) _then;

/// Create a copy of ServicesEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selected = null,Object? unSelected = null,}) {
  return _then(_ServicesEditorState(
selected: null == selected ? _self._selected : selected // ignore: cast_nullable_to_non_nullable
as Set<String>,unSelected: null == unSelected ? _self._unSelected : unSelected // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
