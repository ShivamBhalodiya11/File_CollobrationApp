import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/auth_service.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/files/screens/home_screen.dart';
import '../features/files/screens/file_upload_screen.dart';
import '../features/files/screens/file_details_screen.dart';
import '../features/shared/screens/shared_files_screen.dart';
import '../features/search/screens/search_screen.dart';
import 'shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/shared',
            name: 'shared',
            builder: (context, state) => const SharedFilesScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/upload',
        name: 'upload',
        builder: (context, state) => const FileUploadScreen(),
      ),
      GoRoute(
        path: '/file/:id',
        name: 'file_details',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FileDetailsScreen(fileId: id);
        },
      ),
    ],
  );
});
