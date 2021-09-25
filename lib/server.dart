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

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'graphs.dart';

class Plant {
	final int? id;
	final String type;
	final int humidity;
	final int temperature;
	final int ph;
	final int ec;

	Plant({this.id, required this.type, required this.humidity, required this.temperature, required this.ph, required this.ec});
}

class System {
	final String name;
	final String owner;
	final String plantType;
	List<DataPoint> humidity = [];
	List<DataPoint> temperature = [];
	List<DataPoint> ph = [];
	List<DataPoint> ec = [];

	System({required this.name, required this.owner, required this.plantType});
}

class Server {
	final _host = 'urban-farming-demo.herokuapp.com';
	// final _port = '3000';
	String? userID;

	Server({this.userID});

	List<Function> _cbs = [];
	List<Function> _systemCBs = [];

	Uri _buildUri(String path) => Uri.parse('http://$_host/$path');

	void addCB(Function cb) {
		_cbs.add(cb);
	}

	void addSystemCB(Function cb) {
		_systemCBs.add(cb);
	}

	Future<dynamic> _get(String path) async {
		Uri uri = _buildUri("${this.userID}/$path");
		var response = await http.get(uri);

		if (response.statusCode == 200)
			return jsonDecode(response.body);
	}

	Future<dynamic> _post(String path, {Map<String, String>? data}) async {
		Uri uri = _buildUri(path);
		String jsone = json.encode(data ?? "");

		print("REQ BODY: $jsone");
		print("REQ BODY LEN: ${jsone.length}");

		var response = await http.post(
			uri, 
			body: json.encode(data ?? ""),
			headers: {
				"Content-Type": "application/json"
			},
		);

		print("STATUS CODE: ${response.statusCode}");
		print("RESPONSE BODY: ${response.body}");

		if (response.statusCode == 200) {
			return jsonDecode(response.body);
		} else {
			throw Exception("Invalid post");
		}
	}

	Future<Map<String, String>> auth(Map<String, String> data) async {
		try {
			dynamic respJSON = await _post(
				"auth/google", 
				// "users",
				data: data
			);
			print(respJSON);
			return respJSON;
		} catch (Exception) {
			print("Failed to auth");
			return {};
		}
	}

	void _callCB(dynamic retVal) {
		_cbs.forEach((cb) {
			cb(retVal);
		});
	}

	void _callSystemCB(dynamic retVal) {
		_systemCBs.forEach((cb) {
			cb(retVal);
		});
	}

	Future<System> getSystem() async {
		dynamic respJson = await _get("/systems/");
		System retSystem = System(
			name: respJson["systemName"],
			owner: respJson["ownerID"],
			plantType: respJson["plantType"],
		);

		respJson["humidity"].forEach((item) {
			retSystem.humidity.add(DataPoint(item["value"], item["time"]));
		});

		respJson["temperature"].forEach((item) {
			retSystem.temperature.add(DataPoint(item["value"], item["time"]));
		});

		respJson["ph"].forEach((item) {
			retSystem.ph.add(DataPoint(item["value"], item["time"]));
		});

		respJson["ec"].forEach((item) {
			retSystem.ec.add(DataPoint(item["value"], item["time"]));
		});

		_callSystemCB(retSystem);

		return retSystem;
	}

	Future<List<Plant>> getPlants() async {
		dynamic respJson = await _get("");
		List<Plant> retList = [];

		if (respJson == null)
			return retList;

		respJson["plants"].forEach((plant) {
			retList.add(Plant(
				id: plant["plantID"],
				type: plant["plantType"],
				humidity: plant["humidity"],
				temperature: plant["temperature"],
				ph: plant["pH"],
				ec: plant["E"]
			));
		});

		_callCB(retList);
		return retList;
	}

	Future<Plant?> getPlant(int id) async {
		dynamic respJson = await _get(id.toString());

		if (respJson == null)
			return null;
		else
			return Plant(
				id: respJson["plant"]["plantID"],
				type: respJson["plant"]["plantType"],
				humidity: respJson["plant"]["humidity"],
				temperature: respJson["plant"]["temperature"],
				ph: respJson["plant"]["pH"],
				ec: respJson["plant"]["E"]
			);
	}

	Future<String> update() async {
		Uri uri = _buildUri("plants");
		var response = await http.get(uri);
		print(response.statusCode);
		if (response.statusCode == 200) {
			print(200);
			print(response.body);

			List<Plant> cbRet = [];
			var responseJson = jsonDecode(response.body);
			// responseJson["plants"].forEach((plant) {
			responseJson.forEach((plant) {
				Plant newPlant = Plant(
					// id: plant["id"],
					type: plant["plantType"],
					humidity: plant["humidity"],
					temperature: plant["temperature"],
					ph: plant["pH"],
					ec: plant["EC"]
				);

				cbRet.add(newPlant);
			});

			_cbs.forEach((cb) {
				// cb(response.body);
				cb(cbRet);
			});

			return response.body;
		} else {
			return "Request Failed";
		}
	}
}