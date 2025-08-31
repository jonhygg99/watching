import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:watching/api/trakt/trakt_api.dart';

part 'trakt_api_provider.g.dart';

/// Provides the TraktApi instance to the app.
@riverpod
TraktApi traktApi(Ref ref) {
  return TraktApi();
}
