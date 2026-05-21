import json

file_path = r'lib/l10n/app_tr.arb'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

print("--- Searching for 'sıvı' (case-insensitive) ---")
count = 0
for key, value in data.items():
    if key.startswith('@'):
        continue
    if 'sıvı' in value.lower() or 'sivi' in value.lower():
        print(f"Key: {key} -> {value}")
        count += 1
print(f"Total 'sıvı' found: {count}\n")

print("--- Searching for any word containing 'v' in Turkish values ---")
count = 0
for key, value in data.items():
    if key.startswith('@'):
        continue
    if 'v' in value.lower():
        # Check if it has 'ı' or 'i' near 'v'
        if any(c in value.lower() for c in ['vi', 'vı', 'ıv', 'iv']):
            print(f"Key: {key} -> {value}")
            count += 1
print(f"Total matches found: {count}\n")
