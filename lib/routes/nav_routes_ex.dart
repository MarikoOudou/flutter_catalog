import 'package:flutter/material.dart';
import '../my_route.dart';

// Adapted from Tensor Programming's multi-page app tutorial:
// https://github.com/tensor-programming/dart_flutter_multi_page_app.
class RoutesExample extends MyRoute {
  const RoutesExample([String sourceFile = 'lib/routes/nav_routes_ex.dart'])
      : super(sourceFile);

  @override
  get title => 'Routes';

  // Route name is useful for navigating between routes.
  static const kRouteName = '/RoutesExample';

  @override
  get description => 'Jumping between pages.';

  @override
  get links => {
        'Doc': 'https://docs.flutter.io/flutter/widgets/Navigator-class.html',
        'Youtube video':
            'https://youtu.be/b2fgMCeSNpY?list=PLJbE2Yu2zumDqr_-hqpAN0nIr6m14TAsd',
      };

  @override
  Widget buildMyRouteContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Page 1'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Go to page two'),
          onPressed: () {
            // Navigator maintains a stack-like structure of pages. Jumping
            // between routes is by push/pop of Navigator.
            Navigator.push(context, _PageTwo());
          },
        ),
      ),
    );
  }
}

// <Null> means this route returns nothing.
class _PageTwo extends MaterialPageRoute<Null> {
  _PageTwo()
      : super(builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Page 2'),
              elevation: 1.0,
            ),
            // *Note*: use a Builder instead of directly giving the body, so
            // that Scaffold.of(context) won't throw exception, c.f.
            // https://stackoverflow.com/a/51304732.
            body: Builder(
              builder: (BuildContext context) => Center(
                child: RaisedButton(
                  child: Text('Go to page 3'),
                  onPressed: () {
                    // Navigator.push<T> returns a Future<T>, which is the
                    // return value of the pushed route when it's popped.
                    Navigator.push<String>(context, _PageThree())
                      ..then<String>((returnVal) {
                        if (returnVal != null) {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text('You clicked: $returnVal'),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            ),
                          );
                        }
                      });
                  },
                ),
              ),
            ),
          );
        });
}

// MaterialPageRoute<String> returns a Future<String>.
class _PageThree extends MaterialPageRoute<String> {
  _PageThree()
      : super(builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Last page'),
              elevation: 2.0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.all(32.0),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(child: Text('1')),
                    title: Text('user1@example.com'),
                    onTap: () => Navigator.pop(context, 'user1@example.com'),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Text('2')),
                    title: Text('user2@example.com'),
                    onTap: () => Navigator.pop(context, 'user2@example.com'),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Text('3')),
                    title: Text('user3@example.com'),
                    onTap: () => Navigator.pop(context, 'user3@example.com'),
                  ),
                  Divider(),
                  MaterialButton(
                    child: Text('Go home'),
                    onPressed: () {
                      // Pops until reaching a route with that route name.
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName(RoutesExample.kRouteName),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
}
