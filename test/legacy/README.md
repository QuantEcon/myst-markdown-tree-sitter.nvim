# Legacy Test Files

This directory contains ad-hoc test and validation scripts from the development history
of this plugin. These files were used during development to verify fixes for specific
issues but are **not part of the automated test suite**.

## What's Here

- `demo_*.lua` - Demo scripts for manual testing
- `test_*.lua` - Legacy test scripts (not plenary-based)
- `test_*.md` - Test markdown files for manual verification
- `validate_*.sh` - Shell scripts for specific issue validation
- `validate_*.lua` - Lua validation scripts

## Automated Tests

The proper automated tests are in:
- `test/unit/` - Plenary-based unit tests
- `test/integration/` - Plenary-based integration tests
- `test/fixtures/` - Test data files used by automated tests

Run automated tests with:
```bash
make test           # All tests
make test-unit      # Unit tests only
make test-integration  # Integration tests only
```

## Note

These legacy files may be removed in future versions. They are kept temporarily
for reference when investigating historical issues.
