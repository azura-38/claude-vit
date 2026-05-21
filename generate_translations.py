import json
import os
import re

def generate():
    l10n_dir = r'lib/l10n'
    output_file = r'lib/core/l10n/translations.dart'
    
    if not os.path.exists(l10n_dir):
        print(f"Error: Directory {l10n_dir} not found.")
        return

    # Find all arb files
    arb_files = [f for f in os.listdir(l10n_dir) if f.startswith('app_') and f.endswith('.arb')]
    
    data_map = {}
    
    # Process each arb file
    for filename in sorted(arb_files):
        # Extract locale code, e.g. app_en.arb -> en
        match = re.match(r'app_([a-z]{2})\.arb', filename)
        if not match:
            continue
        locale = match.group(1)
        
        file_path = os.path.join(l10n_dir, filename)
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = json.load(f)
            
            locale_map = {}
            # Keep only the translation keys, ignore keys starting with '@' or '@@'
            for key, value in content.items():
                if not key.startswith('@'):
                    locale_map[key] = value
            
            # Sort keys for consistent generation
            sorted_locale_map = {k: locale_map[k] for k in sorted(locale_map.keys())}
            data_map[locale] = sorted_locale_map
            print(f"Processed locale '{locale}' with {len(sorted_locale_map)} keys.")
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
            return

    # Format the Dart code
    lines = [
        "// Generated from lib/l10n/app_*.arb for runtime key lookup.",
        "// Keep source text in ARB files; regenerate this map when adding dynamic keys.",
        "class Translations {",
        "  Translations._();",
        "",
        "  static const Map<String, Map<String, String>> data = {"
    ]
    
    for locale in sorted(data_map.keys()):
        lines.append(f"    '{locale}': {{")
        for key, value in data_map[locale].items():
            # Escape single quotes and backslashes for safe Dart insertion
            escaped_val = value.replace('\\', '\\\\').replace("'", "\\'")
            # Replace newlines in values
            escaped_val = escaped_val.replace('\n', '\\n')
            lines.append(f"      '{key}': '{escaped_val}',")
        lines.append("    },")
        
    lines.extend([
        "  };",
        "}",
        ""
    ])
    
    # Ensure the parent directory exists
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
        
    print(f"Successfully generated {output_file}")

if __name__ == '__main__':
    generate()
