// Copyright (C) 2021 Rumesh Sudhaharan 
//
// This file is part of urbanfarming_flutter.
//
// urbanfarming_flutter is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// urbanfarming_flutter is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with urbanfarming_flutter.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart' hide DataTable;
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:charts_flutter/flutter.dart' hide TextStyle;

import 'login_page.dart';
import 'user_page.dart';
import 'system_page.dart';

import 'data_table.dart';

import 'server.dart';
import 'graphs.dart';
// import 'auth.dart';

class _HomePageState extends State {
	// Auth _auth = Auth();
	// List<Plant> plants = [];
	Server _server = Server();
	// System system = System.sample();
	System system = System(plantType: "test");
	
	@override
	void initState() {
		super.initState();
		_server.addAuthCB(authCB);
		WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {postBuild();});
	}

	// void _cb(List<Plant> newList) {
	// 	plants = newList;
	// 	setState(() {print("SET STATE");});
	// }

	void _systemCB(System newSystem) {
		system = newSystem;
		setState(() {print("new system set");});
	}

	void postBuild() {
		if (!_server.isSignedIn()) {
			Navigator.push(context, MaterialPageRoute(builder: (context) => LogInPage()));
		}
	}

	void authCB() {
		setState(() {
		  print(_server.getUser().toString());
		});
	}

	@override
	Widget build(BuildContext context) {
		// server.addCB(_cb);
		_server.addCB(_systemCB);

		// GoogleSignInAccount? user = auth.getUser();
		User _user = _server.getUser()!;

		return Scaffold(
			appBar: AppBar(
				title: Text("Urban Farming"),
				actions: [
					IconButton(
						icon: CircleAvatar(
							backgroundImage: NetworkImage(_user.photoURL),
							backgroundColor: Colors.green,
							child: Text(_user.initials),
						),
						onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage()))
					)
				],
			),
			body: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					Card(
						child: DataTable(system)
					),
					Card(
						margin: EdgeInsets.all(10),
						child: Graph(
							title: "Test",
								data: system.temperature
						)
					),
					ElevatedButton(
						child: Text("Sign in status"),
						onPressed: () => _server.isSignedIn(),
					),
					// ElevatedButton(
					// 	child: Text("trial"),
					// 	onPressed: () async {
					// 		GoogleSignInAuthentication? authen = await _auth.authentication;
					// 		print("AUTH TOKEN: ${authen?.idToken}");
					// 		print(_user.email);
					// 	},
					// )
				],
			),
		);
	}
}

class HomePage extends StatefulWidget {
	@override
	_HomePageState createState() => _HomePageState();
}