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

	Auth._init() {
		print("AUTH INIT STARTED");
		SharedPreferences.getInstance().then((prefs) {
			_prefs = prefs;
			try {
				loggedIn = prefs.getBool("logged_in") ?? false;
				print("\nLogged In Status: $loggedIn");
			} catch (e) {
				print("ERROR\n	shared preferences: $e");
				loggedIn = false;
			}
			authComplete = true;
		});

		_googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
			_currentuser = account;
			_prefs?.setBool("logged_in", true);
			loggedIn = true;
			print("Setting logged_in to true");

			_callCBs(User.fromGoogleAccount(account!));
		});

		_googleSignIn.signInSilently();
		print('_currentUser: $_currentuser');
		print('Auth init complete');
	}
	// continue with class

	Server _server = Server();
	GoogleSignIn _googleSignIn = GoogleSignIn(
		clientId: "46868439888-v405ntt411j634238ih9qptopb9svdjf.apps.googleusercontent.com",
		scopes: [
			'https://www.googleapis.com/auth/userinfo.email'
		]
	);

	GoogleSignInAccount? _currentuser;
	SharedPreferences? _prefs;

	bool authComplete = false;
	bool loggedIn = false;

	List<Function> _cbs = [];



	void addCB(Function cb) => _cbs.add(cb);
	void removeCB(Function cb) => _cbs.remove(cb);

	void _callCBs(dynamic retVal) => _cbs.forEach((cb) => cb(retVal));

	Future<void> signIn() async {
		GoogleSignInAccount? gaccount;
		GoogleSignInAuthentication? gauth;

		try {
			gaccount = await _googleSignIn.signIn();
		} catch (error) {
			print('Error experienced during log ing: $error');
		}

		if (gaccount != null)
			gauth = await gaccount.authentication;
		else {
			print("error in logging in");
			return;
		}

		Map<String, String> body = {
			"username": gaccount.displayName ?? "",
			"email": gaccount.email,
			"id_token": gauth.idToken ?? "",
			"access_token": gauth.accessToken ?? ""
		};

		await _server.auth(body);
	}

	Future<void> signOut() async {
		await _googleSignIn.disconnect();
		_prefs?.setBool("logged_in", false);
	}

	bool isSignedIn() {
		for (int i =  0; i < 20; i++) {
			if (authComplete)
				break;
			Future.delayed(Duration(microseconds: 3));
		}

		return loggedIn;
	}

	User? getUser() {
		if (_currentuser == null)
			return null;
		else
			return User.fromGoogleAccount(_currentuser!);
	}
}