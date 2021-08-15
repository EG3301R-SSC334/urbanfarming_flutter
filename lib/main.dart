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

import 'server.dart';
import 'graphs.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
	clientId: "",
	scopes: [
    'https://www.googleapis.com/auth/userinfo.email'
	]
);

class _HomePageState extends State {
	List<Plant> plants = [];
	Server server = Server(0);

	GoogleSignInAccount? _currentUser;
	
	@override
	void initState() {
		super.initState();
		_googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
			setState(() {
				print("\n\n\nsetting state\n\n");
				_currentUser = account;
        print(_currentUser);
			});
			if (_currentUser != null) {
				print("\n\n\nGot account\n\n");
			}
		});
		_googleSignIn.signInSilently();
	}

	void _cb(List<Plant> newList) {
		plants = newList;
		setState(() {print("SET STATE");});
	}

	Future<void> _handleSignIn() async {
		try {
			await _googleSignIn.signIn();
		} catch (error) {
			print("\n\n Failed to sign in\n\n");
			print(error);
		}
	}

	@override
	Widget build(BuildContext context) {
		server.addCB(_cb);
		GoogleSignInAccount? user = _currentUser;
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				Container(
					child: TestGraph.withData(),
					height: 200,
				),
				Container(
					child: TestGraph.withData(),
					height: 300,
				),
				(user != null) ?
				Text('${user.email} ${user.displayName} ${user.id}') :
				Text('Not logged in yet'),
				ElevatedButton(
					child: Text("Log in"),
					// onPressed: () => _googleSignIn.signIn(),
					onPressed: () => _handleSignIn(),
				),
				ElevatedButton(
					child: Text("Log out"),
					onPressed: () => _googleSignIn.disconnect()
				)
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
			body: HomePage(),
		)
	);
}

void main() => runApp(UrbanFarmingApp());