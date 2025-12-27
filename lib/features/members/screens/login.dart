import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/providers/login_provider.dart';
import 'package:my_gate_clone/features/members/screens/homepage.dart';
import 'package:my_gate_clone/utilis/appbar.dart';
import 'package:provider/provider.dart';

class MemberLogin extends StatefulWidget {
  const MemberLogin({super.key});

  @override
  State<MemberLogin> createState() => _MemberLoginState();
}

class _MemberLoginState extends State<MemberLogin> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MembersLoginProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: reuseAppBar(title: "Member Login"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/members.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Welcome, Member!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Login to access your account",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 25),
            Card(
              elevation: 7,
              color: Colors.white,
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildField(
                        controller: emailController,
                        label: "Member Email",
                        keyboard: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || v.isEmpty ? "Enter email" : null,
                      ),
                      const SizedBox(height: 15),
                      buildField(
                        controller: passwordController,
                        label: "Password",
                        obscure: true,
                        validator: (v) =>
                            v == null || v.isEmpty ? "Enter password" : null,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final member = await provider.loginMember(
                                      memberEmail: emailController.text.trim(),
                                      memberPassword: passwordController.text
                                          .trim(),
                                    );

                                    if (member == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Invalid email or password",
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Login Successful!"),
                                        ),
                                      );

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MemberHomepage(member: member),
                                        ),
                                      );

                                      emailController.clear();
                                      passwordController.clear();
                                    }
                                  }
                                },
                          child: provider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboard = TextInputType.text,
  bool obscure = false,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboard,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    validator: validator,
  );
}
