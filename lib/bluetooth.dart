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


import 'package:flutter_blue/flutter_blue.dart';


class BT {
	FlutterBlue _blue = FlutterBlue.instance;
	BluetoothDevice? _device;
	List<BluetoothService> _services = [];
	Map<BluetoothService, List<BluetoothCharacteristic>> _characteristics = {};

	List<String> _impServiceIDs = ["feed"];
	List<String> _impCharacteristicIDs = ["fed0"];

	void scan() {
		_blue.startScan(
			timeout: Duration(seconds: 4)
		);

		_blue.scanResults.listen((results) {
			for (ScanResult r in results) {
				print('${r.device.id} found! type: ${r.device.type} rssi: ${r.rssi}');
				if (r.device.id.toString() == "DC:A6:32:EF:29:1C") {
					print("PI 4 FOUND");
				}
			}
		});

		_blue.stopScan();
	}

	Stream<List<ScanResult>> startScan() {
		_blue.startScan(
			timeout: Duration(seconds: 4)
		);

		return _blue.scanResults;
	}

	void stopScan() => _blue.stopScan();

	String _get16bitID(Guid fullID) => fullID.toString().substring(4,8);

	bool _isImpID(Guid fullID, List<dynamic> filter) => filter.contains(_get16bitID(fullID));

	Future<List<BluetoothService>> connect(BluetoothDevice device) async {
		await device.connect();
		_services = await device.discoverServices();

		_characteristics.clear();
		_services.forEach((service) {
			if (_isImpID(service.uuid, _impServiceIDs)) {
				List<BluetoothCharacteristic> characteristics = service.characteristics;
				characteristics.forEach((characteristic) {
					if (_isImpID(characteristic.uuid, _impCharacteristicIDs)) {
						if (!_characteristics.containsKey(service))
							_characteristics[service] = [];
						_characteristics[service]!.add(characteristic);
					}
				});
			}
		});


		_device = device;
		return _services;
	}

	BluetoothDevice? get device => _device;
	// List<BluetoothService> get services => _services;
	Map<BluetoothService, List<BluetoothCharacteristic>> get impCharacteristics => _characteristics;
}