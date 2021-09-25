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
import 'package:charts_flutter/flutter.dart' hide TextStyle;

import 'login_page.dart';
import 'user_page.dart';

import 'server.dart';
import 'graphs.dart';
import 'auth.dart';

class GridItem extends StatelessWidget {
	final String heading;
	final int value;

	GridItem({required this.heading, required this.value});

	@override
	Widget build(BuildContext context) => Container(
		height: 75,
		child: Column(
			mainAxisAlignment: MainAxisAlignment.center,
			children: [
				Text(heading, style: TextStyle(fontWeight: FontWeight.bold)),
				Text(value.toString())
			],
		)
	);
}

class _HomePageState extends State {
	Auth auth = Auth();
	List<Plant> plants = [];
	Server server = Server();
	// System? system;
	System system = System(
		name: "name",
		owner: "owner",
		plantType: "plant"
	);
	

	List<Series<TestData, DateTime>> testgraph = TestGraph.createData();

	@override
	void initState() {
		super.initState();
		auth.addCB(authCB);
		WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {postBuild();});

		system.humidity = [
			DataPoint(1, DateTime.now()),
			DataPoint(2, DateTime.now()),
			DataPoint(3, DateTime.now()),
			DataPoint(4, DateTime.now()),
			DataPoint(5, DateTime.now()),
			DataPoint(6, DateTime.now()),
		];
		system.temperature = [
			DataPoint(1, DateTime.now()),
			DataPoint(2, DateTime.now()),
			DataPoint(3, DateTime.now()),
			DataPoint(4, DateTime.now()),
			DataPoint(5, DateTime.now()),
			DataPoint(6, DateTime.now()),
		];
		system.ph = [
			DataPoint(1, DateTime.now()),
			DataPoint(2, DateTime.now()),
			DataPoint(3, DateTime.now()),
			DataPoint(4, DateTime.now()),
			DataPoint(5, DateTime.now()),
			DataPoint(6, DateTime.now()),
		];
		system.ec = [
			DataPoint(1, DateTime.now()),
			DataPoint(2, DateTime.now()),
			DataPoint(3, DateTime.now()),
			DataPoint(4, DateTime.now()),
			DataPoint(5, DateTime.now()),
			DataPoint(6, DateTime.now()),
		];
	}

	void _cb(List<Plant> newList) {
		plants = newList;
		setState(() {print("SET STATE");});
	}

	void _systemCB(System newSystem) {
		system = newSystem;
		setState(() {print("new system set");});
	}

	void postBuild() {
		if (!auth.isSignedIn()) {
			Navigator.push(context, MaterialPageRoute(builder: (context) => LogInPage()));
		}
	}

	void authCB() {
		setState(() {
		  print(auth.getUser().toString());
		});
	}

	@override
	Widget build(BuildContext context) {
		server.addCB(_cb);
		server.addSystemCB(_systemCB);

		GoogleSignInAccount? user = auth.getUser();

		return Scaffold(
			appBar: AppBar(
				title: Text("Urban Farming"),
				actions: [
					IconButton(
						// icon: const Icon(Icons.account_circle_outlined),
						// icon: (user != null) ? Image.network(user?.photoUrl ?? "http://cdn.onlinewebfonts.com/svg/img_504768.png") : const Icon(Icons.account_circle_outlined),
						icon: CircleAvatar(
							backgroundImage: NetworkImage(auth.getPhoto()),
							backgroundColor: Colors.green,
							child: Text(auth.getInitials()),
						),
						onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage()))
					)
				],
			),
			body: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					Card(
						child: Table(
							children: [
								TableRow(
									children: [
										GridItem(
											heading: "Humidity",
											value: system.humidity.last.data,
										),
										GridItem(
											heading: "Temperature",
											value: system.temperature.last.data,
										),
									]
								),
								TableRow(
									children: [
										GridItem(
											heading: "pH",
											value: system.ph.last.data,
										),
										GridItem(
											heading: "EC",
											value: system.ec.last.data,
										),
									]
								)
							],
						),
					),
					Card(
						margin: EdgeInsets.all(10),
						child: Graph(
							title: "Test",
								data: testgraph
						)
					),
					ElevatedButton(
						child: Text("Sign in status"),
						onPressed: () => auth.isSignedIn(),
					),
					ElevatedButton(
						child: Text("trial"),
						onPressed: () async {
							GoogleSignInAuthentication? authen = await user?.authentication;
							print("AUTH TOKEN: ${authen?.idToken}");
							print(user?.email);
						},
					)
				],
			),
		);
	}
}

class HomePage extends StatefulWidget {
	@override
	_HomePageState createState() => _HomePageState();
}