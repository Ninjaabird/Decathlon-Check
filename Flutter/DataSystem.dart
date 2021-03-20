
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class DataSystem extends DataSystemBase {

  static Future<List<LinkData>> getLinkData() async {
    List<LinkData> datas=[];
    String data=await DataSystemBase.loadData("/linkData.bn");
    String string=data.substring(1,data.length-1);
    List<String> obj =string.split("},");
    for(String item in obj) {
      if(!item.contains("}")) item+="}";
      datas.add(LinkData.FromJson(item));
    }
    return datas;
  }

  static Future<bool> setLinkData(List<LinkData> data) async {
    String string;
    List<String> datas=[];
    for (LinkData item in data) {
      datas.add(LinkData.ToJson(item));
    }
    string=datas.toString();
    return DataSystemBase.saveData(string, "/linkData.bn");
  }
}

abstract class DataSystemBase {
  @protected
  static Future<bool> saveData(String val,String fileName) async {
    try {
      File file = await localFile(fileName);
      List<int> data=utf8.encoder.convert(val);
      await file.writeAsBytes(data);
      return true;
    }
    catch(e) {
      log(e);
      return false;
    }
  }
  @protected
  // ignore: missing_return
  static Future<String> loadData<T>(String fileName) async {
    try {
      if(await (await localFile(fileName)).exists()) {
        File file = await localFile(fileName);
        List<int> data= await file.readAsBytes();
        return String.fromCharCodes(data);
      }
      else return "";
    }
    catch(e) {
    }
  }
  @protected
  static Future<File> localFile(String fileName) async {
    final path = await localPath();
    return new File(path + fileName);
  }
  @protected
  static Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

class LinkData {
  String name="";
  String link="";

  LinkData();

  LinkData.FromJson(String data) {
    var obj=jsonDecode(data);
    this.name=obj["name"];
    this.link=obj["link"];
  }

  static String ToJson(LinkData data) {
    Map<String,String> obj=new Map<String,String>();
    obj["name"]=data.name;
    obj["link"]=data.link;
    return jsonEncode(obj);
  }
}