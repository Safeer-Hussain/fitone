# Fitone Autonomous Engineering Engine Rules

## 1. Daily Sprint Trigger Protocol
Whenever the user prompts: **"run daily sprint"** (or case-insensitive variations like "run sprint", "next sprint", "execute daily sprint"):

1. **Read Backlog**: Open `docs/AUTONOMOUS_BACKLOG.md` and identify the first item marked with `[ ]`.
2. **End-to-End Implementation**:
   - Implement the complete, production-grade feature matching Clean Architecture (`core/`, `data/`, `domain/`, `presentation/`).
   - Use MobX stores for reactive state management and register new dependencies in `core/di/injection.dart`.
   - Never leave any `// TODO`, fake methods, or placeholders. Every button, calculation, and UI element must be 100% functional.
   - Maintain strict anti-AI hygiene: **NEVER use emojis** in source code, UI strings, debug logs, or commit messages. Use vector Icons (Material Symbols / Cupertino) instead.
   - Never write tutorial-style comments (e.g., "// This method does X").
3. **Automated Verification**:
   - Add at least one meaningful unit or widget test covering the newly implemented feature in `test/`.
   - Execute `flutter analyze` and ensure zero errors and zero warnings.
   - Execute `flutter test` and ensure all tests pass with 100% green status.
4. **Backlog Update & Commit**:
   - Update `docs/AUTONOMOUS_BACKLOG.md`, changing `[ ]` to `[x]` for the completed sprint.
   - Stage all files: `git add .`
   - Commit with a senior conventional commit message (e.g., `feat(workout): add barbell plate loading calculator and unit tests`). Do NOT use emojis in the commit message.
   - Push to GitHub: `git push origin main`.
   - Provide the user with a concise summary of the delivered sprint, files modified, and test results.

## 2. Core Architectural Standards
- Primary State Management: MobX (`mobx`, `flutter_mobx`).
- Dependency Injection: `get_it`.
- Storage: Local SQLite database via `sqflite` with robust offline-first caching.
- Network: `Dio` with custom `MockApiInterceptor` and `NetworkMonitor`.
- Platform Channels: Native Kotlin (`MainActivity.kt`) and Swift (`AppDelegate.swift`) for wearable hardware bridges.
