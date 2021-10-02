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

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'server.dart';

class Auth {
	// Make this a singleton class
	static final Auth _instance = Auth._init();

	factory Auth() {
		print("calling instance of Auth");
		return _instance;
	}

	// Continue with the class itself
	GoogleSignIn _googleSignIn = GoogleSignIn(
		clientId: "46868439888-v405ntt411j634238ih9qptopb9svdjf.apps.googleusercontent.com",
		scopes: [
			'https://www.googleapis.com/auth/userinfo.email'
		]
	);

	GoogleSignInAccount? _currentUser;
	SharedPreferences? _prefs;

	List<Function> _cbs = [];

	bool authComplete = false;
	bool loggedIn = false;

	Auth._init() {
		SharedPreferences.getInstance().then((prefs) {
			_prefs = prefs;
			try {
				loggedIn = prefs.getBool("logged_in") ?? false;
				print("\nLogged In Status: $loggedIn");
			} catch (error) {
				print(error);
				loggedIn = false;
			}
			authComplete = true;
		}
		);

		_googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
			_currentUser = account;
			_prefs?.setBool("logged_in", true);
			loggedIn = true;
			print("setting logged in to true");

			_cbs.forEach((cb) {
				cb();
			});
		});

		_googleSignIn.signInSilently();
		print("_currentUser $_currentUser");

		print("Auth init complete");
	}


	void addCB(Function cb) {
		_cbs.add(cb);
	}

	void removeCB(Function cb) {
		_cbs.remove(cb);
	}

	// void signInSync() {
	// 	try {
	// 		_googleSignIn.signIn().then((obj) {
	// 			Server server = Server();
	// 			String? idToken;
	// 			String? accessToken;

	// 			if (obj != null) {
	// 				obj.authentication.then((gauth) async {
	// 					idToken = gauth.idToken;
	// 					accessToken = gauth.accessToken;

	// 					Map<String, String> data = {
	// 						"username": obj.displayName ?? "",
	// 						"email": obj.email,
	// 						"id_token": idToken ?? "",
	// 						"access_token": accessToken ?? ""
	// 					};

	// 					// print("DATA: $data");
						
	// 					Map<String, String> authResp = await server.auth(data);

	// 					_prefs?.setString("bearer", authResp["bearerToken"] ?? "");
	// 					print('BEARER: ${authResp["bearerToken"] ?? "Not yet"}');
	// 				});
	// 			}
	// 		});
	// 	} catch (error) {
	// 		print("ERROR EXPERIENCED: $error");
	// 	}
	// }

	Future<void> signIn() async {
		GoogleSignInAccount? gaccount;
		GoogleSignInAuthentication? gauth;
		Server server = Server();

		try {
			gaccount = await _googleSignIn.signIn();
		} catch (error) {
			print("error experienced in login: $error");
		}

		if (gaccount != null) 
			gauth = await gaccount.authentication;

		Map<String, String> body = {
			"username": gaccount?.displayName ?? "",
			"email": gaccount?.email ?? "",
			"id_token": gauth?.idToken ?? "",
			"access_token": gauth?.accessToken ?? ""
		};

		Map<String, dynamic> authResp = await server.auth(body);
		print("authResp: $authResp");
		_prefs?.setString("bearer", authResp["bearerToken"] ?? "");
		_prefs?.setString("user_id", authResp["user"]["_id"]);
		print('BEARER: ${authResp["bearerToken"]}');
		print('user id: ${authResp["user"]["_id"]}');

	}

	List<String> getBearer() {
		print("bearer new");
		print(_prefs?.getString("bearer") ?? "NO BEARER");
		return [_prefs?.getString("bearer") ?? "", _prefs?.getString("user_id") ?? ""];
	}

	Future<void> signOut() async {
		await _googleSignIn.disconnect();
		_prefs?.setBool("logged_in", false);
	}

	bool isSignedIn() {
		for (int i = 0; i < 20; i++) {
			if (authComplete)
				break;
			Future.delayed(Duration(microseconds: 3));
		}

		print("logged In: $loggedIn");
		return loggedIn;
	}

	GoogleSignInAccount? getUser() => _currentUser;
	String getName() => _currentUser?.displayName ?? "";
	String getEmail() => _currentUser?.email ?? "";
	String getPhoto() => _currentUser?.photoUrl ?? "";

	String getInitials() {
		String retStr = "";
		_currentUser?.displayName?.split(" ").forEach((name) { 
			retStr += name[0];
		});

		return retStr;
	}


}