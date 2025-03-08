import 'package:watching_app_2/data/models/scraper_config.dart';

import '../repository/photos/elitebabe.dart';
import '../repository/photos/erowall/erowall.dart';
import '../repository/photos/peakpx/peakpx.dart';
import '../repository/photos/pmatehunter/pmatehunter.dart';
import '../repository/photos/wallpaper.mob/wallpaper.mob.dart';
import '../repository/photos/wallpaperporn/wallpaperporn.dart';
import '../repository/videos/baddies/baddies.dart';
import '../repository/videos/crazyShit/crazyShit.dart';
import '../repository/videos/goodPorn/goodPorn.dart';
import '../repository/videos/hqporner/hqporner.dart';
import '../repository/videos/noodlemagazine/noodlemagazine.dart';
import '../repository/videos/pimpbunny/pimpbunny.dart';
import '../repository/videos/pornhits/pornhits.dart';
import '../repository/videos/spankbang/spankbang.dart';
import '../repository/videos/sxyprn/sxyprn.dart';
import '../repository/videos/tabooporn2/tabooporn2.dart';
import '../repository/videos/youjizz/youjizz.dart';
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
    'elitebabes': (source) => EliteBabe(source),
    'erowall': (source) => EroWall(source),
    'peakpx': (source) => PeakPx(source),
    'pxfuel': (source) => PeakPx(source),
    'wallpaperbetter': (source) => PeakPx(source),
    'wallpaper.mob': (source) => WallpaperMob(source),
    'wallpaperporn': (source) => WallpaperPorn(source),

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
