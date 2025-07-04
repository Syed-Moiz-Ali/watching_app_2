// import 'package:html/dom.dart';

// import '../../../models/content_source.dart';
// import '../../../models/scraper_config.dart';
// import '../../base_scraper.dart';

// class KissManga extends BaseScraper {
//   KissManga(ContentSource source)
//       : super(
//           source,
//           ScraperConfig(
//             titleSelector: ElementSelector(
//               selector: '.col-md-2 > .tab-thumb > a ',
//               attribute: 'title', // Extract title from 'title' attribute
//             ),
//             thumbnailSelector: ElementSelector(
//                 customExtraction: (Element element) {
//                   var srcset = element
//                       .querySelector('.col-md-2 > .tab-thumb > a > img')
//                       ?.attributes['srcset'];

//                   var imageUrl = '';
//                   if (srcset != null) {
//                     // Split the srcset attribute by comma to get individual sources
//                     var sources = srcset.split(', ');
//                     if (sources.isNotEmpty) {
//                       // Get the first source
//                       var firstSource = sources.first;
//                       // Split the first source by space to get the URL and size
//                       var parts = firstSource.split(' ');
//                       if (parts.length >= 2) {
//                         // The URL is the first part
//                         imageUrl = parts[0];
//                       }
//                     }
//                   } else {
//                     imageUrl = element
//                             .querySelector('figure > a > img')
//                             ?.attributes['data-src'] ??
//                         '';
//                   }
//                   // log('image is $imageUrl');
//                   return Future.value(imageUrl.trim());
//                 },
//                 ),
//             contentUrlSelector: ElementSelector(
//               selector: '.col-md-2 > .tab-thumb > a',
//               attribute: 'href', // Extract content URL from 'href' attribute
//             ),
//             contentSelector: ElementSelector(
//               selector:
//                   '.tab-content-wrap > .c-tabs-item > .page-content-listing',
//             ),
//             // similarContentSelector: ElementSelector(
//             //   selector: '.user_uploads > .video-list > .video-item',
//             // ),
//           ),
//         );
// }
