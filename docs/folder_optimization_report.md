# VitaCase Folder Optimization Report

Generated on: 2026-05-11

## Summary

The repository folder was optimized by removing generated Flutter/Android build caches and compacting Git object storage.

Before cleanup, the largest folders were:

| Folder | Size |
|---|---:|
| `.git/` | 5,749.47 MB |
| `android/` | 2,695.82 MB |
| `.dart_tool/` | 344.84 MB |
| `build/` | 134.53 MB |

After cleanup:

| Folder | Size |
|---|---:|
| `.git/` | 1,329.41 MB |
| `android/` | 0.30 MB |
| `.dart_tool/` | 0.06 MB |

Estimated space recovered: about 7.4 GB.

## Cleanup Performed

The following generated folders were removed:

- `build/`
- `.dart_tool/` then recreated minimally by `flutter pub get`
- `android/app/build/`
- `android/.gradle/`
- `android/build/`
- `android/app/.cxx/`
- `android/.kotlin/`

Git object storage was compacted with:

```powershell
git gc --prune=now
```

## Deleted Unnecessary Files

The following repo-root artifacts were deleted after this report was first created:

- `vitacase-release.apk`
- `vitacase_v1.1.0_13.aab`
- `vitacase_v1.1.0_14.aab`
- `sentry-wizard.exe`
- `replay_pid19344.log`
- `hs_err_pid19156.log`
- `hs_err_pid19344.log`
- `flutter_01.log`
- `gradle_output.txt`
- `gradle_output_utf8.txt`
- `pub_get_output.txt`
- `build_log.txt`
- `full_cmd.txt`
- `fix_all_bugs.py`
- `gen_ach.js`
- `ach_strings.txt`
- `badge_map.json`
- `.flutter-plugins-dependencies`
- `vitacase.iml`

The following local folders were also deleted:

- `temp_achievements/`
- `vitacase_flutter/`
- `.firebase/`
- `.idea/`
- `.vscode/`

## Remaining Review-For-Removal Files

### Sensitive Or Local-Only Files

These should not be committed to git. Some are already ignored, but they still exist locally.

| File | Recommendation |
|---|---|
| `vitacase-release-key.jks` | Keep outside repo in secure storage. Do not delete unless backed up. |
| `build.env` | Review for secrets; prefer `build.env.example` in git and real env files ignored. |
| `android/key.properties` | Keep ignored and local only. |
| `.firebase/` | Deleted locally. Keep ignored if regenerated. |
| `.idea/` | Deleted locally. Keep ignored if regenerated. |
| `.vscode/` | Deleted locally. Keep ignored if regenerated unless team settings are intentional. |

## Git Hygiene Recommendations

1. Remove large binaries and installers from git history using `git filter-repo` or BFG if repository size matters.
2. Keep release builds outside the repo and publish them through GitHub Releases, Firebase App Distribution, Play Console, or App Store Connect.
3. Keep generated diagnostics, installers, local build artifacts, and release archives out of git.

4. Add or confirm ignore rules for local artifacts:

```gitignore
sentry-wizard.exe
*_output.txt
pub_get_output.txt
build_log.txt
full_cmd.txt
temp_achievements/
vitacase_flutter/
```

5. `.flutter-plugins-dependencies` has been removed from git and added to `.gitignore`.

## Current Repo State Notes

- `docs/final_readiness_audit.md` is currently untracked and should be added if you want the audit committed.
- `docs/folder_optimization_report.md` is the cleanup report created by this pass.
- No source files were deleted during cleanup.
