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

import 'user_page.dart';
import 'login_page.dart';


import 'summary_table.dart';
import 'graphs.dart';
import 'local_files.dart';
import 'server.dart';

class _SummaryPageState extends State {
	System? _system;
	Server _server = Server();

	void initState() {
		super.initState();
		WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {_postBuild();});
	}

	void _postBuild() {
		if (!_server.isSignedIn()) 
			Navigator.push(context, MaterialPageRoute(builder: (context) => LogInPage())).then((value) {
				_server.getSystems().then((system) {
					_system = system[0];
					setState(() {
						print("SETTING STATE");
					});
				});
			});
	}

	@override
	Widget build(BuildContext context) {
		return ListView(
			children: [
				Card(
					child: (_system != null) ? SummaryTable(_system!) : Container(),
				),
				Graph(
					title: "Temperature",
					data: _system?.temperature ?? [],
				), 
				Graph(
					title: "humidity",
					data: _system?.humidity ?? [],
				), 
				Graph(
					title: "pH",
					data: _system?.ph ?? [],
				), 
				Graph(
					title: "EC",
					data: _system?.ec ?? [],
				), 
				ElevatedButton(
					child: Text("GET SYSTEM"),
					onPressed: () {
						_server.getSystems().then((system) {
							_system = system[0];
							setState(() {});
						});
					},
				),
				ElevatedButton(
					child: Text("trial"),
					onPressed: () {},
				)
			],
		);
	}
}

class SummaryPage extends StatefulWidget {
	@override
	_SummaryPageState createState() => _SummaryPageState();
}

class _MainDrawerState extends State {
	LocalFiles files = LocalFiles();

	Future<void> getSystems() async {
		Map<String, dynamic> systemsMap = await files.readJson(LocalFiles.systemsFile);
		systemsMap["systems"].forEach((item) {
			print(item);
		});
	}


	@override
	void initState() {
		super.initState();
		getSystems();
	}

	@override
	Widget build(BuildContext context) => Drawer(
		child: ListView(
			children: [
				DrawerHeader(
					child: Container(
						child: Text("Header"),
					),
				),
				ListTile(
					title: Text("1"),
				),
				ListTile(
					title: Text("2"),
				),
				ListTile(
					title: Text("3"),
				),
				ListTile(
					title: Text("User"),
					onTap: () {
						Navigator.pop(context);
						Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage()));
					}
				)
			],
		),
	);
}

class MainDrawer extends StatefulWidget {
	@override
	_MainDrawerState createState() => _MainDrawerState();
}

class UrbanFarmingApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) => MaterialApp(
		title: "Urban Farming",
		home: Scaffold(
			appBar: AppBar(
				title: Text("Urban Farming"),
			),
			body: SummaryPage(),
			drawer: MainDrawer()
		)
	);
}

void main() {
	WidgetsFlutterBinding.ensureInitialized();
	runApp(UrbanFarmingApp());
} 