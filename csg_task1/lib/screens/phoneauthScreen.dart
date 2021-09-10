import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class PhoneVerification extends StatefulWidget {
  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final phoneVerificationController = TextEditingController();

  String code = "";
  bool codeSent = false;
  String verId = "";
  bool failed = false;

  Future<void> VerifyCode(String pin) async {
    PhoneAuthCredential Credential =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: pin);
    try {
      await FirebaseAuth.instance.signInWithCredential(Credential);
      final SnakBar = SnackBar(content: Text('login successful'));
      ScaffoldMessenger.of(context).showSnackBar(SnakBar);
    } on FirebaseAuthException catch (e) {
      final SnakBar = SnackBar(content: Text('${e.message}'));
      ScaffoldMessenger.of(context).showSnackBar(SnakBar);
      failed = true;
    }
  }

  Future<void> verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+201153478112',
        verificationCompleted: (PhoneAuthCredential credential) async {
          FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          failed = true;
        },
        codeSent: (String VerificationId, int? resendToken) async {
          setState(() {
            codeSent = true;
            verId = VerificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            verId = verificationId;
          });
        },
        timeout: Duration(seconds: 60));
  }

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scafoldKey = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    //verifyPhone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: verifyPhone(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return CircularProgressIndicator();
              else if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    // Image.asset(""),
                    Image(
                        image: NetworkImage(
                            "https://images.unsplash.com/photo-1552207802-77bcb0d13122?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1534&q=80")),

                    Container(
                      color: Colors.blue.withOpacity(0.9),
                      padding: EdgeInsets.only(top: 60, right: 30, left: 30),
                      child: Form(
                        key: _formKey,
                        child: Center(
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.verified_user,
                                size: 50,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "SMS verification ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                  "please enter the verification code sent that you recieved via sms in order to activate your account",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: phoneVerificationController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.verified_outlined),
                                  hintText: 'Phone Verification code',
                                  labelText: 'Verification code',
                                ),
                                onSaved: (String? value) async {
                                  await VerifyCode(value!);
                                  if (failed == true) {
                                    final SnakBar =
                                        SnackBar(content: Text('wrong code'));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnakBar);
                                  } else {
                                    final SnakBar = SnackBar(
                                        content: Text('login successful'));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnakBar);
                                  }
                                },
                                validator: (String? value) {
                                  print("on validator " + value!);
                                  if (value.length < 6)
                                    return 'verification code must be 6 numbers';

                                  return null;
                                },
                                onFieldSubmitted: (value) {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return CircularProgressIndicator();
            }));
  }
}
