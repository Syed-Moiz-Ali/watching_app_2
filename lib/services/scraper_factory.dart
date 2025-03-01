import 'package:watching_app_2/models/scraper_config.dart';

import '../core/extensions/photos/erowall/erowall.dart';
import '../core/extensions/photos/peakpx/peakpx.dart';
import '../core/extensions/photos/pmatehunter/pmatehunter.dart';
import '../core/extensions/photos/wallpaper.mob/wallpaper.mob.dart';
import '../core/extensions/photos/wallpaperporn/wallpaperporn.dart';
import '../core/extensions/videos/baddies/baddies.dart';
import '../core/extensions/videos/crazyShit/crazyShit.dart';
import '../core/extensions/videos/goodPorn/goodPorn.dart';
import '../core/extensions/videos/hqporner/hqporner.dart';
import '../core/extensions/videos/noodlemagazine/noodlemagazine.dart';
import '../core/extensions/videos/pimpbunny/pimpbunny.dart';
import '../core/extensions/videos/pornhits/pornhits.dart';
import '../core/extensions/videos/spankbang/spankbang.dart';
import '../core/extensions/videos/sxyprn/sxyprn.dart';
import '../core/extensions/videos/tabooporn2/tabooporn2.dart';
import '../core/extensions/videos/youjizz/youjizz.dart';
import '../models/content_source.dart';
import 'scrapers/base_scraper.dart';

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
