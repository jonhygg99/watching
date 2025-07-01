// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'details_extras.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShowDetailsExtras {

 List<dynamic> get videos; Map<String, dynamic>? get people; List<dynamic> get relatedShows;
/// Create a copy of ShowDetailsExtras
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShowDetailsExtrasCopyWith<ShowDetailsExtras> get copyWith => _$ShowDetailsExtrasCopyWithImpl<ShowDetailsExtras>(this as ShowDetailsExtras, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShowDetailsExtras&&const DeepCollectionEquality().equals(other.videos, videos)&&const DeepCollectionEquality().equals(other.people, people)&&const DeepCollectionEquality().equals(other.relatedShows, relatedShows));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(videos),const DeepCollectionEquality().hash(people),const DeepCollectionEquality().hash(relatedShows));

@override
String toString() {
  return 'ShowDetailsExtras(videos: $videos, people: $people, relatedShows: $relatedShows)';
}


}

/// @nodoc
abstract mixin class $ShowDetailsExtrasCopyWith<$Res>  {
  factory $ShowDetailsExtrasCopyWith(ShowDetailsExtras value, $Res Function(ShowDetailsExtras) _then) = _$ShowDetailsExtrasCopyWithImpl;
@useResult
$Res call({
 List<dynamic> videos, Map<String, dynamic>? people, List<dynamic> relatedShows
});




}
/// @nodoc
class _$ShowDetailsExtrasCopyWithImpl<$Res>
    implements $ShowDetailsExtrasCopyWith<$Res> {
  _$ShowDetailsExtrasCopyWithImpl(this._self, this._then);

  final ShowDetailsExtras _self;
  final $Res Function(ShowDetailsExtras) _then;

/// Create a copy of ShowDetailsExtras
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videos = null,Object? people = freezed,Object? relatedShows = null,}) {
  return _then(_self.copyWith(
videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<dynamic>,people: freezed == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,relatedShows: null == relatedShows ? _self.relatedShows : relatedShows // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}

}


/// @nodoc


class _ShowDetailsExtras implements ShowDetailsExtras {
  const _ShowDetailsExtras({required final  List<dynamic> videos, required final  Map<String, dynamic>? people, required final  List<dynamic> relatedShows}): _videos = videos,_people = people,_relatedShows = relatedShows;
  

 final  List<dynamic> _videos;
@override List<dynamic> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

 final  Map<String, dynamic>? _people;
@override Map<String, dynamic>? get people {
  final value = _people;
  if (value == null) return null;
  if (_people is EqualUnmodifiableMapView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<dynamic> _relatedShows;
@override List<dynamic> get relatedShows {
  if (_relatedShows is EqualUnmodifiableListView) return _relatedShows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relatedShows);
}


/// Create a copy of ShowDetailsExtras
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShowDetailsExtrasCopyWith<_ShowDetailsExtras> get copyWith => __$ShowDetailsExtrasCopyWithImpl<_ShowDetailsExtras>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShowDetailsExtras&&const DeepCollectionEquality().equals(other._videos, _videos)&&const DeepCollectionEquality().equals(other._people, _people)&&const DeepCollectionEquality().equals(other._relatedShows, _relatedShows));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_videos),const DeepCollectionEquality().hash(_people),const DeepCollectionEquality().hash(_relatedShows));

@override
String toString() {
  return 'ShowDetailsExtras(videos: $videos, people: $people, relatedShows: $relatedShows)';
}


}

/// @nodoc
abstract mixin class _$ShowDetailsExtrasCopyWith<$Res> implements $ShowDetailsExtrasCopyWith<$Res> {
  factory _$ShowDetailsExtrasCopyWith(_ShowDetailsExtras value, $Res Function(_ShowDetailsExtras) _then) = __$ShowDetailsExtrasCopyWithImpl;
@override @useResult
$Res call({
 List<dynamic> videos, Map<String, dynamic>? people, List<dynamic> relatedShows
});




}
/// @nodoc
class __$ShowDetailsExtrasCopyWithImpl<$Res>
    implements _$ShowDetailsExtrasCopyWith<$Res> {
  __$ShowDetailsExtrasCopyWithImpl(this._self, this._then);

  final _ShowDetailsExtras _self;
  final $Res Function(_ShowDetailsExtras) _then;

/// Create a copy of ShowDetailsExtras
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videos = null,Object? people = freezed,Object? relatedShows = null,}) {
  return _then(_ShowDetailsExtras(
videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<dynamic>,people: freezed == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,relatedShows: null == relatedShows ? _self._relatedShows : relatedShows // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}


}

// dart format on
