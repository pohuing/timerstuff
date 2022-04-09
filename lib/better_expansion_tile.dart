import 'package:flutter/material.dart';

/// An [ExpansionTile] with a [ExpandIcon] as it's child. Updates the state when expanded or closed.
class BetterExpansionTile extends StatefulWidget {
  final Widget body;
  final Widget title;
  final bool? isExpanded;

  const BetterExpansionTile({
    Key? key,
    required this.body,
    required this.title,
    this.isExpanded,
  }) : super(key: key);

  @override
  _BetterExpansionTileState createState() => _BetterExpansionTileState();
}

class _BetterExpansionTileState extends State<BetterExpansionTile> {
  late bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: isExpanded,
      onExpansionChanged: (value) => setState(() {
        isExpanded = value;
      }),
      title: widget.title,
      children: [widget.body],
      trailing: IgnorePointer(child: ExpandIcon(onPressed: null, isExpanded: isExpanded)),
    );
  }

  @override
  void initState() {
    isExpanded = widget.isExpanded ?? false;
    super.initState();
  }
}
