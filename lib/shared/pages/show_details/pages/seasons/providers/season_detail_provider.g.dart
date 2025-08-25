// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$seasonDetailHash() => r'649070c3f54774976348efa6410d20ff99f89dc7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SeasonDetail
    extends BuildlessAutoDisposeAsyncNotifier<SeasonDetails> {
  late final String showId;
  late final int seasonNumber;
  late final String? languageCode;

  FutureOr<SeasonDetails> build({
    required String showId,
    required int seasonNumber,
    String? languageCode,
  });
}

/// See also [SeasonDetail].
@ProviderFor(SeasonDetail)
const seasonDetailProvider = SeasonDetailFamily();

/// See also [SeasonDetail].
class SeasonDetailFamily extends Family<AsyncValue<SeasonDetails>> {
  /// See also [SeasonDetail].
  const SeasonDetailFamily();

  /// See also [SeasonDetail].
  SeasonDetailProvider call({
    required String showId,
    required int seasonNumber,
    String? languageCode,
  }) {
    return SeasonDetailProvider(
      showId: showId,
      seasonNumber: seasonNumber,
      languageCode: languageCode,
    );
  }

  @override
  SeasonDetailProvider getProviderOverride(
    covariant SeasonDetailProvider provider,
  ) {
    return call(
      showId: provider.showId,
      seasonNumber: provider.seasonNumber,
      languageCode: provider.languageCode,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'seasonDetailProvider';
}

/// See also [SeasonDetail].
class SeasonDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SeasonDetail, SeasonDetails> {
  /// See also [SeasonDetail].
  SeasonDetailProvider({
    required String showId,
    required int seasonNumber,
    String? languageCode,
  }) : this._internal(
         () =>
             SeasonDetail()
               ..showId = showId
               ..seasonNumber = seasonNumber
               ..languageCode = languageCode,
         from: seasonDetailProvider,
         name: r'seasonDetailProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$seasonDetailHash,
         dependencies: SeasonDetailFamily._dependencies,
         allTransitiveDependencies:
             SeasonDetailFamily._allTransitiveDependencies,
         showId: showId,
         seasonNumber: seasonNumber,
         languageCode: languageCode,
       );

  SeasonDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.showId,
    required this.seasonNumber,
    required this.languageCode,
  }) : super.internal();

  final String showId;
  final int seasonNumber;
  final String? languageCode;

  @override
  FutureOr<SeasonDetails> runNotifierBuild(covariant SeasonDetail notifier) {
    return notifier.build(
      showId: showId,
      seasonNumber: seasonNumber,
      languageCode: languageCode,
    );
  }

  @override
  Override overrideWith(SeasonDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: SeasonDetailProvider._internal(
        () =>
            create()
              ..showId = showId
              ..seasonNumber = seasonNumber
              ..languageCode = languageCode,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        showId: showId,
        seasonNumber: seasonNumber,
        languageCode: languageCode,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SeasonDetail, SeasonDetails>
  createElement() {
    return _SeasonDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeasonDetailProvider &&
        other.showId == showId &&
        other.seasonNumber == seasonNumber &&
        other.languageCode == languageCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, showId.hashCode);
    hash = _SystemHash.combine(hash, seasonNumber.hashCode);
    hash = _SystemHash.combine(hash, languageCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SeasonDetailRef on AutoDisposeAsyncNotifierProviderRef<SeasonDetails> {
  /// The parameter `showId` of this provider.
  String get showId;

  /// The parameter `seasonNumber` of this provider.
  int get seasonNumber;

  /// The parameter `languageCode` of this provider.
  String? get languageCode;
}

class _SeasonDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SeasonDetail, SeasonDetails>
    with SeasonDetailRef {
  _SeasonDetailProviderElement(super.provider);

  @override
  String get showId => (origin as SeasonDetailProvider).showId;
  @override
  int get seasonNumber => (origin as SeasonDetailProvider).seasonNumber;
  @override
  String? get languageCode => (origin as SeasonDetailProvider).languageCode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
