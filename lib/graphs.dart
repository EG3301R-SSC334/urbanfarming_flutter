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

class TestGraph extends StatelessWidget {
	final List<Series<dynamic, DateTime>> seriesList;
	final bool animate;

	TestGraph(this.seriesList, this.animate);

	factory TestGraph.withData() {
		return TestGraph(_createData(), true);
	}

	@override
	Widget build(BuildContext context) {
		return TimeSeriesChart(
			seriesList,
			animate: animate,
		);
	}

	static List<Series<TestData, DateTime>> _createData() {
		final data = [
			TestData(DateTime(2021, 7, 1), 25),
			TestData(DateTime(2021, 7, 2), 23),
			TestData(DateTime(2021, 7, 3), 30),
			TestData(DateTime(2021, 7, 4), 20),
			TestData(DateTime(2021, 7, 6), 15),
			TestData(DateTime(2021, 7, 7), 4),
			TestData(DateTime(2021, 7, 8), 65),
		];

		return [Series<TestData, DateTime>(
			id: 'Test',
			domainFn: (TestData data, _) => data.time,
			measureFn: (TestData data, _) => data.data,
			data: data
		)];
	}

	static List<Series<TestData, DateTime>> createData() {
		final data = [
			TestData(DateTime(2021, 7, 1), 25),
			TestData(DateTime(2021, 7, 2), 23),
			TestData(DateTime(2021, 7, 3), 30),
			TestData(DateTime(2021, 7, 4), 20),
			TestData(DateTime(2021, 7, 6), 15),
			TestData(DateTime(2021, 7, 7), 4),
			TestData(DateTime(2021, 7, 8), 65),
		];

		return [Series<TestData, DateTime>(
			id: 'Test',
			domainFn: (TestData data, _) => data.time,
			measureFn: (TestData data, _) => data.data,
			data: data
		)];
	}
}

class TestData {
	final DateTime time;
	final int data;

	TestData(this.time, this.data);
}

class Graph extends StatelessWidget {
	final String title;
	final List<Series<dynamic, DateTime>> data;
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
							data,
							animate: animate,
						)
					)
				]
			)
		);
	}
}

class DataPoint {
	final int data;
	final DateTime time;

	DataPoint(this.data, this.time);
}