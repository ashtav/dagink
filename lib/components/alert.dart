part of 'components.dart';

class Alert extends StatefulWidget {

  final Widget text;
  final Color color;
  final Icon icon;

  Alert(this.text, {this.color, this.icon});

  @override
  _AlertState createState() => _AlertState();
}

class _AlertState extends State<Alert> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10), width: Mquery.width(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: widget.color ?? Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            widget.text, widget.icon ?? SizedBox.shrink()
          ],
        )
        
      ),
    );
  }
}