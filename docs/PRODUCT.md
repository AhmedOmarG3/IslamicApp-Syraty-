# Siraty Product Description

## Vision

Siraty is a calm, trustworthy, Arabic-first daily Islamic companion. It helps a
Muslim quickly understand the next prayer, continue Quran reading, access the
right daily Azkar, and use Tasbeeh without distraction.

## Target users

- Arabic-speaking Android users who want essential daily Islamic tools.
- Users who need Quran and Azkar access without a reliable internet connection.
- Users who value readable Arabic, simplicity, and continuity more than a large
  collection of features.

## Core daily journey

1. Open Siraty directly to the daily home.
2. See the correct next prayer, its location, and remaining time.
3. Continue Quran reading or open contextual morning/evening Azkar.
4. Complete the activity with progress preserved locally.
5. Return later without repeating setup or losing state.

## Current capabilities

- Local Quran Surah and verse reading.
- Stored last-read Surah index.
- Local Azkar categories and content.
- Remote prayer times searched by city.
- Local Tasbeeh counter during the current screen session.
- Arabic interface with an Amiri font and Material 3 foundation.

## Current limitations

- Prayer information has no reliable offline cache or typed failure model.
- The newer home UI contains hard-coded data and inactive actions.
- Quran resume is Surah-level and is not connected to the new home banner.
- Tasbeeh state is not persistent and its image-overlay UI is fragile.
- Tests are nearly absent.
- Settings, dark theme, notifications, Qibla, and audio are not complete features.

## Product boundaries

Siraty is not a fatwa service, social network, AI religious assistant, or a place
for generated Quran/Hadith content. It should not add a feature simply because
other Islamic apps contain it. Every feature must support daily usefulness,
reliability, continuity, or accessibility.

## Design personality

- Calm, warm, respectful, and content-led.
- Arabic-first and naturally RTL.
- Restrained green brand with a warm neutral background and one subtle accent.
- Consistent Material/vector icons; illustrations only for onboarding or empty
  states.
- Clear reading typography, generous but not wasteful spacing, accessible
  contrast, and minimal visual noise.

## Product success

- Prayer information is correct, understandable, and honest about location/data freshness.
- Quran resume returns to real stored progress.
- Core content works as promised offline.
- Users encounter no dead actions or fake content.
- Crash/ANR health does not regress after updates.
- The codebase contains specifications, tests, and release evidence that Ahmed
  can explain in an interview.

## Long-term plan

The ordered full-app roadmap—including Quran continuity, guided Azkar, prayer
notifications, Tasbeeh, audio, Qibla, Ramadan, backup, and the Islamic design
system—is defined in `docs/MASTER_PLAN.md`.
