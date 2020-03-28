import 'package:concordia_go/models/concordia_building.dart';
import 'package:concordia_go/models/node.dart';

class Classroom {
  final ConcordiaBuilding _building;
  final String _floor;
  final String _number;
  Node _node;

  Classroom(this._building, this._floor, this._number) {
    _node = Node('100' + _number);
  }

  ConcordiaBuilding get building => _building;

  Node get node => _node;

  String get floor => _floor;

  String get number => _number;
}
