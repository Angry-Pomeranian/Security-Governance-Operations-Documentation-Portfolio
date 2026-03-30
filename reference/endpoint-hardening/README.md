# Endpoint Hardening

CIS benchmark references, implementation guides, and tooling for OS and browser hardening across Windows, RHEL 9, Chrome, Edge, and Firefox.

---

## Structure

```
endpoint-hardening/
├── benchmarks/
│   ├── os/
│   │   ├── windows/                  # CIS Windows benchmark guidance
│   │   └── rhel9/                    # CIS RHEL 9 benchmark guidance
│   └── browsers/
│       ├── chrome/
│       │   └── benchmarks/           # CIS Chrome benchmark controls
│       ├── edge/
│       │   └── benchmarks/           # CIS Edge benchmark controls
│       ├── firefox/
│       │   └── benchmarks/           # CIS Firefox benchmark controls
│       └── extensions/               # Browser extension control (AppLocker via Intune)
├── guides/
│   └── veeam/                        # Veeam Backup security configuration
└── scripts/
    ├── README.md                     # CIS Benchmark Converter documentation
    └── cis_benchmark_converter.py    # PDF → Excel/CSV/JSON benchmark extractor
```

---

## Key Documents

| Path | Description |
|------|-------------|
| `scripts/cis_benchmark_converter.py` | Extracts CIS controls from PDF benchmarks into structured formats |
| `benchmarks/browsers/extensions/applocker-using-intune.md` | AppLocker policy deployment via Intune |
| `benchmarks/os/rhel9/` | RHEL 9 CIS baseline |
| `benchmarks/os/windows/` | Windows CIS baseline |

---

## Script Usage

```bash
python cis_benchmark_converter.py \
  -i path/to/benchmark.pdf \
  -o output_file \
  -f [csv|excel|json] \
  --start_page 10
```

See `scripts/README.md` for full parameter reference.

---

## Related

- MEM browser policy deployments → `../identity-access/policies/conditional-access/mem-win10-chrome-cis/`
- MEM browser policy deployments → `../identity-access/policies/conditional-access/mem-win10-edge-cis/`
