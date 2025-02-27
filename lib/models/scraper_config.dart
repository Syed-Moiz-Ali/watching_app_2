import 'package:html/dom.dart';

class ScraperConfig {
  final ElementSelector? contentSelector; // Added this line
  final ElementSelector titleSelector;
  final ElementSelector thumbnailSelector;
  final ElementSelector contentUrlSelector;
  final ElementSelector? previewSelector;
  final ElementSelector? qualitySelector;
  final ElementSelector? timeSelector;
  final ElementSelector? durationSelector; // Added this line
  final ElementSelector? watchingLinkSelector; // Added this line
  final ElementSelector? videoSelector; // Added this line
  final ElementSelector? keywordsSelector; // Added this line
  final ElementSelector? similarContentSelector; // Added this line

  ScraperConfig({
    required this.titleSelector,
    required this.thumbnailSelector,
    required this.contentUrlSelector,
    this.previewSelector,
    this.qualitySelector,
    this.timeSelector,
    this.durationSelector, // Added this line
    this.watchingLinkSelector, // Added this line
    this.keywordsSelector, // Added this line
    this.similarContentSelector, // New parameter
    required this.contentSelector,
    this.videoSelector,
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
