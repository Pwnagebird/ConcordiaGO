import 'package:concordia_go/blocs/bloc.dart';
import 'package:concordia_go/models/node.dart';
import 'package:concordia_go/utilities/application_constants.dart' as application_constants;
import 'package:concordia_go/utilities/application_constants.dart';
import 'package:concordia_go/utilities/floor_maps_lib.dart';
import 'package:concordia_go/widgets/component/floor_selection_dropdown.dart';
import 'package:concordia_go/widgets/component/room_info_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

BuildContext indoorContext;

class IndoorMapScreen extends StatefulWidget {
  IndoorMapScreen();

  @override
  State<IndoorMapScreen> createState() => IndoorMapState();
}

class IndoorMapState extends State<IndoorMapScreen> {
  String _floorSVG = floorPlan['H1'];
  String _buildingCode = 'H';
  String _floorLevel = '1';
  Map<String, List<Node>> _paths;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showDrawer = false;

  IndoorMapState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => buildInfoSheet(_showDrawer));
  }

  @override
  Widget build(BuildContext context) {
    indoorContext = context;
    return Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight / 12),
          child: AppBar(
            title: Image.asset('assets/logo.png', height: screenHeight / 12),
            backgroundColor: application_constants.concordiaRed,
          ),
        ),
        body: Stack(
          children: <Widget>[
            BlocBuilder<MapBloc, MapState>(
              builder: (context, state) {
                if (state is IndoorMap) {
                  _floorSVG = state.svgFile;
                  _buildingCode = state.buildingCode;
                  _showDrawer = state.showDrawer;
                }
                return PhotoView.customChild(
                  child: SvgPicture.string(
                    _floorSVG,
                    height: 500.0,
                  ),
                  initialScale: 1.0,
                  maxScale: 3.5,
                  minScale: 1.0,
                  enableRotation: true,
                  backgroundDecoration: BoxDecoration(
                    color: Colors.white,
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.topRight,
              child: FloorSelectionDropdown(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: stopNavigationButton(),
            ),
          ],
        ));
  }

  Widget stopNavigationButton() {
    return BlocBuilder<MapBloc, MapState>(builder: (context, state) {
      if (state is IndoorMap) {
        _paths = state.paths;
        _floorLevel = state.floorLevel;
      }
      if (_paths != null) {
        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Container(
            height: screenHeight / 16,
            width: application_constants.screenWidth / 2,
            child: FlatButton(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              color: concordiaRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Align(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 32,
                    ),
                    Text(
                      'Stop navigation',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              onPressed: () {
                BlocProvider.of<MapBloc>(context).add(FloorChange(_buildingCode, _floorLevel));
              },
            ),
          ),
        );
      }
      return Container();
    });
  }

  void buildInfoSheet(bool showDrawer) {
    if (showDrawer) {
      RoomInfoSheet.buildInfoSheet(_scaffoldKey.currentState, _scaffoldKey.currentContext);
    }
  }
}