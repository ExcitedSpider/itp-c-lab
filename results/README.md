# Evidence

Use `rework/setup.json`, `rework/metrics.json`, and `rework/*-checks.json` for
the current installed-tool experiment. Every run has exact command/output logs.
`measure.py` computes metrics; `audit_sources.py` checks function-body tokens
and scans proof sources for admission commands. `rework/browser-qa.json` records
real Chromium interaction checks. Old top-level JSON files and JavaScript
runners describe the superseded initial attempt and must not be used as current
results. They are retained as historical evidence, not silently overwritten.
