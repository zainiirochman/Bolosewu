import 'package:bolosewu/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
  bool _obscureText = true;
  bool _isLoading = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future <void> _loginGoogle() async {
    setState(() {
      _isLoading = true;
    });
    await Auth().signInWithGoogle();
    setState(() {
      _isLoading = false;
    });
  }

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

  Widget _errorMessage (){
    return Text(errorMessage == '' ? '' : 'Humm? $errorMessage');
  }

  Widget _submitButton(){
    return ElevatedButton(
      onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(
        isLogin ? 'Login' : 'Register',
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }

  Widget _loginOrRegisterButton (){
    return TextButton(
      onPressed: (){setState(() {
        isLogin = !isLogin;
      });},
      child: Text(
        isLogin ? 'Register Instead' : 'Login Instead',
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                  ),
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
              // Row(
              //   children: [
              //     Divider(
              //       height: 20,
              //       indent: 20,
              //       endIndent: 20,
              //       color: Colors.black,
              //     ),
              //     Text("or"),
              //     Divider(
              //       height: 20,
              //       indent: 20,
              //       endIndent: 20,
              //       color: Theme.of(context).colorScheme.onSurface,
              //     ),
              //   ],
              // ),
              ElevatedButton(
                onPressed: () {_loginGoogle();},
                child: Container(
                  // width: 200,
                  height: 50,
                  width: size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.google,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      SizedBox(width: 20,),
                      Text(
                        'Login With Google',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
