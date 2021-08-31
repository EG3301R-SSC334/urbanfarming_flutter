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

import 'auth.dart';

Auth _auth = Auth();

class LogInPageState extends State {
	void authCB() {
		print("LOGIN Page Auth CB Called");
		setState(() {
			_auth.removeCB(authCB);
			Navigator.pop(context);
		});
	}

	@override
	Widget build(BuildContext context) {
		_auth.addCB(authCB);

		return Scaffold(
			appBar: AppBar(
				title: Text("Log in"),
			),
			body: Column(
				children: [
					Text("You need to login to use the app mate"),
					Text((_auth.isSignedIn()) ? "SIGNED IN " : "Not signed in yet"),
					ElevatedButton(
						child: Text("Log In"),
						onPressed: () => _auth.signInSync()
					),
					ElevatedButton(
						child: Text("go back"),
						onPressed: () => Navigator.pop(context),
					),
					ElevatedButton(
						child: Text("set state"),
						onPressed: () => setState(() {}),
					),
				]
			)
		);
	}
}

class LogInPage extends StatefulWidget {
	@override
	LogInPageState createState() => LogInPageState();
}