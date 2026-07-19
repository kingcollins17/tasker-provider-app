// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tasks_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TasksFilter {

 String? get status; String? get categoryId; String? get serviceId; String? get search; double? get radiusKm; String? get sortBy; bool? get sortDesc; String? get regionId; double? get budgetMin; double? get budgetMax; String? get scheduledStartAt; String? get expiresAt; String? get customerId;
/// Create a copy of TasksFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TasksFilterCopyWith<TasksFilter> get copyWith => _$TasksFilterCopyWithImpl<TasksFilter>(this as TasksFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TasksFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.search, search) || other.search == search)&&(identical(other.radiusKm, radiusKm) || other.radiusKm == radiusKm)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.scheduledStartAt, scheduledStartAt) || other.scheduledStartAt == scheduledStartAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.customerId, customerId) || other.customerId == customerId));
}


@override
int get hashCode => Object.hash(runtimeType,status,categoryId,serviceId,search,radiusKm,sortBy,sortDesc,regionId,budgetMin,budgetMax,scheduledStartAt,expiresAt,customerId);

@override
String toString() {
  return 'TasksFilter(status: $status, categoryId: $categoryId, serviceId: $serviceId, search: $search, radiusKm: $radiusKm, sortBy: $sortBy, sortDesc: $sortDesc, regionId: $regionId, budgetMin: $budgetMin, budgetMax: $budgetMax, scheduledStartAt: $scheduledStartAt, expiresAt: $expiresAt, customerId: $customerId)';
}


}

/// @nodoc
abstract mixin class $TasksFilterCopyWith<$Res>  {
  factory $TasksFilterCopyWith(TasksFilter value, $Res Function(TasksFilter) _then) = _$TasksFilterCopyWithImpl;
@useResult
$Res call({
 String? status, String? categoryId, String? serviceId, String? search, double? radiusKm, String? sortBy, bool? sortDesc, String? regionId, double? budgetMin, double? budgetMax, String? scheduledStartAt, String? expiresAt, String? customerId
});




}
/// @nodoc
class _$TasksFilterCopyWithImpl<$Res>
    implements $TasksFilterCopyWith<$Res> {
  _$TasksFilterCopyWithImpl(this._self, this._then);

  final TasksFilter _self;
  final $Res Function(TasksFilter) _then;

/// Create a copy of TasksFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? categoryId = freezed,Object? serviceId = freezed,Object? search = freezed,Object? radiusKm = freezed,Object? sortBy = freezed,Object? sortDesc = freezed,Object? regionId = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? scheduledStartAt = freezed,Object? expiresAt = freezed,Object? customerId = freezed,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,radiusKm: freezed == radiusKm ? _self.radiusKm : radiusKm // ignore: cast_nullable_to_non_nullable
as double?,sortBy: freezed == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String?,sortDesc: freezed == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as double?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as double?,scheduledStartAt: freezed == scheduledStartAt ? _self.scheduledStartAt : scheduledStartAt // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TasksFilter].
extension TasksFilterPatterns on TasksFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TasksFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TasksFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TasksFilter value)  $default,){
final _that = this;
switch (_that) {
case _TasksFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TasksFilter value)?  $default,){
final _that = this;
switch (_that) {
case _TasksFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? status,  String? categoryId,  String? serviceId,  String? search,  double? radiusKm,  String? sortBy,  bool? sortDesc,  String? regionId,  double? budgetMin,  double? budgetMax,  String? scheduledStartAt,  String? expiresAt,  String? customerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TasksFilter() when $default != null:
return $default(_that.status,_that.categoryId,_that.serviceId,_that.search,_that.radiusKm,_that.sortBy,_that.sortDesc,_that.regionId,_that.budgetMin,_that.budgetMax,_that.scheduledStartAt,_that.expiresAt,_that.customerId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? status,  String? categoryId,  String? serviceId,  String? search,  double? radiusKm,  String? sortBy,  bool? sortDesc,  String? regionId,  double? budgetMin,  double? budgetMax,  String? scheduledStartAt,  String? expiresAt,  String? customerId)  $default,) {final _that = this;
switch (_that) {
case _TasksFilter():
return $default(_that.status,_that.categoryId,_that.serviceId,_that.search,_that.radiusKm,_that.sortBy,_that.sortDesc,_that.regionId,_that.budgetMin,_that.budgetMax,_that.scheduledStartAt,_that.expiresAt,_that.customerId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? status,  String? categoryId,  String? serviceId,  String? search,  double? radiusKm,  String? sortBy,  bool? sortDesc,  String? regionId,  double? budgetMin,  double? budgetMax,  String? scheduledStartAt,  String? expiresAt,  String? customerId)?  $default,) {final _that = this;
switch (_that) {
case _TasksFilter() when $default != null:
return $default(_that.status,_that.categoryId,_that.serviceId,_that.search,_that.radiusKm,_that.sortBy,_that.sortDesc,_that.regionId,_that.budgetMin,_that.budgetMax,_that.scheduledStartAt,_that.expiresAt,_that.customerId);case _:
  return null;

}
}

}

/// @nodoc


class _TasksFilter implements TasksFilter {
  const _TasksFilter({this.status, this.categoryId, this.serviceId, this.search, this.radiusKm, this.sortBy, this.sortDesc, this.regionId, this.budgetMin, this.budgetMax, this.scheduledStartAt, this.expiresAt, this.customerId});
  

@override final  String? status;
@override final  String? categoryId;
@override final  String? serviceId;
@override final  String? search;
@override final  double? radiusKm;
@override final  String? sortBy;
@override final  bool? sortDesc;
@override final  String? regionId;
@override final  double? budgetMin;
@override final  double? budgetMax;
@override final  String? scheduledStartAt;
@override final  String? expiresAt;
@override final  String? customerId;

/// Create a copy of TasksFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TasksFilterCopyWith<_TasksFilter> get copyWith => __$TasksFilterCopyWithImpl<_TasksFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TasksFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.search, search) || other.search == search)&&(identical(other.radiusKm, radiusKm) || other.radiusKm == radiusKm)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.scheduledStartAt, scheduledStartAt) || other.scheduledStartAt == scheduledStartAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.customerId, customerId) || other.customerId == customerId));
}


@override
int get hashCode => Object.hash(runtimeType,status,categoryId,serviceId,search,radiusKm,sortBy,sortDesc,regionId,budgetMin,budgetMax,scheduledStartAt,expiresAt,customerId);

@override
String toString() {
  return 'TasksFilter(status: $status, categoryId: $categoryId, serviceId: $serviceId, search: $search, radiusKm: $radiusKm, sortBy: $sortBy, sortDesc: $sortDesc, regionId: $regionId, budgetMin: $budgetMin, budgetMax: $budgetMax, scheduledStartAt: $scheduledStartAt, expiresAt: $expiresAt, customerId: $customerId)';
}


}

