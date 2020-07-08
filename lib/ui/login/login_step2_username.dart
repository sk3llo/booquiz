import 'package:booquiz/ui/custom_widgets/custom_text_field.dart';
import 'package:booquiz/ui/login/login_step1.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:booquiz/blocs/blocs.dart';

class LoginStep2 extends StatefulWidget {
  final String password;

  LoginStep2(this.password);

  @override
  _LoginStep2State createState() => _LoginStep2State();
}

class _LoginStep2State extends State<LoginStep2> {
  TextEditingController usernameController = TextEditingController();
  FocusNode usernameFocus = FocusNode();

  bool usernameChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            loginBloc.add(LogOutEvent());
            Navigator.push(context, MaterialPageRoute(builder: (c) => LoginStep1()));
          },
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [
              Colors.yellow.shade100,
              Colors.cyan.shade100,
            ])),
        child: GestureDetector(
          onTap: () {
            loginBloc.add(LogOutEvent());

            Navigator.of(context).push(MaterialPageRoute(builder: (c) => LoginStep1()));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  // Main password field
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.only(
                        left: dimensions.dim12(),
                        right: dimensions.dim12(),
                        top: dimensions.dim2(),
                        bottom: dimensions.dim2()),
                    padding: EdgeInsets.only(
                        left: dimensions.dim12(),
                        top: dimensions.dim2(),
                        bottom: dimensions.dim2()),
                    alignment: Alignment.center,
                    height: dimensions.buttonsHeight(),
                    decoration: ShapeDecoration(
                        color: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(dimensions.mainCornerRadius())),
                            side: BorderSide(
                                color: usernameFocus.hasFocus || usernameController.text.isNotEmpty
                                    ? Colors.white
                                    : Colors.blueGrey))),
                    child: CustomTextField(
                      onTap: () {
                        setState(() {});
                      },
                      onChanged: (_t) {
                        // Needed to display color change of login button
                        if (_t.length <= 1) setState(() {});

                        // Check if pass is valid (more 6 chars)
                        if (_t.length >= 6) {
                          setState(() {
                            usernameChecked = true;
                          });
                        } else {
                          setState(() {
                            usernameChecked = false;
                          });
                        }
                      },
                      onSubmitted: (_pass) {
                        loginBloc.add(EmailPassLogInEvent(
                            email: usernameController.text, password: _pass, onStart: false));
                      },
                      focusNode: usernameFocus,
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: 'Pick a username',
                        hintStyle: TextStyle(fontSize: dimensions.sp14(), color: Colors.white),
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: dimensions.sp14(), color: Colors.white),
                      obscureText: true,
                      maxLength: 16,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  // Password check icon
                  usernameChecked
                      ? Positioned(
                          height: dimensions.buttonsHeight(),
                          right: dimensions.dim10(),
                          top: dimensions.dim4(),
                          child: Container(
                            padding: EdgeInsets.all(dimensions.dim4()),
                            decoration: ShapeDecoration(
                                shape: CircleBorder(side: BorderSide(color: Colors.green)),
                                color: Colors.white.withOpacity(.75)),
                            child: Icon(
                              Icons.done,
                              size: dimensions.dim16(),
                              color: Colors.green,
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
