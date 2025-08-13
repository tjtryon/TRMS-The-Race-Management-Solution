# CHANGELOG

All notable changes to TRTS are documented here. Dates use **YYYY‑MM‑DD**.

---

## [1.1.0] — 2025-08-12

### Added (Both)
- **Intelligent deployment detection**: Standalone vs **Integrated With TRMS** (auto‑pathing for config, imports, and databases).
- **Standardized database naming**: `YYYYMMDD-<race#>-<type>-<Race_Name>.db`.
- **Admin bootstrap** with **bcrypt** (first run creates admin user).
- **Documentation**: refreshed README for GUI and dedicated Console v1.1 notes.

### Added (GUI)
- **Libadwaita‑themed** GTK4 interface matching TRMS Launcher (colors, spacing, typography).
- **Right‑aligned dual‑line header** showing integration mode + database line (no separator).
- **Bottom console** with **Copy** to clipboard.
- **Themed dialogs**: instructions, environment, file pickers, error and results windows.
- **Content‑sized windows**: Select Race Type, Create DB, file pickers, and CSV import success dialogs are compact.
- **Dynamic Results** button adapts to race type; **Individual Results** button auto‑disables when no results exist.
- **Wayland‑first**, X11 compatible, with **GTK fallback** via `TRTS_FORCE_GTK=1`.

### Added (Console)
- **Live timing engine** with immediate persistence and robust termination flow.
- **Results processing**: Cross Country team scoring; Road Race age groups; Individual results.
- **CSV discovery order** preferring `TRDS/databases/imports/` when integrated.

### Changed
- Hardened startup chain for GApplication; clearer DEBUG breadcrumbs during launch (GUI).

### Deprecated
- None.

### Removed
- None.

### Fixed
- Multiple layout issues where dialogs were larger than necessary (GUI).

---

## [1.0.0] — 2025-08-01
- Initial public release (Console) and early GUI preview.
