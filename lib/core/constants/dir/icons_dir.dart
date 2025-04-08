/// Application asset paths for icons and images
///
/// This class provides centralized paths to assets,
/// making it easier to update them across the app.
class IconsDir {
  // Prevent instantiation
  IconsDir._();
  
  // Base paths
  static const String _basePath = 'assets/icons/';
  
  // Specific icons
  static const String busStop = '${_basePath}bus_stop_icon.png';
  static const String busMarker = '${_basePath}bus_marker.png';
  static const String refreshIcon = '${_basePath}refresh_icon.png';
  static const String locationPin = '${_basePath}location_pin.png';
}
