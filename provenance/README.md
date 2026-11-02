# Preserved source records

- [lean/as-received.tar.gz](lean/as-received.tar.gz) contains the supplied Lean
  proof sources, original `Main.lean`, build configuration, and two source
  scripts, with normalized archive metadata. [lean/SHA256.json](lean/SHA256.json)
  identifies each member's exact bytes. It excludes dependency caches and
  development transcripts.
- [independent/AUDIT.md](independent/AUDIT.md) and the accompanying hash manifest
  and two logs preserve the independent audit. The original audit predates Lean.

The original archive remains unchanged. The exact differences between its
`RestrictedBell` sources and the active project are recorded in
[lean/public-source.patch](lean/public-source.patch): updated comments, a direct
counting-to-certificate bridge, relocation of the supplementary profile bridge,
and explicit monicity, nonzero, and degree lemmas.
`scripts/check_sources.py` checks the archive hashes, the complete source diff,
the original audit's hashes, and certificate transcription into Lean.

See [PROVENANCE.md](../PROVENANCE.md) for the timeline and path mapping.
