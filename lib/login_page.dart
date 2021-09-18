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
			Navigator.pop(context);
		});
	}

	@override
	Widget build(BuildContext context) {
		_auth.addCB(authCB);

		return WillPopScope(
			onWillPop: () async => false,
			child: Scaffold(
				appBar: AppBar(
					title: Text("Log in"),
					automaticallyImplyLeading: false,
				),
				body: Center(
					child: ElevatedButton(
						child: Text("Log in with Google"),
						onPressed: () => _auth.signInSync(),
					)
				)
			)
		);
	}

	@override
	void dispose() {
		_auth.removeCB(authCB);
		super.dispose();
	}
}

class LogInPage extends StatefulWidget {
	@override
	LogInPageState createState() => LogInPageState();
}