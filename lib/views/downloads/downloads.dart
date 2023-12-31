import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:books_library/components/loading_widget.dart';
import 'package:books_library/database/download_helper.dart';
import 'package:books_library/util/router.dart';
import 'package:uuid/uuid.dart';

class Downloads extends StatefulWidget {
  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  bool done = true;
  var db = DownloadsDB();
  static final uuid = Uuid();

  List dls = [];

  getDownloads() async {
    List l = await db.listAll();
    setState(() {
      dls.addAll(l);
    });
  }

  @override
  void initState() {
    super.initState();
    getDownloads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Downloads'),
      ),
      body: dls.isEmpty ? _buildEmptyListView() : _buildBodyList(),
    );
  }

  _buildBodyList() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: dls.length,
      itemBuilder: (BuildContext context, int index) {
        Map dl = dls[index];

        return Dismissible(
          key: ObjectKey(uuid.v4()),
          direction: DismissDirection.endToStart,
          background: _dismissibleBackground(),
          onDismissed: (d) => _deleteBook(dl, index),
          child: InkWell(
            onTap: () async {
              String path = dl['path'];

              // MyRouter.pushPage(context, EpubScreen.fromPath(filePath: path));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: dl['image'],
                    placeholder: (context, url) => Container(
                      height: 70.0,
                      width: 70.0,
                      child: LoadingWidget(),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/place.png',
                      fit: BoxFit.cover,
                      height: 70.0,
                      width: 70.0,
                    ),
                    fit: BoxFit.cover,
                    height: 70.0,
                    width: 70.0,
                  ),
                  SizedBox(width: 10.0),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dl['name'],
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'COMPLETED',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              dl['size'],
                              style: TextStyle(
                                fontSize: 13.0,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }

  _buildEmptyListView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/empty.png',
            height: 300.0,
            width: 300.0,
          ),
          Text(
            'Nothing is here',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _dismissibleBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  _deleteBook(Map dl, int index) {
    db.remove({'id': dl['id']}).then((v) async {
      File f = File(dl['path']);
      if (await f.exists()) {
        f.delete();
      }
      setState(() {
        dls.removeAt(index);
      });
      print('done');
    });
  }
}
