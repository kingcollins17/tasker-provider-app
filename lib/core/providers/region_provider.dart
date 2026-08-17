import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api.dart';
import '../models/models.dart';
import 'location_provider.dart';

/// Resolves the user's current [Region] by matching the device location's
/// state / administrative area against the list of regions returned from
/// the API.
///
/// Returns `null` if location cannot be determined, reverse-geocoding fails,
/// or no matching region is found.
final currentRegionProvider = FutureProvider<Region?>((ref) async {
  try {
    // 1. Get the user's current address from the location provider.
    final address = await ref.watch(userAddressProvider.future);
    
    final userState = address.administrativeArea?.toLowerCase().trim();
    final userLocality = address.locality?.toLowerCase().trim();

    if (userState == null && userLocality == null) return null;

    // 3. Fetch available regions from the API.
    final client = ref.read(usersClientProvider);
    final response = await client.getRegions();

    if (response.isError || response.data == null || response.data!.isEmpty) {
      return null;
    }

    final regions = response.data!;

    // 4. Match the user's state/locality against region fields.
    //    Priority: exact state match > address_line contains state >
    //              state contains locality.
    for (final region in regions) {
      final regionState = region.state?.toLowerCase().trim();
      final regionAddress = region.addressLine?.toLowerCase().trim();

      // Exact state match.
      if (regionState != null &&
          userState != null &&
          regionState == userState) {
        return region;
      }

      // Address line contains the user's state.
      if (regionAddress != null &&
          userState != null &&
          regionAddress.contains(userState)) {
        return region;
      }
    }

    // Fallback: looser match using locality.
    if (userLocality != null) {
      for (final region in regions) {
        final regionState = region.state?.toLowerCase().trim();
        final regionAddress = region.addressLine?.toLowerCase().trim();

        if (regionState != null && regionState.contains(userLocality)) {
          return region;
        }
        if (regionAddress != null && regionAddress.contains(userLocality)) {
          return region;
        }
      }
    }

    return null;
  } catch (_) {
    return null;
  }
});
