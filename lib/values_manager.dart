import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'better_expansion_tile.dart';

class ValuesManager extends Cubit<ValuesState> {
  final List<Value> values = [];
  GlobalKey<AnimatedListState>? listKey;

  ValuesManager() : super(const ValuesState([]));

  void onNewData(QuerySnapshot<Value> event) async {
    log("Got new data", name: runtimeType.toString());
    for (var change in event.docChanges) {
      log("Pre: $values", name: runtimeType.toString());
      final data = change.doc.data()!;
      switch (change.type) {
        case DocumentChangeType.added:
          ins(data);
          break;
        case DocumentChangeType.modified:
          rem(data);
          ins(data);
          break;
        case DocumentChangeType.removed:
          rem(data);
          break;
      }
      log("Post: $values", name: runtimeType.toString());
    }
    emit(ValuesState(values.map((e) => e).toList()));
  }

  void rem(Value data) {
    final i = values.indexWhere((element) => element.ref == data.ref);
    log('Removing item $data at location $i', name: runtimeType.toString());
    listKey?.currentState?.removeItem(
      i,
      (context, animation) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation),
        child: BetterExpansionTile(
          key: Key(data.toString()),
          isExpanded: true,
          title: Text(data.value.toString()),
          body: Column(children: [
            Text(data.ref.toString()),
            TextButton(onPressed: () async => null, child: const Text('DELETE')),
          ]),
        ),
      ),
    );
    values.removeAt(i);
  }

  void ins(Value data) {
    final i = values.indexWhere((e) => e.value > data.value);
    final actualI = i < 0 ? values.length : i;
    log('Adding item $data at location $actualI, key: $listKey', name: runtimeType.toString());
    values.insert(actualI, data);
    listKey?.currentState?.insertItem(actualI);
  }
}

class ValuesState extends Equatable {
  final List<Value> values;

  const ValuesState(this.values);

  @override
  List<Object?> get props => [values];
}

class Value {
  final DocumentReference<Value> ref;
  final int value;

  static Value fromJSON(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? _options) {
    return Value(
        value: snapshot.data()!['value'],
        ref: snapshot.reference.withConverter(fromFirestore: Value.fromJSON, toFirestore: Value.toJSON));
  }

  static Map<String, dynamic> toJSON(Value value, SetOptions? _options) {
    return {'value': value.value};
  }

  Value({required this.ref, required this.value});

  @override
  String toString() {
    return 'Value{ref: $ref, value: $value}';
  }
}
