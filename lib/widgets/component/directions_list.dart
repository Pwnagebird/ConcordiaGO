import 'package:concordia_go/blocs/bloc.dart';
import 'package:concordia_go/utilities/application_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DirectionsList extends StatefulWidget {
  @override
  State<DirectionsList> createState() => DirectionsListState();
}

class DirectionsListState extends State<DirectionsList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: concordiaRed,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Directions',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Container(
              color: Colors.white,
              child: BlocBuilder<DirectionsBloc, DirectionsState>(
                builder: (BuildContext context, DirectionsState state) {
                  if (state is InstructionState) {
                    return ListView.builder(
                      itemCount: state.directionsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(state.directionsList[index].instruction),
                        );
                      },
                    );
                  } else {
                    return Container(
                      height: 350,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
