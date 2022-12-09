import 'package:blogapp/components/round_button.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPassword();
}

class _ForgotPassword extends State<ForgotPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String email = '';
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
          // automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Email',
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email)),
                          onChanged: (String value) {
                            email = value;
                          },
                          validator: (value) {
                            return value!.isEmpty ? 'Please enter email' : null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 43),
                          child: RoundButton(
                              title: 'Send Email',
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    showSpinner = true;
                                  });
                                  try {
                                    _auth
                                        .sendPasswordResetEmail(
                                            email: _emailController.text
                                                .toString())
                                        .then((value) {
                                      setState(() {
                                        showSpinner = false;
                                      });
                                      toastmessaging(
                                          'Please Check Your Email A Reset Email Link Sent to Your Provided Email');
                                    }).onError((e, stackTrace) {
                                      toastmessaging(e.toString());
                                      setState(() {
                                        showSpinner = false;
                                      });
                                    });
                                  } catch (e) {
                                    toastmessaging(e.toString());
                                    setState(() {
                                      showSpinner = false;
                                    });
                                  }
                                }
                              }),
                        )
                      ],
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  void toastmessaging(String message) {
    Fluttertoast.showToast(
        msg: message.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}
