import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'assets/css/mainStyle.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (c)=> Store1()),
          ChangeNotifierProvider(create: (c)=> Store2()),
        ],//STORE를 사용하기 위해서는 사용하고자 하는 위젯에 ChangeNotifierProvider로 감싸줘야함
        child: MaterialApp( //MaterialApp()의 자식 위젯들은 Store1에 있는 모든 state 사용 가능함
            theme: style.theme,
            home : MyApp()
          // 라우터 설정 샘플예시
          // initialRoute: '/',
          // routes: {
          //   '/': (c) => MyApp(),
          //   '/detail' : (c) => Text('둘째페이지')
          // },
        ),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  var tab = 0;
  var data = [];
  var userImage;
  var userContent;

  // saveData() async { //SharedPreferences 사용법
  //   var storage = await SharedPreferences.getInstance();
  //   storage.setString('name', 'john');
  //   storage.setStringList('bool', ['test', 'test2']);
  //   storage.remove('name');
  //   var result = storage.getBool('name');
  //   print(result);
  //
  //   var map = {'age':20}; //Map 형태는 Json으로 인코딩 해줘야함
  //   storage.setString('map', jsonEncode(map));
  //   var result = storage.get('map');
  //   print(jsonDecode(reuslt)['age']);
  // }

  addMyData(){
    var myData = {
      'id': data.length,
      'image': userImage,
      'likes': 5,
      'date': 'July 25',
      'content': userContent,
      'liked': false,
      'user': 'John Kim'
    };
    setState(() {
      data.insert(0, myData);
    });
  }

  setUserContent(a){
    setState(() {
      userContent = a;
    });
  }

  @override
  void initState() {
    super.initState();
    // saveData();
    getData();
  }

  addData(a){
    setState(() {
      data.add(a);
    });
  }

  getData() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    var result2 = jsonDecode(result.body);
    setState((){
      data = result2;
    });

    if (result.statusCode == 200) {
      print( jsonDecode(result.body) );
    } else {
      throw Exception('실패함ㅅㄱ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram'),
        actions: [
          IconButton(
              icon: Icon(Icons.add_box_outlined),
              onPressed: () async {
                var picker = ImagePicker();
                var image = await picker.pickImage(source: ImageSource.gallery); //ImageSource.camera); 카메라 실행
                //picker.pickVideo() 비디오 실행 위젯
                //picker.pickMultiImage() 이미지 다중 선택
                if(image != null){
                 setState(() {
                   userImage = File(image.path);
                 });
                }
                
                Navigator.push(context,
                  MaterialPageRoute(builder: (c) => Upload(
                      userImage : userImage,
                      setUserContent : setUserContent,
                      addMyData : addMyData,
                  ))
                );
              },
              iconSize: 30,
          )
        ],
      ),
      body: [Home(data : data, addData: addData), Text('샵페이지')][tab],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i){
          setState((){
            tab = i;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: '샵'),
        ],
      )
    );
  }
}

class Upload extends StatelessWidget {
  const Upload({Key? key, this.userImage, this.setUserContent , this.addMyData }) : super(key : key);
  final userImage;
  final setUserContent;
  final addMyData;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar( actions: [
        IconButton(onPressed: (){
          addMyData();
        }, icon: Icon(Icons.send))
      ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(userImage),
          Text('이미지 업로드 화면'),
          TextField(onChanged: (text){
            setUserContent(text);
          },),
          IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(Icons.close)
          ),
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key, this.data, this.addData}) : super(key: key);
  final data;
  final addData;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      // print(scroll.position.pixels); // 스크롤바 내린 높이, 최상단:0 / 최하단: 화면높이
      // print(scroll.position.maxScrollExtent); // 스크롤바 최대내릴 수 있는 높이
      // print(scroll.position.userScrollDirection); // 스크롤되는 방향
      if(scroll.position.pixels == scroll.position.maxScrollExtent){
        getMore();
      }
    });
  }

  getMore() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
    var result2 = jsonDecode(result.body);
    widget.addData(result2);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.data.isNotEmpty){
      return ListView.builder(itemCount: widget.data.length, controller: scroll, itemBuilder: (c, i){
        return Column(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 600),
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image.network(widget.data[i]['image']),
                  widget.data[i]['image'].runtimeType == String
                      ? Image.network(widget.data[i]['image'])
                      : Image.file(widget.data[i]['image']),

                  GestureDetector(
                    child: Text(widget.data[i]['user']),
                    onTap: (){
                      Navigator.push(context,
                          // CupertinoPageRoute(builder: (c) => Profile()) //페이지 슬라이드 애니메이션
                          PageRouteBuilder(
                              pageBuilder: (c, a1, a2) => Profile(),
                              transitionsBuilder: (c, a1, a2, child) => //c=context / a1,2=animation object(페이지 전환 진행현황 표시 0~1), a1=새로운페이지, a2=기존보이던 페이지 진행현황 / child=새로띄울 페이지 ex) Profile()
                                  FadeTransition(opacity: a1, child: child), //애니메이션 위젯종류 기입, 종류: Fade, Positioned Scale, RotationTransition
                              transitionDuration: Duration(milliseconds: 250) //애니메이션 속도조절
                              // SlideTransition(
                              //   position: Tween(
                              //     begin: Offset(-1.0, 0.0),
                              //     end: Offset(0.0, 0.0),
                              //   ).animate(a1),
                              //   child: child,
                              // ) //또 다른 슬라이드 위젯, FadeTransition위젯 대신 넣으면 사용가능
                          )
                      );
                    },
                  ),
                  Text('좋아요 ${widget.data[i]['likes']}'),
                  Text(widget.data[i]['date']),
                  Text(widget.data[i]['content']),
                ],
              ),
            )
          ],
        );
      });
    } else {
      return CircularProgressIndicator();
    }
  }
}

class Store2 extends ChangeNotifier{
  var name = 'john kim';
}

class Store1 extends ChangeNotifier{
  var friend = false;
  var follower = 9;
  var profileImage = [];

  getData() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result2 = jsonDecode(result.body);
    profileImage = result2;
    notifyListeners();
  }

  addFollower(){
    if (friend == false) {
      follower++;
      friend = true;
    } else {
      follower--;
      friend = false;
    }
    notifyListeners();
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.watch<Store2>().name),),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
          ),
          Text('팔로워 ${context.watch<Store1>().follower}명'),
          // ElevatedButton(onPressed: (){
          //   context.read<Store1>().changeName(); //store 저장된 state값 변경 : store class안에 변경함수 생성, 그 함수를 실행하여 값을 변경함. store에 있는 변수값을 store 밖에서 변경 시 버그의 원인됨.
          // }, child: Text('버튼'))
          ElevatedButton(onPressed:(){
            context.read<Store1>().addFollower();
          }, child: Text('팔로우')),
          ElevatedButton(onPressed:(){
            context.read<Store1>().getData();
          }, child: Text('사진가져오기')),
        ],
      ),
    );
  }
}




