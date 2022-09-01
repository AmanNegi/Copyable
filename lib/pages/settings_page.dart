import 'package:copyable/data/local_data.dart';
import 'package:copyable/globals.dart';
import 'package:copyable/colors.dart';
import 'package:copyable/widgets/responsive.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int selectedColor;

  @override
  void initState() {
    selectedColor = colorList.indexOf(appData.value.globalColor);
    if (selectedColor < 0) selectedColor = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !Responsive.isLargeScreen(context)
          ? AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(MdiIcons.chevronLeft),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: const Text("Settings"),
              elevation: 1,
              shadowColor: Colors.white10,
              backgroundColor: Theme.of(context).backgroundColor,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: appData.value.globalColor),
                    child: Text(
                      "Reset",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    onPressed: () {
                      selectedColor = 1;
                      localData.updateColorData(colorList[1]);
                      localData.updateFontSize(16);
                      setState(() {});
                    },
                  ),
                ),
              ],
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.isLargeScreen(context)
              ? 0.1 * MediaQuery.of(context).size.width
              : 15.0,
          vertical: Responsive.isLargeScreen(context)
              ? 0.05 * MediaQuery.of(context).size.height
              : 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Spacer(),
                if (Responsive.isLargeScreen(context))
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: appData.value.globalColor),
                    child: Text(
                      "Reset",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    onPressed: () {
                      selectedColor = 1;
                      localData.updateColorData(colorList[1]);
                      localData.updateFontSize(16);
                      setState(() {});
                    },
                  ),
              ],
            ),
            _getHeading("App Color"),
            Wrap(
              runSpacing: 5.0,
              children: _getWrapChildren(),
            ),
            SizedBox(height: 0.05 * getHeight(context)),
            _getHeading("Font Size"),
            Row(
              children: [
                IconButton(
                  icon: const Icon(MdiIcons.minus),
                  onPressed: () {
                    localData.updateFontSize(appData.value.fontSize - 1);
                  },
                ),
                Text(appData.value.fontSize.toString()),
                IconButton(
                  icon: const Icon(MdiIcons.plus),
                  onPressed: () {
                    localData.updateFontSize(appData.value.fontSize + 1);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getWrapChildren() {
    List<Widget> children = [];
    for (int i = 0; i < colorList.length; i++) {
      children.add(_getColorItem(i, context));
    }
    return children;
  }

  GestureDetector _getColorItem(int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        selectedColor = index;
        localData.updateColorData(colorList[selectedColor]);
        setState(() {});
      },
      child: Container(
        margin: EdgeInsets.only(
          right:
              Responsive.isLargeScreen(context) ? 0.01 * getWidth(context) : 10,
        ),
        width: 0.05 * getHeight(context),
        height: 0.05 * getHeight(context),
        decoration: BoxDecoration(
            color: colorList[index],
            shape: BoxShape.circle,
            border: Border.all(
                color:
                    selectedColor == index ? Colors.white : Colors.transparent,
                width: 2)),
      ),
    );
  }

  _getHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline5!.copyWith(
              color: headingTextColor.withOpacity(0.75),
            ),
      ),
    );
  }
}
