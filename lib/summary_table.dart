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

class _TableItem extends StatelessWidget {
	final String heading;
	final double value;

	_TableItem({required this.heading, required this.value});

	@override
	Widget build(BuildContext context) => Container(
		height: 75,
		child: Column(
			mainAxisAlignment: MainAxisAlignment.center,
			children: [
				Text(heading, style: TextStyle(fontWeight: FontWeight.bold)),
				Text(value.toStringAsPrecision(3))
			],
		)
	);
}

class _SummaryTableState extends State<SummaryTable> {
	@override
	Widget build(BuildContext context) {
		return Table(
			children: [
				TableRow(
					children: [
						_TableItem(
							heading: "Humidity",
							value: widget.system.humidity.last.value,
						),
						_TableItem(
							heading: "Temperature",
							value: widget.system.temperature.last.value,
						)
					],
				),
				TableRow(
					children: [
						_TableItem(
							heading: "pH",
							value: widget.system.ph.last.value,
						),
						_TableItem(
							heading: "EC",
							value: widget.system.ec.last.value,
						)
					]
				)
			]
		);
	}
}

class SummaryTable extends StatefulWidget  {
	final System system;

	SummaryTable(this.system);

	@override
	_SummaryTableState createState() => _SummaryTableState();
}