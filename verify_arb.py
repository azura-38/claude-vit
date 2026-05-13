
import json
import re
import os

file_path = r'c:\Users\olum3\OneDrive\Masaüstü\vit-case\lib\l10n\app_tr.arb'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

warnings = []
for key, value in data.items():
    if key.startswith('@'):
        continue
    
    placeholders_in_text = re.findall(r'\{(\w+)\}', value)
    if not placeholders_in_text:
        continue
    
    meta_key = '@' + key
    if meta_key not in data:
        warnings.append(f"Missing metadata for key: {key}")
        continue
    
    meta = data[meta_key]
    if 'placeholders' not in meta:
        warnings.append(f"Missing 'placeholders' in metadata for key: {key}")
        continue
    
    defined_placeholders = meta['placeholders'].keys()
    for p in placeholders_in_text:
        if p not in defined_placeholders:
            warnings.append(f"Placeholder '{p}' not defined in metadata for key: {key}")

if not warnings:
    print("No placeholder issues found in script.")
else:
    for w in warnings:
        print(w)
