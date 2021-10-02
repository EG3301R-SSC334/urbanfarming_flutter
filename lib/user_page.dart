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

import 'login_page.dart';

import 'server.dart';

class UserPage extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		Server _server = Server();
		User _user = _server.getUser()!;

		return Scaffold(
			appBar: AppBar(
				title: Text(_user.name),
			),
			body: Center(
			  child: DefaultTextStyle(
					style: TextStyle(
						fontSize: 30,
						color: Colors.black
					),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Container(
								child: Column(
									children: [
										CircleAvatar(
											backgroundImage: NetworkImage(_user.photoURL),
											backgroundColor: Colors.green,
											radius: 100,
											child: Text(
												_user.initials,
												style: TextStyle(
													fontSize: 100
												),
											),
										),
										Text(_user.name),
										Text(_user.email),
									],
								)
							),
							Container(
								width: MediaQuery.of(context).size.width * 0.9,
								child: ElevatedButton(
									child: Text("Log out"),
									onPressed: () {
									_server.signOut().then((_) {
										Navigator.push(context, MaterialPageRoute(builder: (context) => LogInPage()));
									});
								},
								),
							)
						],
					),
				),
			),
		);
	}
}