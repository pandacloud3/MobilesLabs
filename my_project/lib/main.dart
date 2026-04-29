import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_project/firebase_options.dart';
import 'package:my_project/data/api_service.dart';
import 'package:my_project/data/local_user_repository.dart';
import 'package:my_project/cubits/bin_cubit.dart';
import 'package:my_project/cubits/history_bloc.dart';
import 'package:my_project/cubits/profile_cubit.dart';
import 'package:my_project/screens/home_screen.dart';
import 'package:my_project/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  final apiService = ApiService();
  final localUserRepository = LocalUserRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: localUserRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BinCubit>(create: (context) => BinCubit()),
          BlocProvider<ProfileCubit>(
            create: (context) =>
                ProfileCubit(context.read<LocalUserRepository>()),
          ),
          BlocProvider<HistoryBloc>(
            create: (context) =>
                HistoryBloc(context.read<ApiService>())
                  ..add(FetchHistoryEvent()),
          ),
        ],
        child: SmartBinApp(isLoggedIn: isLoggedIn),
      ),
    ),
  );
}

class SmartBinApp extends StatelessWidget {
  final bool isLoggedIn;

  const SmartBinApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Trash Can',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
