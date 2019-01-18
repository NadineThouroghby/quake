//TODO: WORK IN PROGRESS

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:quake/src/bloc/earthquakes_bloc.dart';
import 'package:quake/src/locale/localizations.dart';
import 'package:quake/src/model/alert_dialog.dart';
import 'package:quake/src/model/loading.dart';
import 'package:quake/src/routes/earthquakes_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

StreamController<bool> permissionStream = StreamController();

class HomePageNearby extends StatefulWidget {
  static HomePageNearby _instance = HomePageNearby._();
  HomePageNearby._();
  factory HomePageNearby() => _instance;

  @override
  HomePageNearbyState createState() => HomePageNearbyState();
}

class HomePageNearbyState extends State<HomePageNearby> {
  @override
  Widget build(BuildContext context) {
    if (permissionStream != null) {
      permissionStream.stream.listen((value) => setState(() => disposePermissionStream()));
    }

    return Container(
      child: FutureBuilder(
        future: _hasLocationSaved(),
        initialData: false,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          // user has saved data
          if (snapshot.hasData && snapshot.data) {
            final EarthquakesSearchBloc earthquakesBloc =
                EarthquakesSearchBloc();

            return FutureBuilder(
              future: _getLocation(),
              builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
                Map location = snapshot.data;
                if (location == null) return Loading();
                // IDEA: custom bounding box
                SearchOptions options = SearchOptions(
                  minLatitude: location["latitude"] - 10,
                  maxLatitude: location["latitude"] + 10,
                  minLongitude: location["latitude"] - 10,
                  maxLongitude: location["latitude"] + 10,
                );

                earthquakesBloc.search(options: options);
                return EarthquakesList(earthquakesBloc: earthquakesBloc);
              },
            );
          } else if (snapshot.hasData && !snapshot.data) {
            // user has no location saved, so show an alert with some infos and then prompt for location permission
            return ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: NoLocationSavedWidget(),
            );
          }
        },
      ),
    );
  }
}

class NoLocationSavedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            QuakeLocalizations.of(context).locationNotEnabled,
            style: TextStyle(
              color: Theme.of(context).textTheme.title.color,
              fontSize: 18.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
          ),
          FlatButton(
            child: Text(
              QuakeLocalizations.of(context).promptForLocationPermissionButton,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onPressed: () => QuakeAlertDialog.createDialog(
                  context,
                  QuakeAlertDialog(
                    content: QuakeLocalizations.of(context)
                        .locationPromptAlertContent,
                    title:
                        QuakeLocalizations.of(context).locationPromptAlertTitle,
                    onOkPressed: () async {
                      Map currentLocation = <String, double>{};
                      Location location = Location();

                      try {
                        currentLocation = await location.getLocation();
                      } catch (_) {
                        currentLocation = null;
                      }

                      if (currentLocation != null) {
                        _saveLocation(currentLocation);
                        permissionStream.sink.add(true);
                      }

                      // close dialog
                      Navigator.pop(context);
                    },
                  ),
                  dismissible: true,
                ),
          ),
        ],
      ),
    );
  }
}

Future<bool> _hasLocationSaved() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getBool('hasLocationSaved') ?? false;
}

void _saveLocation(Map<String, double> location) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setDouble("latitude", location["latitude"]);
  sharedPreferences.setDouble("longitude", location["longitude"]);

  sharedPreferences.setBool("hasLocationSaved", true);
}

Future<Map> _getLocation() async {
  Map<String, double> location = Map();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  location["latitude"] = sharedPreferences.getDouble("latitude") ?? -1;
  location["longitude"] = sharedPreferences.getDouble("longitude") ?? -1;
  return location;
}


void disposePermissionStream() {
  permissionStream.close();
  permissionStream = null;
}
