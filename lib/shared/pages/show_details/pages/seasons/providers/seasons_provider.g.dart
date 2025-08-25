// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seasons_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$seasonsHash() => r'9c95a5501afa96752b44d59202b3dda165038755';

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

/// See also [seasons].
@ProviderFor(seasons)
const seasonsProvider = SeasonsFamily();

/// See also [seasons].
class SeasonsFamily extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [seasons].
  const SeasonsFamily();

  /// See also [seasons].
  SeasonsProvider call({required String showId}) {
    return SeasonsProvider(showId: showId);
  }

  @override
  SeasonsProvider getProviderOverride(covariant SeasonsProvider provider) {
    return call(showId: provider.showId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'seasonsProvider';
}

/// See also [seasons].
class SeasonsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [seasons].
  SeasonsProvider({required String showId})
    : this._internal(
        (ref) => seasons(ref as SeasonsRef, showId: showId),
        from: seasonsProvider,
        name: r'seasonsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$seasonsHash,
        dependencies: SeasonsFamily._dependencies,
        allTransitiveDependencies: SeasonsFamily._allTransitiveDependencies,
        showId: showId,
      );

  SeasonsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.showId,
  }) : super.internal();

  final String showId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(SeasonsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeasonsProvider._internal(
        (ref) => create(ref as SeasonsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        showId: showId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _SeasonsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeasonsProvider && other.showId == showId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, showId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SeasonsRef on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `showId` of this provider.
  String get showId;
}

class _SeasonsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with SeasonsRef {
  _SeasonsProviderElement(super.provider);

  @override
  String get showId => (origin as SeasonsProvider).showId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
