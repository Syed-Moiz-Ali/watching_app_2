import '../../data/models/scraper_config.dart';
import '../../data/scrapers/sources/manga/kissmanga.dart';
import '../../data/scrapers/sources/manga/manhwa18.dart';
import '../../data/scrapers/sources/photos/erowall.dart';
import '../../data/scrapers/sources/photos/peakpx.dart';
import '../../data/scrapers/sources/photos/pmatehunter.dart';
import '../../data/scrapers/sources/photos/wallpaper.mob.dart';
import '../../data/scrapers/sources/photos/wallpaperporn.dart';
import '../../data/scrapers/sources/videos/baddies.dart';
import '../../data/scrapers/sources/videos/crazyShit.dart';
import '../../data/scrapers/sources/videos/goodPorn.dart';
import '../../data/scrapers/sources/videos/hqporner.dart';
import '../../data/scrapers/sources/videos/noodlemagazine.dart';
import '../../data/scrapers/sources/videos/pimpbunny.dart';
import '../../data/scrapers/sources/pornhits.dart';
import '../../data/scrapers/sources/videos/spankbang.dart';
import '../../data/scrapers/sources/videos/sxyprn.dart';
import '../../data/scrapers/sources/videos/tabooporn2.dart';
import '../../data/scrapers/sources/videos/youjizz.dart';
import '../../data/models/content_source.dart';
import '../../data/scrapers/base_scraper.dart';

// Dummy Scraper class for handling null cases
class DummyScraper extends BaseScraper {
  DummyScraper(ContentSource source)
      : super(
          source,
          ScraperConfig(
            titleSelector: ElementSelector(),
            thumbnailSelector: ElementSelector(),
            contentUrlSelector: ElementSelector(),
            contentSelector: ElementSelector(),
          ),
        );
}

class ScraperFactory {
  static final Map<String, BaseScraper Function(ContentSource)> _scrapers = {
    //videos
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
    'sxyprn': (source) => SxyPrn(source),

    //wallpapers
    'pmatehunter': (source) => PMateHunter(source),
    'elitebabes': (source) => PMateHunter(source),
    'erowall': (source) => EroWall(source),
    'peakpx': (source) => PeakPx(source),
    'pxfuel': (source) => PeakPx(source),
    'wallpaperbetter': (source) => PeakPx(source),
    'wallpaper.mob': (source) => WallpaperMob(source),
    'wallpaperporn': (source) => WallpaperPorn(source),

    //manga
    'kissmanga': (source) => KissManga(source),
    'manhwa18': (source) => Manwha18(source),

    // Add more scrapers here
  };

  static BaseScraper createScraper(ContentSource source) {
    final builder = _scrapers[source.name.toLowerCase()];

    // Return a dummy scraper if the builder is null
    if (builder == null) {
      return DummyScraper(source);
    }
    return builder(source);
  }
}
