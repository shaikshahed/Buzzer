// import 'package:engro/feature/auth/login/repository/auth_repository.dart';
// import 'package:engro/feature/auth/login/repository/response_model.dart';
// import 'package:persistent_storage/persistent_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:test/test.dart';

// void main() {
//   final auth = AuthRepository(persistentStorage: PersistentStorage(sharedPreferences: SharedPreferences.getInstance());
//   group("test login 1", () {
//     test('pure creates correct instance', () async {
//       // final email = await auth.signIn(
//       //     email: "anand@mailinator.com", password: "12345678");

//       await expectLater(
//           () async => await auth.signIn(
//               email: "anand1@mailinator.com", password: "12345678"),
//           throwsException);
//     });
//     test('pure creates correct instance 234', () async {
//       await expectLater(
//           () async => await auth.signIn(
//               email: "anand1@mailinator.com", password: "12345678"),
//           throwsA(isA<Exception>()));
//     });

//     test('signin with corret email and password', () async {
//       await expectLater(
//           () =>
//               auth.signIn(email: "anand@mailinator.com", password: "12345678"),
//           isA<Future<LoginResponse>>());
//     });
//   });
//   // test("getNews SHOULD throw an exception WHEN api fails", () async {
//   //   final Exception exception = Exception();
//   //   when(() => auth.signIn(email: "anand@mailinator.com", password: "12345678"))
//   //       .thenAnswer((realInvocation) => Future<LoginResponse>.error(exception));

//   //   expect(() => sut.getNews(), throwsA(exception));
//   // });
// }
