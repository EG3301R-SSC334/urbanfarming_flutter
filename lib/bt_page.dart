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

	Future<void> refreshPage() async {
		await Future.delayed(Duration(seconds: 1));
		setState(() {});
		return;
	}


	@override
	Widget build(BuildContext context) {
		BT _bt = BT();
		Stream stream = _bt.scanForPlantStation();
		return Scaffold(
			appBar: AppBar(
				title: Text("BT Test Page"),
				actions: [
					IconButton(
						icon: Icon(Icons.refresh),
						onPressed: ()  {
							print("Scaning");
							setState(() {});
						}
					)
				],
			), 
			body: StreamBuilder<List<ScanResult>>(
				// stream: _bt.startScan(),
				stream: _bt.scanForPlantStation(),
				builder: (context, AsyncSnapshot<List<ScanResult>> snapshot) {
					return RefreshIndicator(
						onRefresh: () => refreshPage(),
						child: ListView.builder(
							physics: const AlwaysScrollableScrollPhysics(),
							itemCount: (snapshot.data?.length ?? 1),
							itemBuilder: (context, index) {
								if (snapshot.data == null) {
									return Container(
										// stop scrolling loading indicator
										height: MediaQuery.of(context).size.height - Scaffold.of(context).appBarMaxHeight!,
										child: Center(child: Text("No PlantStations found\nPull to refresh devices", textAlign: TextAlign.center,))
									);
								} else {
									ScanResult curDev = snapshot.data![index];
									return ListTile(
										title: (_bt.isPlantStation(curDev)) ? Text("Plantstation ${curDev.device.id.toString()}") : Text(curDev.device.id.toString()),
										subtitle: Text(curDev.device.id.toString()),
										onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BTDevicePage(_bt, curDev))).then((_) => curDev.device.disconnect()),
									);
								}
							}
						)
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

	void initState() {
		super.initState();
		bt.connect(device);
	}

	Future<String> readStr(BluetoothCharacteristic char) async {
		String retStr = "";
		List<int> result = await char.read();
		result.forEach((charInt) => retStr += String.fromCharCode(charInt));
		return retStr;
	}

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
						String resultStr = await readStr(char);

						showDialog(
							context: context,
							builder: (context) => SimpleDialog(
								title: Text("Char: ${char.uuid.toString()}"),
								children: [
									// ListTile(title: Text(result.toString())),
									ListTile(title: Text(resultStr)),
									ListTile(title: Text("READ: ${(char.properties.read) ? "TRUE": "False"}")),
									ListTile(title: Text("WRITE: ${(char.properties.write) ? "TRUE": "False"}")),
									ElevatedButton(
										child: Text("Increment"),
										onPressed: () async {
											int sendVal = result.last + 1;
											print(sendVal);
											await char.write([sendVal]);
											setState(() async {resultStr = await readStr(char);});
										},
									)
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
					ElevatedButton(
						child: Text("trial"),
						onPressed: () => print(scanResult.advertisementData),
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