import 'dart:async';

import 'package:booquiz/blocs/blocs.dart';
import 'package:booquiz/main.dart';
import 'package:booquiz/models/loginCreds.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:booquiz/ui/custom_widgets/custom_text_field.dart';
import 'package:booquiz/ui/login/login_step2_username.dart';
import 'package:booquiz/ui/mainScreen/main_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flame/widgets/animation_widget.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:sa_stateless_animation/sa_stateless_animation.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/animation.dart' as anim;

class LoginStep1 extends StatefulWidget {
  @override
  _LoginStep1State createState() => _LoginStep1State();
}

class _LoginStep1State extends State<LoginStep1> with TickerProviderStateMixin {
  // Animation
  Sprite flyingBookSprite;
  anim.Animation animation;

  // Email / Password
  bool emailChecked = false;
  bool passwordChecked = false;
  bool showErrorMessage = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode _emailFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();

  // Page View defs
  PageController _pageViewController = PageController();
  int currentPage = 0;

  // Username defs
  TextEditingController _usernameController = TextEditingController();
  String usernameErrorText = '';
  FocusNode _usernameFocus = FocusNode();

  bool usernameChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
  }

  @override
  void initState() {
    super.initState();
    // Listen to log in
    logInListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          _emailFocus?.unfocus();
          _passwordFocus?.unfocus();
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {});
        },
        child: Container(
          color: colorBlueLight,
          // Main gradient
          child: BlocBuilder(
              bloc: loginBloc,
              builder: (context, state) {
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[

                    emailLogin(state),

                    // HUISASI
                    Positioned(
                      child: Container(
                        height: dimensions.dim60(),
                        width: dimensions.dim40(),
                        color: Colors.green,
                        child: RawMaterialButton(
                          onPressed: () async {
                            // Log Out
                           loginBloc.add(LogOutEvent());

                            print(state);

                            var gg = await dbHelper.checkLogin();
                            print(gg?.email);
                            print(gg?.provider);
                            print(gg?.passwordOrAccessToken);
                          },
                          child: Text(
                            'HUISASI',
                            style: TextStyle(color: Colors.black, fontSize: dimensions.sp18()),
                          ),
                        ),
                      ),
                      top: MediaQuery.of(context).size.width / 4,
                      width: 100,
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget emailLogin(dynamic state) {
    return Container(
      margin: EdgeInsets.only(top: dimensions.dim30()),
      child: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageViewController,
        children: <Widget>[
          // Email / Password page
          Container(
            padding: EdgeInsets.symmetric(horizontal: mainPadding),
            margin: EdgeInsets.symmetric(horizontal: mainPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // LOGIN REQUIRED TEXT
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(vertical: dimensions.dim20()),
                  child: Text(
                    'Login Required',
                    style: TextStyle(
                        fontSize: dimensions.sp22(),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        shadows: [
                          Shadow(color: Colors.white, offset: Offset(0, 0), blurRadius: 5),
                        ]),
                  ),
                ),

                // EMAIL
                Stack(
                  children: <Widget>[
                    // Main email field
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.only(
                          left: mainPadding,
                          right: mainPadding,
                          top: dimensions.dim2(),
                          bottom: dimensions.dim2()),
                      alignment: Alignment.center,
                      height: dimensions.buttonsHeight(),
                      margin: EdgeInsets.only(
                        bottom: dimensions.dim4(),
                      ),
                      decoration: ShapeDecoration(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(dimensions.mainCornerRadius())),
                              side: BorderSide(
                                  color: _emailFocus.hasFocus || _emailController.text.isNotEmpty
                                      ? Colors.white
                                      : Colors.grey))),
                      child: CustomTextField(
                        onTap: () {
                          setState(() {});
                        },
                        onChanged: (_t) async {
                          // Needed to display color change of login button
                          if (_t.length <= 1) setState(() {});

                          // Check email
                          if (EmailValidator.validate(_t)) {
                            setState(() {
                              emailChecked = true;
                            });
                          } else {
                            if (emailChecked)
                              setState(() {
                                emailChecked = false;
                              });
                          }
                        },
                        onSubmitted: (_t) {
                          FocusScope.of(context).requestFocus(_passwordFocus);
                          setState(() {});
                        },
                        focusNode: _emailFocus,
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(fontSize: dimensions.sp14(), color: Colors.grey),
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        maxLength: 36,
                        style: TextStyle(fontSize: dimensions.sp14(), color: loginTextColor),
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    // Email check icon
                    emailChecked
                        ? Positioned(
                            height: dimensions.buttonsHeight(),
                            right: dimensions.dim10(),
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

                // PASSWORD
                Stack(
                  children: <Widget>[
                    // Main password field
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.only(
                          left: mainPadding,
                          right: mainPadding,
                          top: dimensions.dim2(),
                          bottom: dimensions.dim2()),
                      alignment: Alignment.center,
                      height: dimensions.buttonsHeight(),
                      margin: EdgeInsets.only(
                        bottom: mainPadding,
                        top: dimensions.dim4(),
                      ),
                      decoration: ShapeDecoration(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(dimensions.mainCornerRadius())),
                              side: BorderSide(
                                  color:
                                      _passwordFocus.hasFocus || _passwordController.text.isNotEmpty
                                          ? Colors.white
                                          : Colors.grey))),
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
                              passwordChecked = true;
                            });
                          } else {
                            setState(() {
                              passwordChecked = false;
                            });
                          }
                        },
                        onSubmitted: (_pass) {
                          loginBloc.add(EmailPassLogInEvent(
                              email: _emailController.text, password: _pass, onStart: false));
                        },
                        focusNode: _passwordFocus,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(fontSize: dimensions.sp14(), color: Colors.grey),
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: dimensions.sp14(), color: Colors.black54),
                        obscureText: true,
                        maxLength: 16,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    // Password check icon
                    passwordChecked
                        ? Positioned(
                            height: dimensions.buttonsHeight(),
                            right: dimensions.dim10(),
                            top: dimensions.dim4(),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
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

                // LOGIN BUTTON
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: dimensions.buttonsHeight(),
                  margin: EdgeInsets.only(bottom: dimensions.dim10()),
                  width: MediaQuery.of(context).size.width / 3,
                  decoration: ShapeDecoration(
                      color: emailChecked && passwordChecked ? Colors.white : Colors.grey[350],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(mainPadding)),
                          side: BorderSide(
                              color: _emailController.text.isNotEmpty &&
                                      _passwordController.text.isNotEmpty
                                  ? Colors.white
                                  : Colors.grey[350]))),
                  child: RawMaterialButton(
                    onPressed: state is LoginLoadingState ? null : () {
                      // Remove all focus
                      FocusScope.of(context).requestFocus(FocusNode());

                      if (emailChecked && passwordChecked)
                        loginBloc.add(EmailPassLogInEvent(
                            email: _emailController.text, password: _passwordController.text));
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                          color: emailChecked && passwordChecked ? Colors.green : Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // ERROR TEXT OR LOADING INDICATOR
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: dimensions.dim40(),
                  margin: EdgeInsets.symmetric(
                      vertical: dimensions.dim6()),
                  padding: EdgeInsets.symmetric(
                      horizontal: dimensions.dim6()),
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      if (state is LoginErrorState && state.message.isNotEmpty)
                        setState(() {
                          showErrorMessage = false;
                        });
                    },
                    child: state is LoginLoadingState
                        ? Container(
                        width: dimensions.dim25(),
                        height: dimensions.dim25(),
                        child: CircularProgressIndicator())
                        : SingleChildScrollView(
                          child: Text(
                      state is LoginErrorState ? state.message : '',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorBlueDarkText),
                    ),
                        ),
                  ),
                ),
                // ROUND BUTTONS
                Container(
                  padding: EdgeInsets.symmetric(horizontal: mainPadding),
                  child: Column(
                    children: <Widget>[
                      // Sign in with
                      Container(
                        margin: EdgeInsets.only(top: dimensions.dim6()),
                        alignment: Alignment.center,
                        child: Text(
                          'or sign in with',
                          style: TextStyle(
                              color: Colors.grey[500],
//                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.solid),
                        ),
                      ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                margin: EdgeInsets.only(bottom: mainPadding * 2, top: mainPadding / 2),
                                height: dimensions.dim1(),
                                color: Colors.grey[400],
                              ),
                      // Providers (Google, FB, Apple)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // FACEBOOK SIGN IN
                          Padding(
                            padding: EdgeInsets.only(right: mainPadding),
                            child: Material(
                              color: Colors.transparent,
                              child: FloatingActionButton(
                                heroTag: 'hui',
                                elevation: 1,
                                backgroundColor: Colors.white,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: dimensions.dim6(), bottom: dimensions.dim6()),
                                  child: Image.asset('assets/images/loginButtons/fb_icon.png',
                                      width: dimensions.dim30(), height: dimensions.dim30()),
                                ),
                                // Suppress action if already loading
                                onPressed: state is LoginLoadingState ? null :  () async {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  if (state is LoginEmptyState || state is LoginErrorState)
                                    loginBloc.add(FBLogInEvent());
                                },
                              ),
                            ),
                          ),

                          // GOOGLE SIGN IN
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: mainPadding),
                            child: Material(
                              color: Colors.transparent,
                              child: FloatingActionButton(
                                elevation: 1,
                                heroTag: 'pizda',
                                backgroundColor: Colors.white,
                                child: Image.asset('assets/images/loginButtons/google_icon.png',
                                    width: dimensions.dim25(), height: dimensions.dim25()),
                                onPressed: state is LoginLoadingState ? null : () {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  if (state is LoginEmptyState || state is LoginErrorState)
                                    loginBloc.add(GoogleLogInEvent());
                                },
                              ),
                            ),
                          ),

                          // Apple sign in
                          Platform.isIOS
                              ? Padding(
                                  padding: EdgeInsets.only(left: mainPadding),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: FloatingActionButton(
                                      elevation: 1,
                                      heroTag: 'dzhigurda',
                                      backgroundColor: Colors.white,
                                      child: Image.asset(
                                          'assets/images/loginButtons/apple_icon.png',
                                          width: dimensions.dim25(),
                                          height: dimensions.dim25()),
                                      onPressed: state is LoginLoadingState ? null : () {
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        if (state is LoginEmptyState || state is LoginErrorState)
                                          loginBloc.add(AppleLogInEvent());
                                      },
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Pick a username page
          pickUsername(state)
        ],
      ),
    );
  }

  void logInListener() async {
    LogInCreds creds = await dbHelper.checkLogin();

    // Try to log in with creds if available
    if (creds != null) {
      loginBloc.add(TryToLogInEvent());
    }

    // Set up listener to listen to loginBloc's state
    StreamSubscription _listener;
    _listener = loginBloc.listen((state) async {
      if (state is LoggedInState) {

        // Go whether to Main Screen or Pick Username page
        if (currentUser != null && currentUser.username != null){
          if (mounted)
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => MainScreen()));
        } else {
          _pageViewController?.animateToPage(
              1, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        }

        // Null state
        loginBloc.add(LoginEmptyEvent());
        await _listener.cancel();
      }
      
      if (state is NewUserCreatedState){
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => MainScreen()));
      }
    });
    
  }

  Widget pickUsername(dynamic state) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Username field
        AnimatedContainer(
          alignment: Alignment.center,
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.only(
              left: mainPadding,
              right: mainPadding,
              top: dimensions.dim2(),
              bottom: dimensions.dim2()),
          margin: EdgeInsets.only(
              left: dimensions.dim24(), right: dimensions.dim24(), top: dimensions.dim50()),
          height: state is NewUserCreatedState ? 0 : dimensions.buttonsHeight(),
          decoration: ShapeDecoration(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(dimensions.mainCornerRadius())),
                  side: BorderSide(
                      color: _usernameFocus.hasFocus || _usernameController.text.isNotEmpty
                          ? Colors.white
                          : Colors.grey))),
          child: CustomTextField(
            onTap: () {
              setState(() {});
            },
            onChanged: (t) {
              // Needed to display color change of login button
              if (t.length <= 1) setState(() {});

              // Check if pass is valid (no whitespaces && more 6 chars)
              if (!t.contains(RegExp(r'\s')) &&
                  t.length >= usernameMinLength &&
                  t.length <= usernameMaxLength) {
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
                  email: _usernameController.text, password: _pass, onStart: false));
            },
            focusNode: _usernameFocus,
            controller: _usernameController,
            expands: false,
            decoration: InputDecoration(
              hintText: 'Pick a username',
              hintStyle: TextStyle(fontSize: dimensions.sp14(), color: Colors.grey),
              enabledBorder: InputBorder.none,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            style: TextStyle(fontSize: dimensions.sp14(), color: loginTextColor, shadows: [
              Shadow(color: Colors.teal, blurRadius: 1, offset: Offset.zero),
              Shadow(color: Colors.white, blurRadius: 5, offset: Offset(0, 0)),
            ]),
            maxLength: 16,
            textInputAction: TextInputAction.done,
          ),
        ),

        // Let's go button
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: state is NewUserCreatedState ? 0 : dimensions.buttonsHeight(),
          margin: EdgeInsets.only(bottom: mainPadding, top: mainPadding),
          width: state is NewUserCreatedState ? 0 : MediaQuery.of(context).size.width / 3,
          decoration: ShapeDecoration(
              color: usernameChecked ? Colors.white : Colors.grey[350],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(mainPadding)),
                  side: BorderSide(color: usernameChecked ? Colors.white : Colors.grey[350]))),
          child: RawMaterialButton(
            onPressed: () async {
              // Verify username
              var t = _usernameController.text; // Username text
              // Check for whitespaces
              if (t.toLowerCase().trim() == '') {
//                setState(() {
//                  usernameErrorText = "Please pick a username.";
//                });
              // Just fucking do nothing
                return;
              } else if (t.contains(' ') || t.contains(RegExp(r'\s'))) {
                setState(() {
                  usernameErrorText = "No whitespaces allowed.";
                });
                return;
              }
              // Check duplicate
              var exists = await fUtils.checkDuplicateUsername(t);
              if (exists) {
                setState(() {
                  usernameErrorText = "Duplicate username.";
                });
                return;
              }

              _usernameController.text = '';
              _usernameFocus.unfocus();

                loginBloc.add(CreateNewUser(
                    firebaseUser, currentUser.loginMethod?.first ?? [], t.toLowerCase().trim(), currentUser.password));
            },
            child: Text(
              state is NewUserCreatedState ? '' : "Let's go!",
              style: TextStyle(color: usernameChecked ? Colors.green : Colors.white),
            ),
          ),
        ),

        // Error text
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
            height: state is NewUserCreatedState ? 0 : dimensions.dim35(),
            alignment: Alignment.center,
            width: state is NewUserCreatedState ? 0 : MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: dimensions.dim4()),
            child: Text(
              usernameErrorText,
              style: TextStyle(color: colorBlueDarkText),
            )),

        successNewUser(state)
      ],
    );
  }

  Widget successNewUser(dynamic state) {
    return Container(
      height: mSize.setHeight(315),
      width: mSize.setHeight(315),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: state is NewUserCreatedState
            ? 1
            : 0,
        child: AnimatedSize(
          duration: Duration(milliseconds: 300),
          vsync: this,
          child: Transform.scale(
            alignment: FractionalOffset.center,
            scale: state is NewUserCreatedState
                ? 1
                : 0,
            child: FlareActor('assets/flare/success.flr', animation: 'idle', fit: BoxFit.contain,
                callback: ((_) {
                  setState(() {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => MainScreen()));
                  });
                })),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _usernameController?.dispose();
    _pageViewController?.dispose();
    _passwordController?.dispose();
    _emailController?.dispose();

    _usernameFocus?.dispose();
    _emailFocus?.dispose();
    _passwordFocus?.dispose();
  }

}
