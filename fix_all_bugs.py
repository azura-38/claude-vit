import os
import re
import json

LIB_DIR = r'c:\Users\olum3\OneDrive\Masaüstü\vit-case\lib'
PROJECT_DIR = r'c:\Users\olum3\OneDrive\Masaüstü\vit-case'

def replace_in_file(filepath, old_str, new_str):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    if old_str in content:
        content = content.replace(old_str, new_str)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

def regex_replace_in_file(filepath, pattern, new_str):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(pattern, new_str, content)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

def main():
    # 1. Fix theme_provider.dart
    theme_provider = os.path.join(LIB_DIR, 'core', 'theme', 'theme_provider.dart')
    replace_in_file(theme_provider, "import 'package:shared_preferences/flutter_shared_preferences.dart';", "import 'package:shared_preferences/shared_preferences.dart';")
    
    # Also add themeTypeProvider to theme_provider.dart
    theme_provider_addition = """
final themeTypeProvider = StateProvider<ThemeType>((ref) {
  return ThemeType.system;
});
"""
    with open(theme_provider, 'a', encoding='utf-8') as f:
        f.write(theme_provider_addition)

    # 2. Fix app.dart imports
    app_dart = os.path.join(LIB_DIR, 'app.dart')
    replace_in_file(app_dart, "import 'core/theme/theme_provider.dart';", "import 'core/theme/theme_provider.dart';\nimport 'core/theme/vitacase_theme.dart';")

    # 3. Fix profile_provider.dart
    profile_provider = os.path.join(LIB_DIR, 'features', 'profile', 'presentation', 'providers', 'profile_provider.dart')
    # Move directives up
    with open(profile_provider, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    imports = []
    code = []
    for line in lines:
        if line.startswith('import ') or line.startswith('part '):
            imports.append(line)
        else:
            code.append(line)
    
    with open(profile_provider, 'w', encoding='utf-8') as f:
        f.writelines(imports + code)
        
    replace_in_file(profile_provider, "../data/services/mock_profile_service.dart", "../../data/services/mock_profile_service.dart")

    # 4. Fix app_settings_screen.dart
    app_settings = os.path.join(LIB_DIR, 'features', 'profile', 'presentation', 'screens', 'app_settings_screen.dart')
    replace_in_file(app_settings, "../../../core/di/service_providers.dart", "package:vitacase/core/di/service_providers.dart")

    # 5. Fix theme_selection_screen.dart
    theme_selection = os.path.join(LIB_DIR, 'features', 'profile', 'presentation', 'screens', 'theme_selection_screen.dart')
    replace_in_file(theme_selection, "import 'package:vitacase/core/theme/theme_provider.dart';", "import 'package:vitacase/core/theme/theme_provider.dart';\nimport 'package:vitacase/core/theme/vitacase_theme.dart';")

    # 6. Fix shared/data/models and shared/data/repositories broken relative imports
    # They are pointing to `../../../domain/...`
    # We will replace `../../../domain/` with `package:vitacase/shared/domain/` OR feature domain.
    # We will build an absolute map of all dart files to match imports correctly.

    dart_files_map = {}
    for root, _, files in os.walk(LIB_DIR):
        for file in files:
            if file.endswith('.dart'):
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, LIB_DIR).replace('\\\\', '/')
                dart_files_map[file] = rel_path

    def fix_imports_in_dir(directory):
        if not os.path.exists(directory): return
        for root, _, files in os.walk(directory):
            for file in files:
                if not file.endswith('.dart'): continue
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Find all import '../../../domain/.../xxx.dart'
                matches = re.findall(r"import\s+'\.\.\/\.\.\/\.\.\/domain\/[a-zA-Z0-9_\/]+\/([a-zA-Z0-9_]+\.dart)';", content)
                for filename in matches:
                    if filename in dart_files_map:
                        new_pkg_path = f"package:vitacase/{dart_files_map[filename].replace(os.sep, '/')}"
                        # Replace the old relative import with the new absolute package import
                        content = re.sub(r"import\s+'\.\.\/\.\.\/\.\.\/domain\/[a-zA-Z0-9_\/]+\/" + filename + r"';", f"import '{new_pkg_path}';", content)
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)

    fix_imports_in_dir(os.path.join(LIB_DIR, 'shared', 'data', 'models'))
    fix_imports_in_dir(os.path.join(LIB_DIR, 'shared', 'data', 'repositories'))
    fix_imports_in_dir(os.path.join(PROJECT_DIR, 'test'))

    # 7. Notification service
    notif_service = os.path.join(LIB_DIR, 'services', 'notification_service.dart')
    replace_in_file(notif_service, "await _notificationsPlugin.initialize(initializationSettings);", "await _notificationsPlugin.initialize(initializationSettings);")
    replace_in_file(notif_service, "await _notificationsPlugin.show(0,", "await _notificationsPlugin.show(id: 0,")

    # 8. Profile Create Screen
    profile_create = os.path.join(LIB_DIR, 'features', 'profile', 'presentation', 'screens', 'profile_create_screen.dart')
    replace_in_file(profile_create, "saveProfile(", "saveProfile(userProfile: ")

    print("Import and syntax fixes applied.")

if __name__ == '__main__':
    main()
