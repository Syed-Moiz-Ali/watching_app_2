import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:watching_app_2/models/content_source.dart';

class SourceBySearchData extends StatefulWidget {
  final ContentSource source;
  const SourceBySearchData({super.key, required this.source});

  @override
  State<SourceBySearchData> createState() => _SourceBySearchDataState();
}

class _SourceBySearchDataState extends State<SourceBySearchData> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
