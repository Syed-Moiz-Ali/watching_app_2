import 'package:watching_app_2/core/extensions/videos/crazyShit/crazyShit.dart';
import 'package:watching_app_2/core/extensions/videos/goodPorn/goodPorn.dart';
import 'package:watching_app_2/core/extensions/videos/hqporner/hqporner.dart';
import 'package:watching_app_2/core/extensions/videos/tabooporn2/tabooporn2.dart';

import '../core/extensions/videos/noodlemagazine/noodlemagazine.dart';
import '../core/extensions/videos/pornhits/pornhits.dart';
import '../core/extensions/videos/spankbang/spankbang.dart';
import '../models/content_source.dart';
import 'scrapers/base_scraper.dart';

class ScraperFactory {
  static final Map<String, BaseScraper Function(ContentSource)> _scrapers = {
    'spankbang': (source) => Spankbang(source),
    'noodlemagazine': (source) => NoodleMagazine(source),
    'ukdevilz': (source) => NoodleMagazine(source),
    'pornhits': (source) => PornHits(source),
    'tabooporn': (source) => GoodPorn(source),
    'hqporner': (source) => HQPorner(source),
    'tabooporn2': (source) => Tabooporn2(source),
    'crazyshit': (source) => CrazyShit(source),
    // Add more scrapers here
  };

  static BaseScraper createScraper(ContentSource source) {
    final builder = _scrapers[source.name.toLowerCase()];
    if (builder == null) {
      throw Exception('No scraper implemented for source: ${source.name}');
    }
    return builder(source);
  }
}
