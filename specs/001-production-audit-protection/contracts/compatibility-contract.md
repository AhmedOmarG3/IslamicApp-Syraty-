# Compatibility Contract

| Contract | Identifier | Required behavior |
|---|---|---|
| Startup | `/` | Recoverable startup journey |
| Core routes | `/home`, `/quran`, `/azkar`, `/tasbeeh`, `/prayer` | Remain reachable |
| Detail routes | `/surah-details`, `/zekr-details` | Valid arguments work; malformed input recovers safely |
| Quran progress | `last_read_index` | Preserve valid values; avoid destructive invalid-value overwrite |
| Quran asset | `assets/json/quran.json` | Preserve path and approved content |
| Azkar asset | `assets/json/adhkar.json` | Preserve path and approved content |
| App identity | Existing package/signing setup | No change without approved migration and rollback |

