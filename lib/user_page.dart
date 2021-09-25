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

import 'auth.dart';

class UserPage extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		Auth _user = Auth();

		return Scaffold(
			appBar: AppBar(
				title: Text(_user.getName()),
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
											backgroundImage: NetworkImage(_user.getPhoto()),
											backgroundColor: Colors.green,
											radius: 100,
											child: Text(
												_user.getInitials(),
												style: TextStyle(
													fontSize: 100
												),
											),
										),
										// SizedBox(height: 10),
										Text(_user.getName()),
										// SizedBox(height: 10),
										Text(_user.getEmail()),
										// SizedBox(height: 10),
									],
								)
							),
							Container(
								width: MediaQuery.of(context).size.width * 0.9,
								child: ElevatedButton(
									child: Text("Log out"),
									onPressed: () {
									_user.signOut().then((_) {
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