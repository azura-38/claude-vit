# VitaCase — Localization & Multi-Language Support Guide (l10n)

This document provides a comprehensive guide on how the multi-language localization system works in VitaCase, how to maintain it, and how to add new languages or translations.

---

## 📖 Architecture Overview

VitaCase uses a **dual-system hybrid localization** approach to achieve both compile-time safety and dynamic, flexible runtime lookups:

1. **Flutter ARB (gen-l10n)**:
   - Location: `lib/l10n/`
   - Files: `app_*.arb`
   - Purpose: Standard Flutter localization system. Generates compile-time safe, typed extension properties under `context.l10n.propertyName`.
   
2. **Dynamic Runtime Map (`translations.dart`)**:
   - Location: `lib/core/l10n/translations.dart`
   - Purpose: Direct map lookup (`context.tr('key')`) which allows fetching translations dynamically using string variables (essential for achievements, notifications, and dynamic widgets).

3. **Fallback Extension (`l10n_extension.dart`)**:
   - Provides smooth, multi-level fallbacks if a key is missing:
     `ARB File` ➔ `translations.dart Map` ➔ `Dynamic Fallbacks` ➔ `Humanized String`

---

## 🛠️ Configuration & Core Files

### 1. `l10n.yaml`
Located in the project root, configuring Flutter's localization tool:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### 2. `lib/shared/providers/locale_provider.dart`
Controls the current active language. Defines all 10 supported languages with their **native name and flag emoji**:
- 🇹🇷 Türkçe (`tr`)
- 🇬🇧 English (`en`)
- 🇩🇪 Deutsch (`de`)
- 🇪🇸 Español (`es`)
- 🇫🇷 Français (`fr`)
- 🇮🇹 Italiano (`it`)
- 🇵🇹 Português (`pt`)
- 🇮🇳 हिन्दी (`hi`)
- 🇯🇵 日本語 (`ja`)
- 🇨🇳 中文 (`zh`)

---

## 🚀 How to Add or Modify Translation Keys

To add or modify translation keys, always follow this workflow:

### Step 1: Add the keys to `app_en.arb` & `app_tr.arb`
Always add the new translation key to the two primary developer files first:
- `lib/l10n/app_en.arb` (English Template)
- `lib/l10n/app_tr.arb` (Turkish Translation)

Ensure that any placeholders are properly specified using curly braces (e.g. `{days}` or `{limit}`).

### Step 2: Auto-Translate to Other Languages
Run the automated translation pipeline to translate the missing keys to the other 8 languages:
```bash
python translate_arbs.py
```
This script will:
1. Load `app_en.arb` as the absolute source of truth.
2. Prune any obsolete or legacy keys in the other files.
3. Automatically translate all missing keys in batches using Google Translate (safeguarding placeholders like `{days}` so they are not corrupted).
4. Auto-run `fix_all_arb.py` to synchronize `@key` metadata across all ARB files.
5. Auto-run `generate_translations.py` to compile all ARB files into `lib/core/l10n/translations.dart`.

### Step 3: Compile Flutter Localizations
Regenerate Flutter's typed localizations classes:
```bash
flutter gen-l10n
```

### Step 4: Run Code Analysis
Verify that all localized properties compile successfully and no lint warnings exist:
```bash
flutter analyze
```

---

## ⚠️ Important Rules & Best Practices

> [!IMPORTANT]
> **Placeholder Safety**:
> When writing translations with variables, always use correct curly brackets (e.g. `You have {count} slots left`). 
> Our automated translator protects these using bracket tokens (`[[VAR_0]]`), but always manually verify that the variables inside translations are correct.

> [!WARNING]
> **No Direct Edits to translations.dart**:
> Never edit `lib/core/l10n/translations.dart` manually. It is a generated file. Any manual changes will be overwritten the next time the localization script is run. Always update the source ARB files instead.

> [!TIP]
> **Adding a New Language**:
> To support an entirely new language (e.g. Russian `ru`):
> 1. Add `SupportedLanguage('ru', '🇷🇺 Русский')` to `lib/shared/providers/locale_provider.dart`.
> 2. Add `'ru': 'ru'` mapping to `LANG_MAP` inside `translate_arbs.py`.
> 3. Run `python translate_arbs.py` to auto-create and populate `app_ru.arb`.
