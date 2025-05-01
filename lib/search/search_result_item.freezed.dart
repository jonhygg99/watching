// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'search_result_item.dart';

// ***************************************************************************
// FreezedGenerator
// ***************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it. Please check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods',
);

/// @nodoc
mixin _$SearchResultItem {
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResultItemCopyWith<SearchResultItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResultItemCopyWith<$Res> {
  factory $SearchResultItemCopyWith(
    SearchResultItem value,
    $Res Function(SearchResultItem) then,
  ) = _$SearchResultItemCopyWithImpl<$Res, SearchResultItem>;
  $Res call({Map<String, dynamic> data, String type});
}

/// @nodoc
class _$SearchResultItemCopyWithImpl<$Res, $Val extends SearchResultItem>
    implements $SearchResultItemCopyWith<$Res> {
  _$SearchResultItemCopyWithImpl(this._value, this._then);

  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @override
  $Res call({Object? data = null, Object? type = null}) {
    return _then(
      _value.copyWith(
            data:
                null == data
                    ? _value.data
                    : data // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$_SearchResultItemCopyWith<$Res>
    implements $SearchResultItemCopyWith<$Res> {
  factory _$$_SearchResultItemCopyWith(
    _$_SearchResultItem value,
    $Res Function(_$_SearchResultItem) then,
  ) = __$$_SearchResultItemCopyWithImpl<$Res>;
  @override
  $Res call({Map<String, dynamic> data, String type});
}

/// @nodoc
class __$$_SearchResultItemCopyWithImpl<$Res>
    extends _$SearchResultItemCopyWithImpl<$Res, _$_SearchResultItem>
    implements _$$_SearchResultItemCopyWith<$Res> {
  __$$_SearchResultItemCopyWithImpl(
    _$_SearchResultItem _value,
    $Res Function(_$_SearchResultItem) _then,
  ) : super(_value, _then);

  @override
  $Res call({Object? data = null, Object? type = null}) {
    return _then(
      _$_SearchResultItem(
        data:
            null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc

class _$_SearchResultItem implements _SearchResultItem {
  const _$_SearchResultItem({required this.data, required this.type});

  @override
  final Map<String, dynamic> data;
  @override
  final String type;

  @override
  String toString() {
    return 'SearchResultItem(data: $data, type: $type)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SearchResultItem &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data), type);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  _$$_SearchResultItemCopyWith<_$_SearchResultItem> get copyWith =>
      __$$_SearchResultItemCopyWithImpl<_$_SearchResultItem>(this, _$identity);
}

abstract class _SearchResultItem implements SearchResultItem {
  const factory _SearchResultItem({
    required Map<String, dynamic> data,
    required String type,
  }) = _$_SearchResultItem;

  @override
  Map<String, dynamic> get data;
  @override
  String get type;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$_SearchResultItemCopyWith<_$_SearchResultItem> get copyWith =>
      throw _privateConstructorUsedError;
}
