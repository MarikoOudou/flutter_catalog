import 'package:flutter/material.dart';
import '../my_route.dart';
import 'package:english_words/english_words.dart' as english_words;

class AppbarSearchExample extends MyRoute {
  const AppbarSearchExample(
      [String sourceFile = 'lib/routes/appbar_search_ex.dart'])
      : super(sourceFile);

  @override
  get title => 'Search';

  @override
  get links => {
        'Doc':
            'https://docs.flutter.io/flutter/material/SearchDelegate-class.html'
      };

  @override
  Widget buildMyRouteContent(BuildContext context) {
    return _AppbarSearchDemo();
  }
}

// Adapted from search demo in offical flutter gallery:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/search_demo.dart
class _AppbarSearchDemo extends StatefulWidget {
  @override
  _AppbarSearchDemoState createState() => _AppbarSearchDemoState();
}

class _AppbarSearchDemoState extends State<_AppbarSearchDemo> {
  final List<String> kEnglishWords;
  _MySearchDelegate _delegate;

  _AppbarSearchDemoState()
      : kEnglishWords = List.from(Set.from(english_words.all))
          ..sort(
            (w1, w2) => w1.toLowerCase().compareTo(w2.toLowerCase()),
          ),
        super();

  @override
  void initState() {
    super.initState();
    _delegate = _MySearchDelegate(kEnglishWords);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('English Words'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final String selected = await showSearch<String>(
                context: context,
                delegate: _delegate,
              );
              if (selected != null) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You have selected the word: $selected'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Scrollbar(
        child: ListView.builder(
          itemCount: kEnglishWords.length,
          itemBuilder: (context, idx) => ListTile(
            title: Text(kEnglishWords[idx]),
          ),
        ),
      ),
    );
  }
}

// Defines the content of the search page in `showSearch()`.
// SearchDelegate has a member `query` which is the query string.
class _MySearchDelegate extends SearchDelegate<String> {
  final List<String> _words;
  final List<String> _history;

  _MySearchDelegate(List<String> words)
      : _words = words,
        _history = <String>['apple', 'hello', 'world', 'flutter'],
        super();

  // Leading icon in search bar.
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        // SearchDelegate.close() can return vlaues, similar to Navigator.pop().
        this.close(context, null);
      },
    );
  }

  // Widget of result page.
  @override
  Widget buildResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('You have selected the word:'),
            GestureDetector(
              onTap: () {
                // Returns this.query as result to previous screen, c.f.
                // `showSearch()` above.
                this.close(context, this.query);
              },
              child: Text(
                this.query,
                style: Theme.of(context)
                    .textTheme
                    .display1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Suggestions list while typing (this.query).
  @override
  Widget buildSuggestions(BuildContext context) {
    final Iterable<String> suggestions = this.query.isEmpty
        ? _history
        : _words.where((word) => word.startsWith(query));

    return _SuggestionList(
      query: this.query,
      suggestions: suggestions.toList(),
      onSelected: (String suggestion) {
        this.query = suggestion;
        this._history.insert(0, suggestion);
        showResults(context);
      },
    );
  }

  // Action buttons at the right of search bar.
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? IconButton(
              tooltip: 'Voice Search',
              icon: const Icon(Icons.mic),
              onPressed: () {
                this.query = 'TODO: implement voice input';
              },
            )
          : IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
    ];
  }
}

// Suggestions list widget displayed in the search page.
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({this.suggestions, this.query, this.onSelected});

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return ListTile(
          leading: query.isEmpty ? Icon(Icons.history) : Icon(null),
          // Highlight the substring that matched the query.
          title: RichText(
            text: TextSpan(
              text: suggestion.substring(0, query.length),
              style: textTheme.copyWith(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: suggestion.substring(query.length),
                  style: textTheme,
                ),
              ],
            ),
          ),
          onTap: () {
            onSelected(suggestion);
          },
        );
      },
    );
  }
}
