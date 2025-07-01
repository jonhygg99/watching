import 'package:freezed_annotation/freezed_annotation.dart';

part 'details_extras.freezed.dart';

@freezed
class ShowDetailsExtras with _$ShowDetailsExtras {
  const factory ShowDetailsExtras({
    required List<dynamic> videos,
    required Map<String, dynamic>? people,
    required List<dynamic> relatedShows,
  }) = _ShowDetailsExtras;
}
