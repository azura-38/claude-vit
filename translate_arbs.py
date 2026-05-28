import os
import json
import re
import time
from deep_translator import GoogleTranslator

# Target directory
L10N_DIR = r'lib/l10n'
EN_PATH = os.path.join(L10N_DIR, 'app_en.arb')

# Language mapping: project code -> google translator code
# Note: de and es are already fully translated and will skip instantly!
LANG_MAP = {
    'de': 'de',
    'es': 'es',
    'fr': 'fr',
    'it': 'it',
    'pt': 'pt',
    'hi': 'hi',
    'ja': 'ja',
    'zh': 'zh-CN'
}

def load_arb(path):
    if not os.path.exists(path):
        return {}
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_arb(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def protect_placeholders(text):
    placeholders = re.findall(r'\{[^{}]+\}', text)
    protected_text = text
    tokens = []
    for i, p in enumerate(placeholders):
        token = f"[[VAR_{i}]]"
        tokens.append((token, p))
        protected_text = protected_text.replace(p, token)
    return protected_text, tokens

def restore_placeholders(text, tokens):
    restored = text
    for token, p in tokens:
        restored = restored.replace(token, p)
        token_clean = token.replace("[", "").replace("]", "")
        restored = re.sub(r'\[\s*\[\s*VAR_' + str(token_clean.split('_')[1]) + r'\s*\]\s*\]', p, restored, flags=re.IGNORECASE)
    return restored

def main():
    print("Loading template English ARB...", flush=True)
    en_data = load_arb(EN_PATH)
    en_keys = {k: v for k, v in en_data.items() if not k.startswith('@') and not k.startswith('@@')}
    print(f"Loaded {len(en_keys)} English keys to translate.\n", flush=True)

    for lang, translator_lang in LANG_MAP.items():
        print(f"==========================================", flush=True)
        print(f"Processing language: {lang} (Google Translate: {translator_lang})", flush=True)
        target_path = os.path.join(L10N_DIR, f'app_{lang}.arb')
        
        target_data = load_arb(target_path)
        existing_keys = {k: v for k, v in target_data.items() if not k.startswith('@') and not k.startswith('@@')}
        
        # PRUNING: Only keep existing keys if they also exist in English
        pruned_existing_keys = {k: v for k, v in existing_keys.items() if k in en_keys}
        deleted_count = len(existing_keys) - len(pruned_existing_keys)
        if deleted_count > 0:
            print(f"Pruned {deleted_count} obsolete/legacy keys from existing app_{lang}.arb.", flush=True)
            
        print(f"Valid existing translations: {len(pruned_existing_keys)} keys.", flush=True)
        
        # Find missing keys
        missing_keys = [k for k in en_keys.keys() if k not in pruned_existing_keys]
        print(f"Missing keys to translate: {len(missing_keys)} keys.", flush=True)
        
        if not missing_keys:
            # If no missing keys and prune changes exist, save them
            if deleted_count > 0:
                new_target_data = {"@@locale": lang}
                for k, v in pruned_existing_keys.items():
                    new_target_data[k] = v
                save_arb(target_path, new_target_data)
                print(f"Saved pruned app_{lang}.arb file.", flush=True)
            print(f"Language {lang} is already fully translated!", flush=True)
            continue

        # Prepare batch translation
        texts_to_translate = []
        metadata_map = {} # maps text index to (key, tokens)
        
        for k in missing_keys:
            orig_text = en_keys[k]
            protected_text, tokens = protect_placeholders(orig_text)
            idx = len(texts_to_translate)
            texts_to_translate.append(protected_text)
            metadata_map[idx] = (k, tokens)

        # Batch translation (size 50)
        translated_results = []
        batch_size = 50
        translator = GoogleTranslator(source='en', target=translator_lang)
        
        print(f"Translating in batches of {batch_size}...", flush=True)
        for i in range(0, len(texts_to_translate), batch_size):
            batch = texts_to_translate[i:i+batch_size]
            print(f"  Translating batch {i//batch_size + 1}/{(len(texts_to_translate)-1)//batch_size + 1} ({len(batch)} items)...", flush=True)
            
            # Retry loop for batch translation (up to 3 retries with 60s sleep on rate limits)
            max_retries = 3
            success = False
            for retry in range(max_retries):
                try:
                    translations = translator.translate_batch(batch)
                    translated_results.extend(translations)
                    success = True
                    # Adaptive sleep: be gentle to avoid rate-limiting
                    time.sleep(1.5)
                    break
                except Exception as e:
                    print(f"  [Rate Limit Warning] Batch {i//batch_size + 1} failed on try {retry + 1}/{max_retries}. Error: {e}", flush=True)
                    if retry < max_retries - 1:
                        print("  [Rate Limit Cooldown] Pausing for 60 seconds before retrying to let rate-limit cool down...", flush=True)
                        time.sleep(60)
                    else:
                        print("  [Rate Limit Exhausted] Moving to fallback individual translations...", flush=True)
            
            # Fallback to individual translations only if the batch repeatedly failed
            if not success:
                print("  Executing fallback individual translation...", flush=True)
                for text in batch:
                    item_success = False
                    for item_retry in range(2):
                        try:
                            res = translator.translate(text)
                            translated_results.append(res)
                            item_success = True
                            time.sleep(0.5)
                            break
                        except Exception as ex:
                            print(f"    [Rate Limit Warning] Failed individual translation on try {item_retry + 1}. Error: {ex}", flush=True)
                            time.sleep(10) # Cooldown
                    
                    if not item_success:
                        print(f"    [Fallback Warning] Could not translate '{text}'. Writing original text.", flush=True)
                        translated_results.append(text) # Fallback to original text

        # Reconstruct target dict
        new_target_data = {"@@locale": lang}
        
        # 1. Keep pruned existing keys first (preserving their translations)
        for k, v in pruned_existing_keys.items():
            new_target_data[k] = v
            
        # 2. Add newly translated keys
        for idx, translated_text in enumerate(translated_results):
            k, tokens = metadata_map[idx]
            restored_text = restore_placeholders(translated_text, tokens)
            new_target_data[k] = restored_text

        # Save to file
        save_arb(target_path, new_target_data)
        print(f"Successfully updated app_{lang}.arb to {len(new_target_data) - 1} keys.", flush=True)
        
    print("\nRunning fix_all_arb.py to sync metadata...", flush=True)
    os.system("python fix_all_arb.py")
    
    print("Running generate_translations.py to update Dart translation map...", flush=True)
    os.system("python generate_translations.py")
    
    print("All tasks completed successfully!", flush=True)

if __name__ == '__main__':
    main()
