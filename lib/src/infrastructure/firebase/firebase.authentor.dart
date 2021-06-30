import 'package:authenticator/src/core/i.auth.facade.dart';
import 'package:cache/cache.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:frozen_freezed/frozen_freezed.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

/// {@template FirebaseAuthenticator}
/// Repository which manages user authentication backed by Firebase.
/// {@endtemplate}
class FirebaseAuthenticator implements IAuthFacade {
  ///{@macro FirebaseAuthenticator}
  FirebaseAuthenticator(
      {
        CacheClient? cache,
      firebase.FirebaseAuth? fireAuth,
      GoogleSignIn? googleSignIn})
      : _cacheClient = cache ?? CacheClient(),
        _firebaseAuth = fireAuth ?? firebase.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  final firebase.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final CacheClient _cacheClient;

  /// User cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  /// Returns a stream of fired user.
  /// Defaults to [FiredUser.absent] if there is no cached user.
  Stream<FiredUser> get firedUser {
    return _firebaseAuth.authStateChanges().map(
      (user) {
        final fired = user == null ? FiredUser.absent : user.toFiredUser;
        _cacheClient.write(key: userCacheKey, value: fired);
        return fired;
      },
    );
  }

  /// Returns the current cached user.
  /// Defaults to [FiredUser.absent] if there is no cached user.
  FiredUser get currentFiredUser =>
      _cacheClient.read<FiredUser>(key: userCacheKey) ?? FiredUser.absent;

  @override
  Future<Either<Authfailure, Unit>> registerWithEmailAndPassword(
      {required EmailAddress emailAddress, required Password password}) async {
    // TODOimplement registerWithEmailAndPassword
    final emailStr = emailAddress.getOrCrash();
    final passwordStr = password.getOrCrash();
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: emailStr, password: passwordStr);
      return right(unit);
    } on firebase.FirebaseAuthException catch (e) {
      return (e.code == 'email-already-in-use')
          ? left(const Authfailure.emailAlreadyInUse())
          : left(const Authfailure.serverError());
    }
  }

  @override
  Future<Either<Authfailure, Unit>> signInWithEmailAndPassword(
      {required EmailAddress emailAddress, required Password password}) async {
    // TODOimplement signInWithEmailAndPassword
    final emailStr = emailAddress.getOrCrash();
    final passwordStr = password.getOrCrash();
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: emailStr, password: passwordStr);
      return right(unit);
    } on firebase.FirebaseAuthException catch (e) {
      return (e.code == 'wrong-password' || e.code == 'user-not-found')
          ? left(const Authfailure.invalidEmailAndPasswordCombination())
          : left(const Authfailure.serverError());
    }
  }

  @override
  Future<Either<Authfailure, Unit>> signInWithGoogle() async {
    // TODOimplement signInWithGoogle
    try {
      // Trigger the authentication flow
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return left(const Authfailure.cancelledByUser());
      } else {
        // Obtain the auth details from the request
        final googleAuth = await googleUser.authentication;
        //Create a new credentail
        final credential = firebase.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
        await _firebaseAuth.signInWithCredential(credential);
        return right(unit);
      }
    } on firebase.FirebaseAuthException catch (_) {
      return left(const Authfailure.serverError());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
    } on firebase.FirebaseAuthException catch (_) {
      left(const Authfailure.serverError());
    }
  }
}

extension on firebase.User {
  FiredUser get toFiredUser {
    return FiredUser(
      uniqueId: UniqueId.fromUniqueString(uid),
      name: displayName,
      email: email,
      picUrl: photoURL,
      //TODOimplement contact in frozen_freezed package and push it
      //contact: phoneNumber,
    );
  }
}
