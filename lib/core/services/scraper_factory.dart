import 'package:watching_app_2/data/models/content_source.dart';
import 'package:watching_app_2/data/models/scraper_config.dart';
import 'package:watching_app_2/data/scrapers/base_scraper.dart';
// Photo Scrapers
import '../../data/scrapers/sources/photos/definebabe.dart';
import '../../data/scrapers/sources/photos/erowall.dart';
import '../../data/scrapers/sources/photos/peakpx.dart';
import '../../data/scrapers/sources/photos/pmatehunter.dart';
import '../../data/scrapers/sources/photos/wallpaper.mob.dart';
import '../../data/scrapers/sources/photos/wallpaperporn.dart';
import '../../data/scrapers/sources/videos/pandamovies.dart';
import '../../data/scrapers/sources/videos/baddies.dart';
import '../../data/scrapers/sources/videos/bdsm.dart';
import '../../data/scrapers/sources/videos/bigfuck.dart';
import '../../data/scrapers/sources/videos/brazz.dart';
import '../../data/scrapers/sources/videos/collectionofbestporn.dart';
import '../../data/scrapers/sources/videos/crazyshit.dart';
import '../../data/scrapers/sources/videos/eporner.dart';
import '../../data/scrapers/sources/videos/eroticmv.dart';
import '../../data/scrapers/sources/videos/goodporn.dart';
import '../../data/scrapers/sources/videos/hqporner.dart';
import '../../data/scrapers/sources/videos/interntchicks.dart';
import '../../data/scrapers/sources/videos/kompoz2.dart';
import '../../data/scrapers/sources/videos/netfapx.dart';
import '../../data/scrapers/sources/videos/noodlemagazine.dart';
import '../../data/scrapers/sources/videos/pimpbunny.dart';
import '../../data/scrapers/sources/videos/pornhits.dart';
import '../../data/scrapers/sources/videos/porntop.dart';
import '../../data/scrapers/sources/videos/spankbang.dart';
import '../../data/scrapers/sources/videos/sxyprn.dart';
import '../../data/scrapers/sources/videos/taboohome.dart';
import '../../data/scrapers/sources/videos/tabooporn2.dart';
import '../../data/scrapers/sources/videos/tranny.dart';
import '../../data/scrapers/sources/videos/whoreshub.dart';
import '../../data/scrapers/sources/videos/xtapes.dart';
import '../../data/scrapers/sources/videos/youjizz.dart';

// Manga Scrapers
import '../../data/scrapers/sources/manga/kissmanga.dart';
import '../../data/scrapers/sources/manga/manhwa18.dart';

/// Dummy Scraper class for handling null cases
class DummyScraper extends BaseScraper {
  DummyScraper(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: source.config!.titleSelector,
            thumbnailSelector: source.config!.thumbnailSelector,
            contentUrlSelector: source.config!.contentUrlSelector,
            contentSelector: source.config!.contentSelector,
            videoSelector: source.config!.videoSelector,
          ),
        );
}

/// Factory class for creating scraper instances based on content source
class ScraperFactory {
  /// Registry of scraper builders organized by content type
  static final Map<String, Map<String, BaseScraper Function(ContentSource)>>
      _scrapers = {
    'videos': {
      'spankbang': (source) => Spankbang(source),
      'noodlemagazine': (source) => NoodleMagazine(source),
      'ukdevilz': (source) => NoodleMagazine(source),
      'pornhits': (source) => PornHits(source),
      'tabooporn': (source) => GoodPorn(source),
      'hqporner': (source) => HQPorner(source),
      'tabooporn2': (source) => Tabooporn2(source),
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
      'bdsm': (source) => Bdsm(source),
      'pandamovies': (source) => Pandamovies(source),
      'interntchicks': (source) => Interntchicks(source),
      'taboohome': (source) => Taboohome(source),
      'eporner': (source) => Eporner(source),
    },
    'photos': {
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
    'manga': {
      'kissmanga': (source) => KissManga(source),
      'manhwa18': (source) => Manwha18(source),
    },
    'tiktok': {
      // 'tikporn': (source) => TikPorn(source),
      // 'xxxfollow': (source) => Xxxfollow(source),
    }
  };

  /// Creates an appropriate scraper instance for the given content source
  static BaseScraper createScraper(ContentSource source) {
    final String sourceName = source.name.toLowerCase();

    // Search through all content type categories
    for (final category in _scrapers.values) {
      final builder = category[sourceName];
      if (builder != null) {
        return builder(source);
      }
    }

    // Return dummy scraper if no match found
    return DummyScraper(source);
  }

  /// Returns list of supported source names for a given content type
  static List<String> getSupportedSources(String contentType) {
    return _scrapers[contentType]?.keys.toList() ?? [];
  }

  /// Checks if a source name is supported
  static bool isSourceSupported(String sourceName) {
    final lowerName = sourceName.toLowerCase();
    return _scrapers.values.any((category) => category.containsKey(lowerName));
  }
}
