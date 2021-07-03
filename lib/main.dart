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

import 'server.dart';
import 'graphs.dart';

class _HomePageState extends State {
	List<Plant> plants = [];
	Server server = Server(0);

	void _cb(List<Plant> newList) {
		plants = newList;
		setState(() {print("SET STATE");});
	}

	@override
	Widget build(BuildContext context) {
		server.addCB(_cb);
		// return ListView.builder(
		// 	itemCount: plants.length + 1,
		// 	itemBuilder: (context, index) =>
		// 	(index == plants.length) ? 
		// 	ElevatedButton(
		// 		child: Text("Click Me"),
		// 		onPressed: () => server.update(),
		// 	) :
		// 	ListTile(
		// 		title: Text(plants[index].type),
		// 		subtitle: Text(plants[index].temperature.toString()),
		// 	),
		// );
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
				)
			],
		);

		// return ListView.builder(
		// 	itemCount: plants.length + 2,
		// 	itemBuilder: (context, index) {
		// 		if (index == plants.length) {
		// 			return ElevatedButton(
		// 				child: Text("Click Me"),
		// 				onPressed: () => server.update(),
		// 			);
		// 		} else if (index == plants.length + 1) {
		// 		} else {
		// 			return ListTile(
		// 				title: Text(plants[index].type),
		// 				subtitle: Text(plants[index].temperature.toString()),
		// 			);
		// 		}
		// 	}
		// );
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