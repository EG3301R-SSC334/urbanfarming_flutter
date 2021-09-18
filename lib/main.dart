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

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:urbanfarming_flutter/login_page.dart';

import 'server.dart';
import 'graphs.dart';
import 'auth.dart';

class _HomePageState extends State {
	Auth auth = Auth();
	List<Plant> plants = [];
	Server server = Server(0);

	@override
	void initState() {
		super.initState();
		auth.addCB(authCB);
		WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {postBuild();});
	}

	void _cb(List<Plant> newList) {
		plants = newList;
		setState(() {print("SET STATE");});
	}

	void postBuild() {
		if (!auth.isSignedIn()) {
			Navigator.push(context, MaterialPageRoute(builder: (context) => LogInPage()));
		}
	}

	void authCB() {
		print("Main Page Auth CB Called");
		setState(() {
		  print(auth.getUser().toString());
		});
	}

	@override
	Widget build(BuildContext context) {
		server.addCB(_cb);

		GoogleSignInAccount? user = auth.getUser();
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				Container(
					child: TestGraph.withData(),
					height: 200,
				),
				// Container(
				// 	child: TestGraph.withData(),
				// 	height: 300,
				// ),
				Text(auth.getUser().toString()),
				(user != null) ?
				Text('${user.email} ${user.displayName} ${user.id} ${auth.toString()}') :
				Text('Not logged in yet'),
				ElevatedButton(
					child: Text("Log in"),
					onPressed: () => auth.signIn(),
				),
				ElevatedButton(
					child: Text("Log out"),
					onPressed: () => auth.signOut(),
				),
				ElevatedButton(
					child: Text("Sign in page"),
					onPressed: () => Navigator.push(context, MaterialPageRoute(
						builder: (context) {
							return LogInPage();
						}
					))
				),
				ElevatedButton(
					child: Text("set state"),
					onPressed: () => setState(() {})
				),
				ElevatedButton(
					child: Text("Sign in status"),
					onPressed: () => auth.isSignedIn(),
				),
			],
		);
	}
}

class HomePage extends StatefulWidget {
	@override
	_HomePageState createState() => _HomePageState();
}

class UrbanFarmingApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) => MaterialApp(
		title: "Urban Farming",
		home: Scaffold(
			appBar: AppBar(
				title: Text("Urban Farming")
			),
			body: HomePage()
		)
	);
}

void main() => runApp(UrbanFarmingApp());