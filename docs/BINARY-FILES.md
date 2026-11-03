# Tested driver binaries

Five kernel modules were provided from the successful FydeOS test. Their metadata was inspected using `modinfo`.

**Target kernel:** `6.12.54-01180-gb4e10020ba49-dirty`

| Module | SHA-256 |
|---|---|
| `mt76.ko` | `c616184327a43ac2573b89e54061030fb5f68803a5a2513aa353bb20afc2588b` |
| `mt76-connac-lib.ko` | `526f102abe1b7c7893ae98ef52809181fb7e527dda3c28a0fd50757022537921` |
| `mt792x-lib.ko` | `7164575be20e5f7706f7641256ea8076a160fa2d2db5fcdf8800f68aaa82505d` |
| `mt7921-common.ko` | `a9c61b9128ccd9cc3024708a40e1f2cfde69b2f82d9e053e77790096b01d8af4` |
| `mt7921e.ko` | `b1ccfb649ffb168bc931888729c0ec91d9d9f08e90e4b2b7542fbfa85ccffda4` |

The `mt7921e.ko` module advertises the MT7902 PCI alias `14c3:7902` and MT7902 firmware names. **These binaries are not currently attached to the GitHub repository.** Before redistribution, ensure corresponding GPL/BSD-licensed source and notices are available and review license obligations.

Never use them on a different kernel just because the filename matches. Exact kernel configuration and ABI matter.
