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

	bool loggedIn = false;

	Auth._init() {
		// Auth() {
			print("AUTH IS BEING INITED NOW");
			SharedPreferences.getInstance().then((prefs) {
				_prefs = prefs;
				try {
					loggedIn = _prefs?.getBool("logged_in") ?? false;
					print("\nLogged In Status: $loggedIn");
				} catch (error) {
					print(error);
					loggedIn = false;
				}
			}
		);

		_googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
			print("sign in happening");
			print("account: $account");
			print("_currentUser: $_currentUser");
			_currentUser = account;
			_prefs?.setBool("logged_in", true);

			print("_currentUser: $_currentUser");

			print("Calling CBs");
			_cbs.forEach((element) {
				element();
			});

			print("Finished signing in");
		});

		_googleSignIn.signInSilently();
		print("_currentUser $_currentUser");
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

	// bool isSignedIn() => (_currentUser != null) ? true : false;
	bool isSignedIn() => loggedIn;

	GoogleSignInAccount? getUser() => _currentUser;

}