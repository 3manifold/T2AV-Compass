# T2AV-Compass Repository Maintenance

This document is for maintainers of this repository fork and focuses on repository hygiene, especially submodule stability.

## 1. Repository Layout

- `README.md`: Main English documentation.
- `README_cn.md`: Main Chinese documentation.
- `t2av-compass/`: Evaluation code, scripts, and metric implementations.
- `docs/`: Project page assets and maintenance documentation.
- `.gitmodules`: Source of truth for all git submodule mappings.

## 2. Clone and Initialize (Recommended)

Use recursive clone to avoid missing submodule content:

```bash
git clone --recurse-submodules https://github.com/MichaelCao0/T2AV-Compass_pr.git
cd T2AV-Compass_pr
```

If the repo is already cloned:

```bash
git submodule sync --recursive
git submodule update --init --recursive
git submodule status --recursive
```

## 3. Submodule Mapping Policy

Every gitlink entry (mode `160000`) must have one matching entry in `.gitmodules`.

Current tracked submodules:

- `t2av-compass/Objective/Audio/NISQA`
- `t2av-compass/Objective/Audio/audiobox-aesthetics`
- `t2av-compass/Objective/Similarity/LatentSync`
- `t2av-compass/Objective/Video/DOVER`
- `t2av-compass/Objective/Video/aesthetic-predictor-v2-5`

Quick check commands:

```bash
git ls-files -s | rg "^160000"
git config --file .gitmodules --get-regexp "^submodule\\..*\\.path$"
git submodule status --recursive
```

## 4. Fixing "no submodule mapping found in .gitmodules"

Typical error:

```text
fatal: no submodule mapping found in .gitmodules for path '<path>'
```

Resolution:

1. Ensure `<path>` exists in `.gitmodules`.
2. Sync submodule metadata:

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

3. Re-check:

```bash
git submodule status --recursive
```

## 5. Pre-Push Checklist

Before pushing:

```bash
git status
git submodule status --recursive
```

Ensure:

- No unexpected dirty submodule state.
- `.gitmodules` and tracked gitlink paths stay consistent.
- New docs are linked from `README.md` or `README_cn.md`.

## 6. Suggested Commit Practice

- Keep submodule maintenance changes in a dedicated commit.
- Use explicit commit messages, for example:
  - `fix: restore complete submodule mappings in .gitmodules`
  - `docs: add repository maintenance guide and submodule recovery steps`

