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

import 'user_page.dart';
import 'login_page.dart';
import 'summary_table.dart';
import 'server.dart';
import 'system_page.dart';
import 'bt_page.dart';

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
					child: (_system != null) ? Column(
						children: [
							Text(
								_system!.name ?? "System",
								style: TextStyle(
									fontSize: 20,
									fontWeight: FontWeight.bold
								),
							),
							InkWell(
								child: SummaryTable(_system!),
								onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SystemPage(_system!))),
							)
						]
					) : Container(
						child: Center(
							child: SizedBox(
								child: CircularProgressIndicator(),
								height: 50,
								width: 50,
							)
						),
						height: 170
					)
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
					onPressed: () {
						Navigator.push(context, MaterialPageRoute(builder: (context) => BTPage()));
					},
				),
			],
		);
	}
}

class SummaryPage extends StatefulWidget {
	@override
	_SummaryPageState createState() => _SummaryPageState();
}

class _MainDrawerState extends State {
	Server _server = Server();
	List<System> _systems = [];

	@override
	void initState() {
		super.initState();
		_server.addCB(Server.system, _systemsCB);
		_systems = _server.systems;
		print(_systems);
	}

	void _systemsCB(List<System> retList) {
		print("DRAWER SYSTEM CB CALLED");
		_systems = retList;
		setState(() {});
	}

	@override
	Widget build(BuildContext context) => Drawer(
		child: ListView.builder(
			itemCount: _systems.length + 2,
			itemBuilder: (context, index) {
				print(index);
				if (index == 0) {
					return DrawerHeader(
						child: Container(
							child: Text("Header"),
						),
					);
				} else if (index == _systems.length + 1) {
					return ListTile(
						title: Text("User"),
						onTap: () {
							Navigator.pop(context);
							Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage()));
						},
					);
				} else {
					return ListTile(
						title: Text(_systems[index - 1].name ?? "System ${index - 1}"),
						onTap: () {
							Navigator.pop(context);
							Navigator.push(context, MaterialPageRoute(builder: (context) => SystemPage(_systems[index - 1])));
						}
					);
				}
			}
		)
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