/// @nodoc
abstract mixin class _$TasksFilterCopyWith<$Res> implements $TasksFilterCopyWith<$Res> {
  factory _$TasksFilterCopyWith(_TasksFilter value, $Res Function(_TasksFilter) _then) = __$TasksFilterCopyWithImpl;
@override @useResult
$Res call({
 String? status, String? categoryId, String? serviceId, String? search, double? radiusKm, String? sortBy, bool? sortDesc, String? regionId, double? budgetMin, double? budgetMax, String? scheduledStartAt, String? expiresAt, String? customerId
});




}
/// @nodoc
class __$TasksFilterCopyWithImpl<$Res>
    implements _$TasksFilterCopyWith<$Res> {
  __$TasksFilterCopyWithImpl(this._self, this._then);

  final _TasksFilter _self;
  final $Res Function(_TasksFilter) _then;

/// Create a copy of TasksFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? categoryId = freezed,Object? serviceId = freezed,Object? search = freezed,Object? radiusKm = freezed,Object? sortBy = freezed,Object? sortDesc = freezed,Object? regionId = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? scheduledStartAt = freezed,Object? expiresAt = freezed,Object? customerId = freezed,}) {
  return _then(_TasksFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,radiusKm: freezed == radiusKm ? _self.radiusKm : radiusKm // ignore: cast_nullable_to_non_nullable
as double?,sortBy: freezed == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String?,sortDesc: freezed == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as double?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as double?,scheduledStartAt: freezed == scheduledStartAt ? _self.scheduledStartAt : scheduledStartAt // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
