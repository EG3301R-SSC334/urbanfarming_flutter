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

import 'system_page.dart';

import 'graphs.dart';
import 'local_files.dart';
import 'auth.dart';

class Plant {
	final int? id;
	final String type;
	final int humidity;
	final int temperature;
	final int ph;
	final int ec;

	Plant({this.id, required this.type, required this.humidity, required this.temperature, required this.ph, required this.ec});
}

class Server {
	LocalFiles files = LocalFiles();
	Auth _auth = Auth();
	final _host = 'urban-farming-demo.herokuapp.com';
	// final _port = '3000';
	String? userID;
	List<System> systems = [];

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

	Future<dynamic> _get(String path, {Map<String, String>? header}) async {
		Uri uri = _buildUri(path);
		var response = await http.get(
			uri, 
			headers: header ?? {},
		);

		print("GET");
		print("URL: ${response.request?.url}");
		print("HEADERS: ${response.request?.headers}");
		print("STATUS CODE: ${response.statusCode}");
		print("RESPONSE BODY: ${response.body}");

		if (response.statusCode == 200)
			return jsonDecode(response.body);
	}

	Future<dynamic> _post(String path, {Map<String, String>? data, Map<String, String>? header}) async {
		Uri uri = _buildUri(path);
		String jsone = json.encode(data ?? "");

		print("REQ BODY: $jsone");
		print("REQ BODY LEN: ${jsone.length}");

		var response = await http.post(
			uri, 
			body: json.encode(data ?? ""),
			headers: header ?? {
				"Content-Type": "application/json"
			},
		);

		print("POST");
		print("STATUS CODE: ${response.statusCode}");
		print("RESPONSE BODY: ${response.body}");

		if (response.statusCode == 200) {
			return jsonDecode(response.body);
		} else {
			throw Exception("Invalid post");
		}
	}

	Future<dynamic> _delete(String path, {Map<String, String>? header}) async {
		Uri uri = _buildUri(path);
		var response = await http.delete(
			uri,
			headers: header ?? {}
		);

		print("DELETE");
		print("URL: ${response.request?.url}");
		print("HEADERS: ${response.request?.headers}");
		print("STATUS CODE: ${response.statusCode}");
		print("RESPONSE BODY: ${response.body}");
	}

	Future<dynamic> _put(String path, {Map<String, String>? data, Map<String, String>? header}) async {
		Uri uri = _buildUri(path);
		var response = await http.put(
			uri,
			body: json.encode(data ?? ""),
			headers: header ?? {}
		);

		print("PUT");
		print("URL: ${response.request?.url}");
		print("HEADERS: ${response.request?.headers}");
		print("STATUS CODE: ${response.statusCode}");
		print("RESPONSE BODY: ${response.body}");
	}

	Future<Map<String, dynamic>> auth(Map<String, String> data) async {
		try {
			dynamic respJSON = await _post(
				"auth/google", 
				// "users",
				data: data
			);
			print(respJSON);
			return respJSON;
		} catch (e) {
			print("Failed to auth");
			print(e);
			return {};
		}
	}

	void _callCB(dynamic retVal) {
		_cbs.forEach((cb) {
			cb(retVal);
		});
	}

	// ---------------------------


	void _callSystemCB(dynamic retVal) {
		_systemCBs.forEach((cb) {
			cb(retVal);
		});
	}

	Future<void> trial() async {
		List<String> info = _auth.getBearer();
		// dynamic respJson = await _get("users/61509348365d140004d42cde", 
		dynamic respJson = await _get(
			"users/${info[1]}", 
			header: {
				"Authorization": 'Bearer ${info[0]}',
				"Content-Type": "application/json"
			}
		);

		print(respJson);
	}

	Future<void> connectSystem() async {
		List<String> info = _auth.getBearer();
		var respJson = await _put(
			"users/${info[1]}",
			header: {
				"Authorization": 'Bearer ${info[0]}',
				"Content-Type": "application/json"
			},
			data: {
				"systems": "6150a4f0447e2a0004adc583"
			},
		);

		print(respJson);
	}

	Future<List<System>> getSystems() async {
		List<System> retList = [];
		dynamic respJson = await _get("/systems");
		respJson["system_ids"].forEach((sys_id) async {
			retList.add(await getSystem(sys_id));
		});

		systems = retList;
		await files.writeJson(LocalFiles.systemsFile, {"systems": retList});
		return retList;
	}

	Future<System> getSystem(String sysId) async {
		Map<String, dynamic> respJson = await _get("systems/$sysId");
		System retSystem = System(
			name: respJson["systemName"],
			owner: respJson["ownerID"],
			plantType: respJson["plantType"],
		);

		respJson["humidity"].forEach((item) {
			retSystem.humidity.add(DataPoint(double.parse(item["value"]), item["time"]));
		});

		respJson["temperature"].forEach((item) {
			retSystem.temperature.add(DataPoint(double.parse(item["value"]), item["time"]));
		});

		respJson["pH"].forEach((item) {
			retSystem.ph.add(DataPoint(double.parse(item["value"]), item["time"]));
		});

		respJson["EC"]?.forEach((item) {
			retSystem.ec.add(DataPoint(double.parse(item["value"]), item["time"]));
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