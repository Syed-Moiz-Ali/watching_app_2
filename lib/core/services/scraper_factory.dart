import 'package:flutter/foundation.dart';
import 'package:watching_app_2/data/models/content_source.dart';
import 'package:watching_app_2/data/scrapers/base_scraper.dart';
// Photo Scrapers
import '../../data/scrapers/sources/photos/definebabe.dart';
import '../../data/scrapers/sources/photos/erowall.dart';
import '../../data/scrapers/sources/photos/peakpx.dart';
import '../../data/scrapers/sources/photos/pmatehunter.dart';
import '../../data/scrapers/sources/photos/wallpaper.mob.dart';
import '../../data/scrapers/sources/photos/wallpaperporn.dart';
// Video Scrapers
import '../../data/scrapers/sources/videos/baddies.dart';
import '../../data/scrapers/sources/videos/bdsm.dart';
import '../../data/scrapers/sources/videos/bigfuck.dart';
import '../../data/scrapers/sources/videos/brazz.dart';
import '../../data/scrapers/sources/videos/collectionofbestporn.dart';
import '../../data/scrapers/sources/videos/crazyporn.dart';
import '../../data/scrapers/sources/videos/crazyshit.dart';
import '../../data/scrapers/sources/videos/eporner.dart';
import '../../data/scrapers/sources/videos/eroticmv.dart';
import '../../data/scrapers/sources/videos/goodporn.dart';
import '../../data/scrapers/sources/videos/hqporner.dart';
import '../../data/scrapers/sources/videos/interntchicks.dart';
import '../../data/scrapers/sources/videos/kompoz2.dart';
import '../../data/scrapers/sources/videos/netfapx.dart';
import '../../data/scrapers/sources/videos/noodlemagazine.dart';
import '../../data/scrapers/sources/videos/pandamovies.dart';
import '../../data/scrapers/sources/videos/pimpbunny.dart';
import '../../data/scrapers/sources/videos/pornhits.dart';
import '../../data/scrapers/sources/videos/porntop.dart';
import '../../data/scrapers/sources/videos/spankbang.dart';
import '../../data/scrapers/sources/videos/sxyprn.dart';
import '../../data/scrapers/sources/videos/taboohome.dart';
import '../../data/scrapers/sources/videos/tranny.dart';
import '../../data/scrapers/sources/videos/whoreshub.dart';
import '../../data/scrapers/sources/videos/xtapes.dart';
import '../../data/scrapers/sources/videos/youjizz.dart';

/// Enum representing supported content types for scrapers.
enum ContentType {
  videos,
  photos,
  tiktok,
}

/// Dummy scraper implementation for handling unsupported sources.
class DummyScraper extends BaseScraper {
  DummyScraper(super.source);
}

/// Factory class for creating scraper instances based on content source.
class ScraperFactory {
  /// Registry of scraper builders organized by content type.
  static final Map<ContentType,
      Map<String, BaseScraper Function(ContentSource)>> _scrapers = {
    ContentType.videos: {
      'spankbang': (source) => Spankbang(source),
      'noodlemagazine': (source) => NoodleMagazine(source),
      'ukdevilz': (source) => NoodleMagazine(source),
      'pornhits': (source) => PornHits(source),
      'tabooporn': (source) => GoodPorn(source),
      'hqporner': (source) => HQPorner(source),
      'crazyshit': (source) => CrazyShit(source),
      'onlyporn': (source) => PornHits(source),
      'youjizz': (source) => YouJizz(source),
      'pimpbunny': (source) => PimpBunny(source),
      'baddies': (source) => Baddies(source),
      'sxyprn': (source) => Sxyprn(source),
      'kompoz2': (source) => Kompoz2(source),
      'eroticmv': (source) => Eroticmv(source),
      'brazz': (source) => Brazz(source),
      'pornobae': (source) => Brazz(source),
      'collectionofbestporn': (source) => CollectionOfBestPorn(source),
      'bigfuck': (source) => Bigfuck(source),
      'xtapes': (source) => Xtapes(source),
      'netfapx': (source) => Netfapx(source),
      'slutvids': (source) => Netfapx(source),
      'milfnut': (source) => Netfapx(source),
      'watchporninpublic': (source) => Netfapx(source),
      'tranny': (source) => Tranny(source),
      'whorehub': (source) => WhoreHub(source),
      'porntop': (source) => Porntop(source),
      'crazyporn': (source) => Crazyporn(source),
      'bdsm': (source) => Bdsm(source),
      'pandamovies': (source) => Pandamovies(source),
      'interntchicks': (source) => Interntchicks(source),
      'taboohome': (source) => Taboohome(source),
      'eporner': (source) => Eporner(source),
    },
    ContentType.photos: {
      'pmatehunter': (source) => PMateHunter(source),
      'elitebabes': (source) => PMateHunter(source),
      'erowall': (source) => EroWall(source),
      'peakpx': (source) => PeakPx(source),
      'pxfuel': (source) => PeakPx(source),
      'wallpaperbetter': (source) => PeakPx(source),
      'wallpaper.mob': (source) => WallpaperMob(source),
      'wallpaperporn': (source) => WallpaperPorn(source),
      'definebabe': (source) => Definebabe(source),
    },
    ContentType.tiktok: {},
  };

  /// Creates an appropriate scraper instance for the given content source.
  ///
  /// [source] The content source to create a scraper for.
  /// Returns a [BaseScraper] instance, or [DummyScraper] if no matching scraper is found.
  static BaseScraper createScraper(ContentSource source) {
    final sourceName = source.name.toLowerCase();

    for (final category in _scrapers.entries) {
      final builder = category.value[sourceName];
      if (builder != null) {
        return builder(source);
      }
    }

    if (kDebugMode) {
      print('No scraper found for source: $sourceName');
    }
    return DummyScraper(source);
  }

  /// Returns a list of supported source names for a given content type.
  ///
  /// [contentType] The content type to query supported sources for.
  /// Returns a list of source names or an empty list if the content type is not supported.
  static List<String> getSupportedSources(ContentType contentType) {
    return _scrapers[contentType]?.keys.toList() ?? [];
  }

  /// Checks if a source name is supported by any scraper.
  ///
  /// [sourceName] The name of the source to check.
  /// Returns true if the source is supported, false otherwise.
  static bool isSourceSupported(String sourceName) {
    final lowerName = sourceName.toLowerCase();
    return _scrapers.values.any((category) => category.containsKey(lowerName));
  }
}
