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

import 'graphs.dart';
import 'server.dart';
import 'summary_table.dart';

class SystemPage extends StatelessWidget {
	final System system;

	SystemPage(this.system);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(system.name ?? "no name")
			),
			body: Center(
				child: ListView(
					children: [
						SummaryTable(system),
						Graph(
							title: "Temperature",
							data: system.temperature
						),
						Graph(
							title: "Humidity",
							data: system.humidity
						),
						Graph(
							title: "EC",
							data: system.ec
						),
						Graph(
							title: "pH",
							data: system.ph
						),
					],
				),
			),
		);
	}
}