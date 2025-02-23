import 'package:html/dom.dart';

class ScraperConfig {
  final ElementSelector titleSelector;
  final ElementSelector thumbnailSelector;
  final ElementSelector contentUrlSelector;
  final ElementSelector previewSelector;
  final ElementSelector qualitySelector;
  final ElementSelector timeSelector;
  final ElementSelector durationSelector; // Added this line
  final ElementSelector watchingLinkSelector; // Added this line
  final ElementSelector keywordsSelector; // Added this line

  ScraperConfig({
    required this.titleSelector,
    required this.thumbnailSelector,
    required this.contentUrlSelector,
    required this.previewSelector,
    required this.qualitySelector,
    required this.timeSelector,
    required this.durationSelector, // Added this line
    required this.watchingLinkSelector, // Added this line
    required this.keywordsSelector, // Added this line
  });
}

class ElementSelector {
  final String? selector;
  final String? attribute;
  final Future<String> Function(Element)? customExtraction;

  ElementSelector({
    this.selector,
    this.attribute,
    this.customExtraction,
  });
}
