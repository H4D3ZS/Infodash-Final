// ignore_for_file: no_logic_in_create_state, prefer__ructors, avoid_unnecessary_containers, non_ant_identifier_names, unused_local_variable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../infodashlib/news.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _HomePageState(title);
}

class _HomePageState extends State<HomePage> {
  _HomePageState(this.title);
  final String title;
  late Future<News> myNews;
  late Future<List<News>> newsList;
  @override
  void initState() {
    super.initState();
    // myNews = GetNews();
    newsList = GetNewsList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
      Container(
          margin: const EdgeInsets.only(left: 20, top: 20),
          child: const Row(
            children: [
              Text("NEWS",
                  style: TextStyle(
                      decorationThickness: 2.85,
                      fontWeight: FontWeight.bold,
                      fontSize: 40),
                  textAlign: TextAlign.left),
            ],
          )),
      SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: SingleChildScrollView(
            child: FutureBuilder<List<News>>(
              future: newsList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height / 2,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 10),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                    ),
                    items: snapshot.data!.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return SingleChildScrollView(
                              //width: MediaQuery.of(context).size.width,
                              //margin: EdgeInsets.symmetric(horizontal: 5.0),
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                i.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Image(
                                image: NetworkImage(i.media),
                                height: MediaQuery.of(context).size.height / 2,
                                errorBuilder: (context, error, stackTrace) => Image(
                                    image: const NetworkImage(
                                        'https://www.trendsetter.com/pub/media/catalog/product/placeholder/default/no_image_placeholder.jpg'),
                                    height:
                                        MediaQuery.of(context).size.height / 2 -
                                            10),
                              ),
                              InkWell(
                                child: const Text("Read Full Article",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue)),
                                onTap: () async {
                                  final url = i.link.toString();
                                  // ignore: deprecated_member_use
                                  await launch(url);
                                },
                              )
                            ],
                          ));
                        },
                      );
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return const Text('Error Loading Image');
                }

                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
          ))
    ]));
  }

  Widget? NewsWidgets() {
    GetNews().then((value) {
      debugPrint('News Value : ${value.title}');
      return Container(
        child: Text(value.title),
      );
    });
    return null;
  }

  Future<List<dynamic>> GetNewsData() async {
    final queryParameters = {
      'q': 'covid-19',
      'page_size': '20',
      'lang': 'en',
      'countries': 'ph'
    };
    final uri =
        Uri.https('api.newscatcherapi.com', '/v2/search', queryParameters);
    final response = await http.get(uri,
        headers: {'x-api-key': 'qWhhOV8km6wibadZ0C4w-MEQVLn95xprvEvR7VQ4H4Y'});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> data = await jsonDecode(response.body)['articles'];
      // Map<String, String> articles = jsonDecode(data[0]);
      // Map<String, String> articles = jsonDecode(data[i].toString());
      return data;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.

      throw Exception(response.body);
    }
  }

  var currentCount = 3;

  Future<News> GetNews() async {
    List<dynamic> data = await GetNewsData();
    if (data[currentCount] != null) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // List<dynamic> data = await jsonDecode(response.body)['articles'];

      // Map<String, String> articles = jsonDecode(data[0]);
      // Map<String, String> articles = jsonDecode(data[i].toString());
      return News(
          title: data[currentCount]['title'].toString(),
          media: data[currentCount]['media'].toString(),
          link: data[currentCount]['link'].toString(),
          rights: data[currentCount]['rights'].toString(),
          publishDate: data[currentCount]['publishDate'].toString());
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.

      throw Exception("Error Loading News");
    }
  }

  Future<List<News>> GetNewsList() async {
    List<dynamic> data = await GetNewsData();
    List<News> result = [];
    for (var element in data) {
      result.add(News(
          title: element['title'].toString(),
          media: element['media'].toString(),
          link: element['link'].toString(),
          rights: element['rights'].toString(),
          publishDate: element['publishDate'].toString()));
    }

    return result;
  }
}
