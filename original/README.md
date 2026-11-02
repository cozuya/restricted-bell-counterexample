# Original computational refutation

These six files preserve the accepted pre-Lean result byte-for-byte:
[argument](research/argument.md), [handoff](research/handoff.md),
[verifier](code/check.py), [certificate](certificates/witness.json),
[result record](result.json), and [recovery README](PROOF-README.txt).

The recovery README was written before the Lean formalization. Its statement
that there is no formal verification describes that earlier snapshot. The
current unconditional Lean results are in [Final.lean](../RestrictedBell/Final.lean).
The original orchestration status in these records is also historical.

Run the original exact-arithmetic check from the repository root:

```sh
python3 original/code/check.py
```

Python 3.9 or later and its standard library are sufficient. Assertions must
remain enabled; do not use `python -O`. The original mathematical write-up
retains its original math delimiters and relative links.
