import 'package:watching_app_2/core/extensions/photos/erowall/erowall.dart';
import 'package:watching_app_2/core/extensions/photos/pmatehunter/pmatehunter.dart';
import 'package:watching_app_2/core/extensions/videos/crazyShit/crazyShit.dart';
import 'package:watching_app_2/core/extensions/videos/goodPorn/goodPorn.dart';
import 'package:watching_app_2/core/extensions/videos/hqporner/hqporner.dart';
import 'package:watching_app_2/core/extensions/videos/tabooporn2/tabooporn2.dart';
import 'package:watching_app_2/core/navigation/navigator.dart';
import 'package:watching_app_2/widgets/error_page.dart';

import '../core/extensions/photos/peakpx/peakpx.dart';
import '../core/extensions/videos/noodlemagazine/noodlemagazine.dart';
import '../core/extensions/videos/pornhits/pornhits.dart';
import '../core/extensions/videos/spankbang/spankbang.dart';
import '../models/content_source.dart';
import 'scrapers/base_scraper.dart';

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

    //wallpapers
    'pmatehunter': (source) => PMateHunter(source),
    'erowall': (source) => EroWall(source),
    'peakpx': (source) => PeakPx(source),
    // Add more scrapers here
  };

  static BaseScraper createScraper(ContentSource source) {
    final builder = _scrapers[source.name.toLowerCase()];
    if (builder == null) {
      // NH.navigateTo(ErrorPage(
      //     errorMessage: 'No scraper implemented for source: ${source.name}'));
      throw Exception('No scraper implemented for source: ${source.name}');
    }
    return builder(source);
  }
}
