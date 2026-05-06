import 'package:hive_flutter/hive_flutter.dart';
import '../models/file_model.dart';

class HiveService {
  static const String filesBoxName = 'files';
  static const String userBoxName = 'user_settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FileVersionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FileCommentAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FileTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ConflictInfoAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(FileModelAdapter());
    }
    
    // Open boxes
    await Hive.openBox<FileModel>(filesBoxName);
    await Hive.openBox(userBoxName);
  }

  static Box<FileModel> get filesBox => Hive.box<FileModel>(filesBoxName);
  static Box get userBox => Hive.box(userBoxName);
}
