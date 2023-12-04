import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    
  runApp(const MainApp());

}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Flutter VET APP',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 34, 159)),
        ),
      home: const Scaffold(
        body: Center(
          child: LoginWidget(),//Text("HELLO WORLD"),
        ),
      ),
    );
  }
}

//Login & sign up view
class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  @override
  Widget build(BuildContext context) {

    TextEditingController login = TextEditingController();
    TextEditingController password = TextEditingController();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print("usuario: ${user.uid}");
      } else {
        print("No hay usuario!");
      }
    });

    setState(() {
      login.text = "";
      password.text = "";
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AppBar(
          title: const Text('THE VET APP',  style: TextStyle(fontWeight: FontWeight.bold),),
        ),
         Container(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration:  InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                icon: Icon(
                  Icons.email, 
                  color: Theme.of(context).primaryColor
                ),
                labelText: "Login",
                 labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor
                  ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor
              ),
              controller: login,
              keyboardType: TextInputType.emailAddress,
            )),
         Container(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
              ),
              icon: Icon(
                  Icons.password, 
                  color: Theme.of(context).primaryColor
                ),
              labelText: "Password",
              labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor
                  ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor
            ),
            controller: password,
            obscureText: true,
             keyboardType: TextInputType.number,
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              final user = await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: login.text, password: password.text);
              print("USUARIO CREADO: ${user.user?.uid}");

              Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MenuWidget()),
              );
            } on FirebaseAuthException catch (e) {
              print('Failed with error code: ${e.code}');
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('An error occurred: ${e.message}'),
                    );
                  },
                );
              print(e.message);
            }
          },
          child: const Text("Sign Up")
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final user = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: login.text, password: password.text);

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const  MenuWidget()),
                  );
                print("usuario ha logrado logearse: ${user.user?.uid}");
              } on FirebaseAuthException catch (e)  {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('An error occurred: ${e.message}'),
                    );
                  },
                );
              }
            },
            child: const Text("Log In")
          ),
      ]
    );
  }
}


class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
 final Stream<QuerySnapshot> _animalsStream =
      FirebaseFirestore.instance.collection("Animals").snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _animalsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return const Text("ERROR AL HACER QUERY, FAVOR DE VERIFICAR");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return Scaffold(
              appBar: AppBar(
              title: Transform(
                transform: Matrix4.translationValues(10.0, 0.0, 0.0),
                child: const Text('Menu'),),
              centerTitle: false,
              actions: <Widget>[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailWidget(),
                      settings: const RouteSettings(
                        arguments: null,
                      ),
                    ),
                    );
                  },
                  label: const Text(
                    'Register \nnew animal', 
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  icon: const Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    shape:  RoundedRectangleBorder(
                    borderRadius:  BorderRadius.circular(20.0),
                  ),
                ),
              ),
              ]
            ),
            body: Center(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data?.docs.length ?? 0,
                itemBuilder: (context, index){
                   final data = snapshot.data?.docs[index].data() as Map<String, dynamic>;
                   return ListTile(
                        contentPadding: const EdgeInsets.all(20.0),
                        leading: const Icon(Icons.pets) ,
                        title: Text(data['name'] ?? 'No data'),
                        trailing: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetailWidget(),
                              settings:RouteSettings(
                                arguments: snapshot.data?.docs[index].data(),
                              ),
                            ),
                            );
                            print(snapshot.data?.docs[index].data()!);

                          },
                          icon: const Icon(Icons.info),
                          label: const Text('Check details'),
                          style: ElevatedButton.styleFrom(
                              shape:  RoundedRectangleBorder(
                              borderRadius:  BorderRadius.circular(20.0),
                            ),
                          ),       
                        )                    
                      );
                },
              )
            ),
          );
        },
      );
    }
}

class DetailWidget extends StatefulWidget {
  const DetailWidget({super.key});

  @override
  State<DetailWidget> createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget> {
  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> mapArgs = args is Map<String, dynamic> ? args : {};
    final FirebaseFirestore db = FirebaseFirestore.instance;

    TextEditingController name = TextEditingController();
    TextEditingController age = TextEditingController();
    TextEditingController weight = TextEditingController();

    setState(() {
      name.text = "";
      age.text = "";
      weight.text = "";
    });

    if (mapArgs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Registration'),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText:  "Enter the animals name",
                    icon: Icon(Icons.abc),
                    labelText: 'Name'
                  ),
                  controller: name,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText:  "Enter the animals age",
                    icon: Icon(Icons.calendar_today),
                    labelText: 'age'
                  ),
                  controller: age,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText:  "Enter the animals name",
                    icon: Icon(Icons.monitor_weight),
                    labelText: 'Weight'
                  ),
                  controller: weight,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                      onPressed: () async {

                      final animal = <String, dynamic>{
                        "name": name.text,
                        "age": age.text,
                        "weight": weight.text
                      };

                      db.collection('Animals')
                        .add(animal)
                        .then((DocumentReference documento) =>
                            print("nuevo doc: ${documento.id}"));

                       Navigator.pop(context);


                      },
                      style: ElevatedButton.styleFrom(
                        shape:  RoundedRectangleBorder(
                        borderRadius:  BorderRadius.circular(20.0),
                        ),
                       ),
                      child: const Text('Register'),
                  ),
                )
              ],),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detail'),
        ),
        body: Center(
          child: Column(
            children: [
              const Icon(
                Icons.pets,  
                size: 50,
              ),
              Text("${mapArgs['name']}"),
              Text("Age: ${mapArgs['age']}"),
              Text("Weight: ${mapArgs['weight']}"),
            ],),
        ),
      );
    }
  }
}

