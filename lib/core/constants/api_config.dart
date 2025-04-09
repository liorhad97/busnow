/// Configuration for the Israeli Bus API
class BusApiConfig {
  /// The base URL for the API
  static const String apiUrl = 'https://api.bus.gov.il/v1/buses';

  /// API key placeholder - replace this with your actual API key
  static const String apiKey = 'YOUR_API_KEY_HERE';

  /// Whether to use the real-time API (set to false to use local data only)
  static const bool useRealTimeApi = false;
}
