import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../my_route.dart';

class BlocLibExample extends MyRoute {
  const BlocLibExample(
      [String sourceFile = 'lib/routes/state_bloc_lib_ex.dart'])
      : super(sourceFile);

  @override
  get title => 'Easier BLoC pattern';

  @override
  get description => 'Simpler BLoC implementation with flutter_bloc package.';

  @override
  get links => {
        'Video by Reso Coder': 'https://youtu.be/LeLrsnHeCZY',
        'flutter_bloc doc': 'https://felangel.github.io/bloc/#/coreconcepts',
      };

  @override
  Widget buildMyRouteContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _MyDemoApp(),
    );
  }
}

// ###1. Define an Event class that represents an event in our app. The widgets
// pass _MyEvent objects as inputs to MyBloc.
class _MyEvent {
  final bool isIncrement;
  final DateTime timestamp;

  _MyEvent({@required this.isIncrement, DateTime timestamp})
      : this.timestamp = timestamp ?? DateTime.now();
}

// ###2. Define a State class that represents our app's state. MyBloc's output
// would be such a state. Note the state must be IMMUTABLE in flutter_bloc from
// v0.6.0. Instead of mutating the state, create a new state instance.
class _MyState {
  final int counter;

  const _MyState(this.counter);
}

// ###3. Define a MyBloc class which extends Bloc<_MyEvent, _MyState> from the
// flutter_bloc package. With this package, we don't need to manage the stream
// controllers.
class MyBloc extends Bloc<_MyEvent, _MyState> {
  @override
  _MyState get initialState => _MyState(0);

  // The business logic is in this mapEventToState function.
  // Note: in flutter_bloc from v0.6.0 on, states are enforced IMMUTABLE,
  // mutating currentState and yielding the it won't update on UI.
  // C.f. https://github.com/felangel/bloc/issues/103.
  @override
  Stream<_MyState> mapEventToState(_MyEvent event) async* {
    _MyState newState;
    if (event.isIncrement) {
      newState = _MyState(currentState.counter + 1);
    } else {
      newState = _MyState(currentState.counter - 1);
    }
    yield newState;
  }

  // Instead of doing bloc.sink.add(), we do bloc.dispatch().
  void increment() => this.dispatch(_MyEvent(isIncrement: true));
  void decrement() => this.dispatch(_MyEvent(isIncrement: false));
}

class _MyDemoApp extends StatefulWidget {
  @override
  _MyDemoAppState createState() {
    return new _MyDemoAppState();
  }
}

class _MyDemoAppState extends State<_MyDemoApp> {
  final _bloc = MyBloc();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Text("BLoC pattern is great for accessing/mutating app's state and "
            "updating UI without rebuilding the whole widget tree. But the vanilla "
            "BLoC implementation has too much boilerplate code. \n\n"
            "With the flutter_bloc package, we don't need to manage Streams "
            "or implement our own BlocProvider/InheritedWidget. We only need to "
            "implement the core business logic in the `mapEventToState` function.\n"),
        // ###4. Use the BlocProvider from flutter_bloc package, we don't need
        // to write our own InheritedWidget.
        BlocProvider<MyBloc>(
          builder: (BuildContext context) => this._bloc,
          child: _AppRootWidget(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    this._bloc.dispose();
    super.dispose();
  }
}

class _AppRootWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        children: <Widget>[
          Text('(root widget)'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _CounterAndButton(),
              _CounterAndButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterAndButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(4.0).copyWith(top: 32.0, bottom: 32.0),
      color: Colors.white70,
      child: Column(
        children: <Widget>[
          Text('(child widget)'),
          // ###5. Access the state from child widget by wrapping the widget by
          // a BlocBuilder.
          BlocBuilder(
            bloc: BlocProvider.of<MyBloc>(context),
            builder: (context, _MyState state) {
              return Text(
                '${state.counter}',
                style: Theme.of(context).textTheme.display1,
              );
            },
          ),
          ButtonBar(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                // ###6. Post new event by calling functions in bloc or by
                // bloc.dispatch(newEvent);
                onPressed: () => BlocProvider.of<MyBloc>(context).increment(),
              ),
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => BlocProvider.of<MyBloc>(context).decrement(),
              ),
            ],
          )
        ],
      ),
    );
  }
}
