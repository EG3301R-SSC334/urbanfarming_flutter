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
import 'package:charts_flutter/flutter.dart' hide TextStyle;

class Graph extends StatelessWidget {
	final String title;
	final List<DataPoint> data;
	final bool animate;

	Graph({required this.title, required this.data, this.animate = false});
	
	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(10),
			child: Column(
				children: [
					Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
					Container(
						height: 200,
						child: TimeSeriesChart(
							[Series(
								id: title,
								data: data,
								domainFn: (data, _) => data.time,
								measureFn: (data, _) => data.value
							)],
							animate: animate,
						)
					)
				]
			)
		);
	}
}

class DataPoint {
	final int value;
	final DateTime time;

	DataPoint(this.value, this.time);
}