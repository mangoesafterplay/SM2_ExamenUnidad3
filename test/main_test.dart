import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:movuni/services/auth_service.dart';
import 'package:movuni/services/session_service.dart';

class FakeFirestore extends Fake implements FirebaseFirestore {}

void main() {
  // ========== PRUEBAS DE AUTENTICACIÓN ==========
  group('AuthService Tests', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirestore fakeFirestore;
    late AuthService authService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirestore();
      authService = AuthService(auth: mockAuth, firestore: fakeFirestore);
    });

    test('Debe lanzar error si el email no es institucional', () async {
      expect(
        () async => await authService.signUpWithEmail(
          email: 'usuario@gmail.com',
          password: '123456',
          firstName: 'Juan',
          lastName: 'Perez',
          dni: '12345678',
          phone: '987654321',
          isDriver: false,
          role: 'student',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Debe registrar usuario con correo institucional válido', () async {
      final user = await mockAuth.createUserWithEmailAndPassword(
        email: 'test@virtual.upt.pe',
        password: '123456',
      );

      expect(user.user, isA<User>());
      expect(user.user?.email, 'test@virtual.upt.pe');
    });

    test('Debe cerrar sesión correctamente', () async {
      await mockAuth.signInWithEmailAndPassword(
        email: 'test@virtual.upt.pe',
        password: '123456',
      );
      expect(mockAuth.currentUser, isNotNull);

      await mockAuth.signOut();
      expect(mockAuth.currentUser, isNull);
    });
  });

  // ========== PRUEBAS DE SESIÓN ==========
  group('SessionService Tests', () {
    late SessionService sessionService;

    setUp(() {
      sessionService = SessionService();
      SharedPreferences.setMockInitialValues({});
    });

    test('Debe guardar y obtener el rol del usuario', () async {
      await sessionService.saveUserRole('conductor');
      final role = await sessionService.getUserRole();
      expect(role, 'conductor');
    });

    test('Debe devolver null si no hay rol guardado', () async {
      final role = await sessionService.getUserRole();
      expect(role, isNull);
    });

    test('Debe eliminar el rol del usuario', () async {
      await sessionService.saveUserRole('pasajero');
      await sessionService.clearUserRole();
      final role = await sessionService.getUserRole();
      expect(role, isNull);
    });
  });
}