import 'package:dartz/dartz.dart';
import 'package:frozenmobs/frozenmobs.dart';

/// {@template IAuthFacade}
/// Repository which manages user authentication.
/// {@endtemplate}
abstract class IAuthFacade {
  ///Register the user through the mail address and password he provided
  Future<Either<Authfailure, Unit>> registerWithEmailAndPassword({
    required EmailAddress emailAddress,
    required Password password,
  });

  ///Log in the user through the mail address and password he provided
  Future<Either<Authfailure, Unit>> signInWithEmailAndPassword({
    required EmailAddress emailAddress,
    required Password password,
  });

  ///Register/Log in user through the google mail address he provided
  Future<Either<Authfailure, Unit>> signInWithGoogle();
  //TODOComing implementation of Github Sign in method
  //Future<Either<Authfailure, Unit>> signInWithGithub();
  //TODOComing implementation of Phone Number Sign in method
  /*Future<Either<Authfailure, Unit>> signInWithPhoneNumber(
      {required String number, required String code});*/
  //TODOTwittter flutter sign in package is still in legacy mofe
  // Future<Either<Authfailure, Unit>> signInWithTwitter();
  ///Signs Out the user from the app
  Future<void> signOut();
}
