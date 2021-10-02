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

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart';
import 'graphs.dart';

typedef ServerCB = Function(dynamic ret);

class System {
	final String? name;
	final String? owner;
	final String plantType;
	List<DataPoint> humidity = [];
	List<DataPoint> temperature = [];
	List<DataPoint> ph = [];
	List<DataPoint> ec = [];

	System({this.name, this.owner, required this.plantType});

	factory System.fromServer(Map<String, dynamic> systemJson) {
		System retSystem = System(
			name: systemJson["systemName"],
			owner: systemJson["ownerID"],
			plantType: systemJson["plantType"] 
		);

		systemJson["humidity"].forEach((item) {
			retSystem.humidity.add(DataPoint(double.parse(item["value"]), item["time"]));
		});

		systemJson["temperature"].forEach((item) {
			retSystem.temperature.add(DataPoint(double.parse(item["value"]), item["time"]));
		});

		systemJson["pH"].forEach((item) {
			retSystem.ph.add(DataPoint(double.parse(item["value"]), item["time"]));
		});

		systemJson["EC"].forEach((item) {
			retSystem.ec.add(DataPoint(double.parse(item["value"]), item["time"]));
		});

		return retSystem;
	}

}

class User {
	String? username;
	final String email;
	String? photo;
	List<System> systems = [];

	User({required this.email, this.username, this.photo});

	User.fromGoogleAccount(GoogleSignInAccount account):
		email = account.email,
		username = account.displayName,
		photo = account.photoUrl;

	String get photoURL => this.photo ?? "";
	String get name => this.username ?? "";
	String get initials {
		String retStr = "";
		this.name.split(" ").forEach((name) {
			retStr += name[0];
		});
		return retStr;
	}
}

// helper class with constants for http requests
class _Requests {
	static const get = 0x01;
	static const put = 0x02;
	static const post = 0x03;
	static const delete = 0x04;
}

class Server {
	// Make this a singleton class
	static final Server _instance = Server._init();

	factory Server() {
		print("calling instance of Server");
		return _instance;
	}

	Server._init() {
		print("SERVER INIT STARTED");
		SharedPreferences.getInstance().then((prefs) {
			_prefs = prefs;
			bearer = prefs.getString("bearer");
			userID = prefs.getString("user_id");
		});

		// _auth.addCB(authCB);
	}

	// Continue with class

	final String _host = 'urban-farming-demo.herokuapp.com';
	SharedPreferences? _prefs;
	String? bearer;
	String? userID;

	Auth _auth = Auth();
	User? _user;

	bool _verbose = true;

	List<Function> _systemCBs = [];

	void addCB(Function cb) => _systemCBs.add(cb);
	void removeCB(Function cb) => _systemCBs.remove(cb);

	void _callCBs(dynamic retVal) => _systemCBs.forEach((cb) => cb(retVal));

	void authCB(User user) {
		_user = user;
	}

	Uri _buildUri(String path) => Uri.parse('http://$_host/$path');

	Future<http.Response> _get(Uri uri, Map<String, String> headers) async => await http.get(
		uri,
		headers: headers
	);

	Future<http.Response> _put(Uri uri, Map<String, String> headers, String body) => http.put(
		uri,
		headers: headers,
		body: body
	);

	Future<http.Response> _post(Uri uri, Map<String, String> headers, String body) => http.post(
		uri,
		headers: headers,
		body: body
	);

	Future<http.Response> _delete(Uri uri, Map<String, String> headers) async => await http.delete(
		uri,
		headers: headers
	);

	Future<dynamic> _request(int type, String path, {Map<String, String>? headers, Map<String, String>? body}) async {
		Uri uri = _buildUri(path);

		Map<String, String> baseHeaders = {
			"Content-Type": "application/json",
			"Authorization": 'Bearer $bearer'
		};

		Map<String, String> finalHeaders = {}
			..addAll(baseHeaders)
			..addAll(headers ?? {});

		String bodyStr = json.encode(body ?? "");

		http.Response? response;
		
		switch (type) {
			case _Requests.get:		response = await _get(uri, finalHeaders);						break;
			case _Requests.put:		response = await _put(uri, finalHeaders, bodyStr);	break;
			case _Requests.post:		response = await _post(uri, finalHeaders, bodyStr);	break;
			case _Requests.delete:	response = await _delete(uri, finalHeaders);				break;
		}

		if (_verbose) {
			print('URL: ${response!.request?.url}');
			print('HEADERS: ${response.request?.headers}');
			print('STATUS CODE: ${response.statusCode}');
			print('RESPONSE BODY: ${response.body}');
		}

		if (response!.statusCode == 200)
			return jsonDecode(response.body);
	}

	Future<void> auth(Map<String, String> body) async {
		dynamic respJson;
		try {
			respJson = await _request(
				_Requests.post,
				"auth/google",
				body: body
			);
		} catch (e) {
			print("Failed to auth: $e");
		}

		print(respJson);
		if (respJson != null) {
			_prefs?.setString("bearer", respJson["bearerToken"]);
			_prefs?.setString("user_id", respJson["user"]["_id"]);

			bearer = respJson["bearerToken"];
			userID = respJson["user"]["_id"];
		}
	}

	Future<List<System>> getSystems() async {
		List<System> retList = [];
		dynamic respJson = await _request(
			_Requests.get,
			"/systems"
		);

		respJson["system_ids"].forEach((sys_id) async {
			retList.add(await getSystem(sys_id));
		});

		// _callCBs(retList);
		return retList;
	}

	Future<System> getSystem(String sysID) async {
		Map<String, dynamic> respJson = await _request(
			_Requests.get, 
			"systems/$sysID"
		);

		_callCBs(System.fromServer(respJson));
		return System.fromServer(respJson);
	}

}