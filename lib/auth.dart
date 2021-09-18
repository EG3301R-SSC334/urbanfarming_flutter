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

class Auth {
	// Make this a singleton class
	static final Auth _instance = Auth._init();

	factory Auth() {
		print("calling instance of Auth");
		return _instance;
	}

	// Continue with the class itself
	GoogleSignIn _googleSignIn = GoogleSignIn(
		clientId: "",
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
				loggedIn = _prefs?.getBool("logged_in") ?? false;
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

			_cbs.forEach((element) {
				element();
			});
		});

		_googleSignIn.signInSilently();
		// print("_currentUser $_currentUser");

		print("Auth init complete");
	}

	Future<void> signIn() async {
		try {
			await _googleSignIn.signIn();
		} catch (error) {
			print(error);
		}
	}

	void addCB(Function cb) {
		_cbs.add(cb);
	}

	void removeCB(Function cb) {
		_cbs.remove(cb);
	}

	void signInSync() {
		try {
			_googleSignIn.signIn().then((_) {});
		} catch (error) {
			print("ERROR EXPERIENCED: $error");
		}
	}

	void signOut() {
		_googleSignIn.disconnect();
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

}