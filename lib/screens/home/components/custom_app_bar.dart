import 'package:flutter/material.dart';

import 'package:quake/components/logo_title.dart';
import 'package:quake/screens/home/components/date_selection_row.dart';
import 'package:quake/screens/home/components/magnitude_row.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({
    Key key,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isOpened = false;

  changeState() => setState(() => isOpened = !isOpened);
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double width = mediaQuery.size.width;
    final double height = mediaQuery.size.height;

    final bool isPortrait = mediaQuery.orientation == Orientation.portrait;

    final double _barHeight = isPortrait
        ? height / (isOpened ? 4 : 5)
        : height / (isOpened ? 2 : 2.5);

    final EdgeInsets _internalPadding = EdgeInsets.all(6);

    return SafeArea(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        width: width,
        height: _barHeight,
        color: Theme.of(context).cardColor,
        padding: _internalPadding,
        child: InkWell(
          onTap: changeState,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LogoTitle(),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              ),
              if (isOpened) MagnitudeRow(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "Selected date",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              DateSelectionRow(),
              Center(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 4),
                    ),
                    Container(
                      height: 6,
                      width: MediaQuery.of(context).size.width / 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        color: Colors.grey[350],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 4),
                    ),
                    Text("Tap to expand"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
