import 'package:darboda_rider/models/user_model.dart';
import 'package:darboda_rider/screens/auth/phone_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController controller = TextEditingController();

  String? _phoneNumber;
  String name = '';
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                child: Column(children: [
                  Image.network(
                    'https://www.dispatch.ug/wp-content/uploads/2018/07/SafeBoda-Vs-Tafify-Boda.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLogin ? 'LOGIN' : 'BECOME A DARBODA RIDER',
                            style: GoogleFonts.ibmPlexSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.grey.shade900),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 20),
                            child: Text(
                              'Enter your phone number to continue, we will send you OTP to verify.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade700),
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          if (!isLogin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.13)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xffeeeeee),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                onChanged: (val) {
                                  setState(() {
                                    name = val;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Full Name',
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Iconsax.user,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          if (!isLogin)
                            const SizedBox(
                              height: 15,
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.13)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xffeeeeee),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                InternationalPhoneNumberInput(
                                  onInputChanged: (PhoneNumber number) {
                                    setState(() {
                                      _phoneNumber = number.phoneNumber;
                                    });
                                  },
                                  onInputValidated: (bool value) {},
                                  selectorConfig: const SelectorConfig(
                                    selectorType:
                                        PhoneInputSelectorType.BOTTOM_SHEET,
                                  ),
                                  ignoreBlank: false,
                                  autoValidateMode: AutovalidateMode.disabled,
                                  selectorTextStyle:
                                      const TextStyle(color: Colors.black),
                                  textFieldController: controller,
                                  formatInput: false,
                                  maxLength: 9,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                  cursorColor: Colors.black,
                                  inputDecoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        bottom: 15, left: 0),
                                    border: InputBorder.none,
                                    hintText: 'Phone Number',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 16),
                                  ),
                                  onSaved: (PhoneNumber number) {},
                                ),
                                Positioned(
                                  left: 90,
                                  top: 8,
                                  bottom: 8,
                                  child: Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.black.withOpacity(0.13),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 70,
                          ),
                          MaterialButton(
                            minWidth: double.infinity,
                            onPressed: () async {
                              if ((_phoneNumber != null) &&
                                  _formKey.currentState!.validate()) {
                                final user = UserModel(
                                    phoneNumber: _phoneNumber, name: name);

                                Get.to(() => PhoneVerificationScreen(
                                      user: user,
                                      isSignUp: !isLogin,
                                    ));
                              }
                            },
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            child: Text(
                              isLogin ? 'Login' : "Register",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLogin
                                    ? 'Dont have an account? '
                                    : 'Already have an account?',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isLogin = !isLogin;
                                  });
                                },
                                child: Text(
                                  isLogin ? 'Register' : 'Login',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ])),
          ),
        ));
  }
}
