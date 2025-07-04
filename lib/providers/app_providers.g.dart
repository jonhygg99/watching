// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$traktApiHash() => r'e14225c86ddd24ee5b8c37a9ff04e988e59dbc11';

/// Provides a singleton instance of [TraktApi].
///
/// Copied from [traktApi].
@ProviderFor(traktApi)
final traktApiProvider = AutoDisposeProvider<TraktApi>.internal(
  traktApi,
  name: r'traktApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$traktApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TraktApiRef = AutoDisposeProviderRef<TraktApi>;
String _$countryCodeHash() => r'5e037e6406dd2c5e562d42464aaad7a6c2ce9577';

/// Provides the user's selected country code, persisted in SharedPreferences.
///
/// Copied from [CountryCode].
@ProviderFor(CountryCode)
final countryCodeProvider =
    AutoDisposeNotifierProvider<CountryCode, String>.internal(
      CountryCode.new,
      name: r'countryCodeProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$countryCodeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CountryCode = AutoDisposeNotifier<String>;
String _$usernameHash() => r'9b7fc1974d8185ee3779b54e36ef98a5a9f03849';

/// Provides the current username (null if not authenticated).
///
/// Copied from [Username].
@ProviderFor(Username)
final usernameProvider =
    AutoDisposeNotifierProvider<Username, String?>.internal(
      Username.new,
      name: r'usernameProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product') ? null : _$usernameHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Username = AutoDisposeNotifier<String?>;
String _$navIndexHash() => r'ce3728813a4c87041ffb09c0b5f6eeaea57a0bf3';

/// Provides the selected bottom navigation index.
///
/// Copied from [NavIndex].
@ProviderFor(NavIndex)
final navIndexProvider = AutoDisposeNotifierProvider<NavIndex, int>.internal(
  NavIndex.new,
  name: r'navIndexProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$navIndexHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NavIndex = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
