import 'dart:developer';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timerstuff/better_expansion_tile.dart';
import 'package:timerstuff/values_manager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final valuesCubit = ValuesManager();
  FirebaseFirestore.instance
      .collection('timings')
      .withConverter(
        fromFirestore: Value.fromJSON,
        toFirestore: Value.toJSON,
      )
      .orderBy('value')
      .snapshots()
      .listen((event) {
    valuesCubit.onNewData(event);
  });
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider.value(value: valuesCubit)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final int initialCount;
  final listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    log('ListKey: $listKey');
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          FirebaseFirestore.instance.collection('timings').add({'value': Random().nextInt(100000)});
        },
      ),
      body: AnimatedList(
        key: listKey,
        initialItemCount: initialCount,
        itemBuilder: (context, index, animation) {
          var data = context.read<ValuesManager>().values[index];
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation),
            child: BetterExpansionTile(
              key: Key(data.toString()),
              title: Text(data.value.toString()),
              body: Column(children: [
                Text(data.ref.toString()),
                TextButton(onPressed: () async => data.ref.delete(), child: const Text('DELETE')),
              ]),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    log('Key: $listKey', name: runtimeType.toString());
    context.read<ValuesManager>().listKey = listKey;
    log('ManagerListKey: ${context.read<ValuesManager>().listKey}', name: runtimeType.toString());
    initialCount = context.read<ValuesManager>().values.length;
    log('Initial count: $initialCount', name: runtimeType.toString());
    super.initState();
  }
}
