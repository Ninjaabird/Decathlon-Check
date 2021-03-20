import 'package:google_fonts/google_fonts.dart';

import 'package:decathlon_check/Utils.dart';
import 'package:flutter/material.dart';

import 'DataSystem.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DecathlonCheck',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Decathlon Check'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<LinkData> data=[];

  bool waiting=false;

  TextEditingController controller=new TextEditingController();

  void initState() {
    super.initState();
    DataSystem.getLinkData().then((value) {
     setState(() {
       data=value;
     });
    });
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child:Container(
            width: size.width,
            height: size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(top:size.height*0.02),
                  height: size.height*0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        child: Text("Aggiungi un articolo",style:GoogleFonts.aBeeZee(fontSize: 25,fontWeight: FontWeight.w600,color: Colors.black87)),
                      ),
                      Container(
                        width: size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: size.width*0.7,
                              child: TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: "Link",
                                  labelStyle: GoogleFonts.aBeeZee(fontSize: 18,fontWeight: FontWeight.w600),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            waiting?
                            Container(
                              child: CircularProgressIndicator(),
                            )
                                :Container(
                              child: ElevatedButton(
                                child: Text("Salva",style:GoogleFonts.aBeeZee(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.white)),
                                onPressed: () =>SaveLink(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: size.width,
                  height: size.height*0.05,
                  margin: EdgeInsets.all(10),
                  child: Text("I tuoi articoli",style:GoogleFonts.aBeeZee(fontSize: 25,fontWeight: FontWeight.w600,color: Colors.black87),textAlign: TextAlign.start,),
                ),
                 Container(
                      width: size.width,
                      height: size.height*0.55,
                      child: ListView(
                        children: FutureDatas(size),
                      ),
                    )
              ],
            ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }


  List<Widget> FutureDatas(Size size) {
    List<Widget> list=[];
    for(LinkData item in data) {
      list.add(SingleLine(item,size));
    }
    return list;
  }


  Widget SingleLine(LinkData data,Size size) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: size.width*0.6,
                child: Text(data.name,style:GoogleFonts.aBeeZee(fontSize: 14,color: Colors.black87),maxLines: 4,),
              ),
              OutlinedButton(
                  onPressed: () => DeleteData(data),
                  child: Text("Elimina",style:GoogleFonts.aBeeZee(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.blue))
              )
            ],
          ),
          Divider(
            color: Colors.blue,
            thickness: 2,
          ),
        ],
      ),
    );
  }


  void SaveLink() async {
    if(!waiting) {
      setState(() {
        waiting=true;
      });
      LinkData linkData=new LinkData();
      linkData.link=controller.text;
      linkData.name=await Utils.SearchForNameInDecathlon(linkData);
      setState(() {
        this.data.add(linkData);
      });
      await DataSystem.setLinkData(this.data);
      setState(() {
        controller.text="";
        waiting=false;
      });
    }
  }


  void DeleteData(LinkData data) async{
    setState(() {
      this.data.remove(data);
    });
    await DataSystem.setLinkData(this.data);
  }
}
