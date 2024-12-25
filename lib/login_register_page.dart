import 'package:bolosewu/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
  bool _obscureText = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> signInWithEmailAndPassword() async{
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async{
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _entryField(
      String title,
      TextEditingController controller,
      ){
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage (){
    return Text(errorMessage == '' ? '' : 'Humm? $errorMessage');
  }

  Widget _submitButton(){
    return ElevatedButton(
      onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(
        isLogin ? 'Login' : 'Register'
      ),
    );
  }

  Widget _loginOrRegisterButton (){
    return TextButton(
      onPressed: (){setState(() {
        isLogin = !isLogin;
      });},
      child: Text(
        isLogin ? 'Register Instead' : 'Login Instead'
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/splash_logo.png'),
              SizedBox(height: 20,),
              TextFormField(
                controller: _controllerEmail,
                decoration: InputDecoration(
                  labelText : 'Username',
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )
                ),
              ),
              SizedBox(height: 20,),
              TextFormField(
                controller: _controllerPassword,
                decoration: InputDecoration(
                    labelText : 'Password',
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  suffixIcon: IconButton(
                    onPressed: _toggleObscureText,
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                obscureText: _obscureText,
              ),
              _errorMessage(),
              _submitButton(),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
}
