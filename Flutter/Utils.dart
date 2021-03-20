import 'package:decathlon_check/DataSystem.dart';
import 'package:http/http.dart' as http;

class Utils {

  static String search="disabled cta-v2--disabled";

  static Future<String> SearchForNameInDecathlon(LinkData data) async{
    Uri url=Uri.parse(data.link);
    String html=await _ReadHTLM(url);
    return _FindPatternInHTML(html, '<h1 class="title--main product-title-right">','</h1>');
  }

  // ignore: non_constant_identifier_names
  static _FindPatternInHTML(String file,String patternStart,String patternEnd) {
    int start=file.indexOf(patternStart);
    int end=file.indexOf(patternEnd,file.indexOf(patternStart));
    String val = file.substring(start,end).split(patternStart)[1];
    return val;
  }
  // ignore: non_constant_identifier_names
  static Future<String> _ReadHTLM(Uri url) async{
    return await http.read(url);
  }
}