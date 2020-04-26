    import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  Function endTimer;
  dynamic valueNotifier;
  bool isRegisterPopup;

  CustomDialog({this.isRegisterPopup, this.valueNotifier});

  // Here I am receiving the function in constructor as params

  @override
    State<StatefulWidget> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
    @override
    Widget build(BuildContext context) {
        return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: dialogContent(context),
        );
    }

    Widget dialogContent(BuildContext context) {
      print('widget${widget}');
        return Container(
        margin: EdgeInsets.only(left: 0.0,right: 0.0),
        child: Stack(
            children: <Widget>[
            Container(
                padding: EdgeInsets.only(
                top: 18.0,
                ),
                margin: EdgeInsets.only(top: 13.0,right: 8.0),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 0.0,
                        offset: Offset(0.0, 0.0),
                    ),
                    ]),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    SizedBox(
                    height: 20.0,
                    ),
                    Center(
                        child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: widget.isRegisterPopup ?
                        new Text("User Registered Successfully", style:TextStyle(fontSize: 30.0,color: Colors.white)):
                        new Text("Report Submitted \n ${widget.valueNotifier}", style:TextStyle(fontSize: 30.0,color: Colors.white)),
                        )//
                    ),
                    SizedBox(height: 24.0),
                    InkWell(
                    child: Container(
                        padding: EdgeInsets.only(top: 15.0,bottom:15.0),
                        decoration: BoxDecoration(
                        color:Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16.0),
                            bottomRight: Radius.circular(16.0)),
                        ),
                        child:  Text(
                        "OK",
                        style: TextStyle(color: Colors.blue,fontSize: 25.0),
                        textAlign: TextAlign.center,
                        ),
                    ),
                    onTap:(){
                      // widget.endTimer();
                        Navigator.pop(context);
                    },
                    )
                ],
                ),
            ),
            // Positioned(
            //     right: 0.0,
            //     child: GestureDetector(
            //     onTap: (){
            //         Navigator.of(context).pop();
            //     },
            //     child: Align(
            //         alignment: Alignment.topRight,
            //         child: CircleAvatar(
            //         radius: 14.0,
            //         backgroundColor: Colors.white,
            //         child: Icon(Icons.close, color: Colors.blue),
            //         ),
            //     ),
            //     ),
            // ),
            ],
        ),
        );
    }
    }