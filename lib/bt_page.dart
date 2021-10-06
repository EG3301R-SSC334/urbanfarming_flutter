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
import 'package:flutter_blue/flutter_blue.dart';

import 'bluetooth.dart';

class _BTPageState extends State {
	@override
	Widget build(BuildContext context) {
		BT _bt = BT();
		Stream stream = _bt.startScan();
		return Scaffold(
			appBar: AppBar(
				title: Text("BT Test Page"),
			),
			body: StreamBuilder<List<ScanResult>>(
				stream: _bt.startScan(),
				builder: (context, AsyncSnapshot<List<ScanResult>> snapshot) {
					return ListView.builder(
						itemCount: (snapshot.data?.length ?? 0) + 2,
						itemBuilder: (context, index) {
							if (index == 0) {
								return ElevatedButton(
									child: Text("Start"),
									onPressed: () {stream = _bt.startScan();},
								);
							} else if (index == 1) {
								return ElevatedButton(
									child: Text("STOP"),
									onPressed: () => _bt.stopScan(),
								);
							} else {
								if (snapshot.data?[index - 2].device.id.toString() == "DC:A6:32:EF:29:1C") {
									print("PI 4 FOUND");
									print(snapshot.data?[index - 2]);
								}

								ScanResult curDev = snapshot.data![index - 2];
								return ListTile(
									title: Text(curDev.device.id.toString()),
									subtitle: Text(curDev.device.type.toString()),
									onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BTDevicePage(_bt, curDev))),
								);
							}
						},
					);
				},
			),
		);
	}
}

class BTPage extends StatefulWidget {
	@override
	_BTPageState createState() => _BTPageState();
}

class _BTDevicePageState extends State<BTDevicePage> {
	ScanResult scanResult;
	BluetoothDevice device;
	BT bt;
	Map<BluetoothService, List<BluetoothCharacteristic>> chars = {};

	_BTDevicePageState(this.bt, this.scanResult):
		device = scanResult.device;

	Widget buildChars() {
		List<ListTile> _list = [];

		chars.forEach((service, characteristics) {
			_list.add(ListTile(
				title: Text(
					service.uuid.toString(),
					style: TextStyle(
						fontWeight: FontWeight.bold
					),
				),
			));
			characteristics.forEach((char) {
				_list.add(ListTile(
					title: Text(char.uuid.toString()),
					onTap: () async {
						List<int> result = await char.read();
						String resultStr = "";
						result.forEach((charInt) => resultStr += String.fromCharCode(charInt));

						showDialog(
							context: context,
							builder: (context) => SimpleDialog(
								title: Text("Char: ${char.uuid.toString()}"),
								children: [
									Text(result.toString()),
									Text(resultStr)
								],
							)
						);
					},
				));
			});
			_list.add(ListTile(title: Text("-------------"),));
		});

		print(_list);
		return Container(
			height: 700,
			child: ListView(
				children: _list,
			)
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(device.id.toString()),
			),
			body: ListView(
				children: [
					ElevatedButton(
						child: Text("Connect"),
						onPressed: () async {
							await bt.connect(device);
							setState(() => chars = bt.impCharacteristics);
						}
					),
					ElevatedButton(
						child: Text("Disconnect"),
						onPressed: () => device.disconnect(),
					),
					ElevatedButton(
						child: Text("Set State"),
						onPressed: () {
							setState(() {});
						},
					),
					buildChars()
				],
			),
		);
	}
}

class BTDevicePage extends StatefulWidget {
	final ScanResult scanResult;
	final BT bt;

	BTDevicePage(this.bt, this.scanResult);

	@override
	_BTDevicePageState createState() => _BTDevicePageState(bt, scanResult);
}