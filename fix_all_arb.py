
import json
import re
import os

def fix_file(target_path, source_path=None):
    if not os.path.exists(target_path):
        print(f"File not found: {target_path}")
        return

    with open(target_path, 'r', encoding='utf-8') as f:
        target_data = json.load(f)

    source_data = {}
    if source_path and os.path.exists(source_path):
        with open(source_path, 'r', encoding='utf-8') as f:
            source_data = json.load(f)

    new_data = {}
    # Keep @@locale at top
    if '@@locale' in target_data:
        new_data['@@locale'] = target_data['@@locale']

    for key, value in target_data.items():
        if key.startswith('@'):
            continue
        
        new_data[key] = value
        
        # Find placeholders in target string
        placeholders_found = re.findall(r'\{(\w+)\}', value)
        
        meta_key = '@' + key
        existing_meta = target_data.get(meta_key, {})
        
        # Look in source for official placeholders/types if source is different
        source_placeholders = {}
        if source_path:
            source_meta = source_data.get(meta_key, {})
            source_placeholders = source_meta.get('placeholders', {})
        else:
            # If no source, use existing placeholders if they exist
            source_placeholders = existing_meta.get('placeholders', {})

        placeholders_to_define = {}
        for p in placeholders_found:
            if p in source_placeholders:
                placeholders_to_define[p] = source_placeholders[p]
            else:
                # Default to String if unknown
                placeholders_to_define[p] = {"type": "String"}
        
        new_meta = existing_meta.copy()
        if placeholders_to_define:
            new_meta['placeholders'] = placeholders_to_define
        
        if 'description' not in new_meta:
            new_meta['description'] = f"Translation for {key}"
            
        new_data[meta_key] = new_meta

    # Write back
    with open(target_path, 'w', encoding='utf-8') as f:
        json.dump(new_data, f, ensure_ascii=False, indent=2)
    print(f"Updated {target_path}")

l10n_dir = r'c:\Users\olum3\OneDrive\Masaüstü\vit-case\lib\l10n'
en_path = os.path.join(l10n_dir, 'app_en.arb')

# Get all ARB files
arb_files = [f for f in os.listdir(l10n_dir) if f.endswith('.arb')]

# Fix EN first to use it as source
fix_file(en_path)

# Fix others using EN as source
for f in arb_files:
    if f == 'app_en.arb':
        continue
    target_path = os.path.join(l10n_dir, f)
    fix_file(target_path, en_path)
