import 'package:anti_food_waste_app/features/charity/data/sources/charity_remote_source.dart';
import 'package:anti_food_waste_app/features/charity/domain/models/charity_models.dart';

class CharityRepository {
  final CharityRemoteSource _remoteSource;

  CharityRepository({required CharityRemoteSource remoteSource})
      : _remoteSource = remoteSource;

  /// Fetch all available donations (and maybe ones assigned to this charity)
  Future<List<CharityDonation>> getDonations() async {
    final data = await _remoteSource.fetchDonations();
    return data.map((json) => CharityDonation.fromJson(json)).toList();
  }

  /// Get details for a single donation
  Future<CharityDonation> getDonationDetail(String id) async {
    final data = await _remoteSource.fetchDonationDetail(id);
    return CharityDonation.fromJsonDetail(data); // special constructor for detailed fields if needed
  }

  /// Send a pickup request
  Future<void> requestDonation(String donationId, String notes) async {
    await _remoteSource.requestDonation(donationId, notes);
  }

  /// Fetch pickup requests (Optional fallback depending on backend support)
  Future<List<CharityPickupRequest>> getMyPickupRequests() async {
    final data = await _remoteSource.fetchMyRequests();
    return data.map((json) => CharityPickupRequest.fromJson(json)).toList();
  }
}
