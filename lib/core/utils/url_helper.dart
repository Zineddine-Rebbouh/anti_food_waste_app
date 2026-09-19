import 'package:anti_food_waste_app/core/config/app_config.dart';

/// Normalises a raw URL returned by the Django backend so it is always
/// reachable from the current device.
///
/// Django's `ImageField` serialises media URLs using `request.build_absolute_uri`,
/// which embeds the **server's** host/port (e.g. `http://192.168.104.136:8000/media/…`).
/// When the app is configured with a different `BASE_URL` (emulator, different
/// subnet, staging…) those embedded hosts are unreachable.
///
/// This helper always replaces the scheme + host + port of any HTTP URL with
/// the origin from [AppConfig.baseUrl], keeping only the path & query intact.
/// External CDN URLs (e.g. Unsplash, Cloudinary) are left untouched because
/// they are not served by the Django instance.
class UrlHelper {
  UrlHelper._();

  /// The known broken Unsplash photo IDs from legacy mock data.
  static const _brokenUnsplashIds = [
    'photo-1610832958506-aa56338406cd',
    'photo-1550583724-125581f77833',
  ];

  /// A safe placeholder used when an image URL is known-broken.
  static const _placeholder =
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800';

  /// Returns the scheme + host + port of the configured backend, e.g.
  /// `http://192.168.104.136:8000`.
  static String get _backendOrigin =>
      AppConfig.baseUrl.split('/api/').first;

  /// Normalises [url] so it points to the currently configured backend.
  ///
  /// Rules (applied in order):
  /// 1. Empty → empty string.
  /// 2. Known-broken Unsplash ID → [_placeholder].
  /// 3. Already an external CDN URL (unsplash.com, cloudinary.com, …) → keep.
  /// 4. Full `http(s)://` URL from the backend → replace origin with [_backendOrigin].
  /// 5. Relative path → prepend [_backendOrigin].
  static String normalize(String? url) {
    if (url == null || url.isEmpty) return '';

    // 1. Known-broken Unsplash placeholder
    for (final id in _brokenUnsplashIds) {
      if (url.contains(id)) return _placeholder;
    }

    if (url.contains('source.unsplash.com')) {
      return _placeholder;
    }

    // 2. Fully-qualified external CDN → keep as-is
    if (_isExternalCdn(url)) return url;

    // 3. Full URL (any host) – replace just the origin
    if (url.startsWith('http://') || url.startsWith('https://')) {
      try {
        final uri = Uri.parse(url);
        return '$_backendOrigin${uri.path}'
            '${uri.query.isNotEmpty ? '?${uri.query}' : ''}';
      } catch (_) {
        return url; // malformed – return as-is
      }
    }

    // 4. Relative path
    final clean = url.startsWith('/') ? url : '/$url';
    return '$_backendOrigin$clean';
  }

  /// Returns true when the URL belongs to a known external CDN that the
  /// Django instance has no control over.
  static bool _isExternalCdn(String url) {
    const externalHosts = [
      'unsplash.com',
      'res.cloudinary.com',
      'cdn.',
      'amazonaws.com',
      'googleusercontent.com',
      'storage.googleapis.com',
    ];
    return externalHosts.any((h) => url.contains(h));
  }
}
