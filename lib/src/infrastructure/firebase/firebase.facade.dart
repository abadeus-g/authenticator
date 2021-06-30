import 'package:dartz/dartz.dart';
import 'package:frozenmobs/frozenmobs.dart';

import 'firebase.authentor.dart';

/// {@template firebaseAuthFacade}
/// Repository which manages user authentication backed by Firebase.
/// {@endtemplate}
class FirebaseAuthFacade {

  ///{@macro firebaseAuthFacade}
  FirebaseAuthFacade({
    FirebaseAuthenticator? authenticator,
  }) : _authenticator = authenticator ?? FirebaseAuthenticator();

  final FirebaseAuthenticator _authenticator;

  /// Returns a stream of fired user.
  /// Defaults to [UserInterface.unknown] if there is no cached user.
  Stream<UserInterface> get user => _authenticator.userInterface;

  /// Return an Option of whether the current user is null or not
  Future<Option<UserInterface>> userAuthOption() =>
      _authenticator.authenticatedUserInterface();

  /// Returns the current user saved in cache.
  /// Defaults to [UserInterface.unknown] if there is no cached user.
  UserInterface get userFromCache => _authenticator.cachedUserInterface;

  /// Register a new user in firebase using the provided mail credentials
  Future<Either<Authfailure, Unit>> signUpWithEmailCredentials(
          {required EmailAddress emailAddress, required Password password}) =>
      _authenticator.registerWithEmailAndPassword(
          emailAddress: emailAddress, password: password);

  /// Login an existing user through the provided credentials
  Future<Either<Authfailure, Unit>> signInWithEmailCredentials(
          {required EmailAddress emailAddress, required Password password}) =>
      _authenticator.signInWithEmailAndPassword(
          emailAddress: emailAddress, password: password);

  /// Login/Register the user through the google process
  Future<Either<Authfailure, Unit>> signWithGoogle() =>
      _authenticator.signInWithGoogle();

  /// Disconnect the user from firebase database
  Future<void> signOut() => _authenticator.signOut();
}
