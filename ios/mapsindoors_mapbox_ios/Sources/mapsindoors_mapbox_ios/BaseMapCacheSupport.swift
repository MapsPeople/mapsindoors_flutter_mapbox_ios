import Foundation

/// Whether this build's map provider can cache base-map tiles.
///
/// Mapbox has an offline tile store, so base-map tiles can be cached into it.
///
/// This is a compile-time constant because the iOS SDK offers nothing to ask. `MapProviderBaseMapCache` has no `isBaseMapCachingSupported()`, and both adapters register a provider on map-provider init - Mapbox a real one, Google a no-op - so a non-nil `MPMapsIndoors.baseMapCacheProvider` says nothing about support. Declaring it per provider mirrors Android's `BaseMapCache.kt`, needs no `@_spi` import, and keeps `MapsIndoorsPlugin.swift` identical in both packages.
enum BaseMapCache {
    static let isSupported = true
}
