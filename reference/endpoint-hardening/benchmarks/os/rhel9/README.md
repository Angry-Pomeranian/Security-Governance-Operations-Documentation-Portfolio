# RHEL 9 Benchmark — Reference

## Note

This folder is a legacy location from an earlier folder structure. The CIS RHEL benchmark PDFs — including RHEL 9 — have been consolidated into the [`../rhel/`](../rhel/) folder alongside RHEL 8 and RHEL 10 benchmarks for easier cross-version reference.

The CIS RHEL 9 benchmark is located at:
`../rhel/CIS_Red_Hat_Enterprise_Linux_9_Benchmark_v2.0.0.pdf`

---

## RHEL 9 Benchmark Overview

**CIS Red Hat Enterprise Linux 9 Benchmark v2.0.0** defines a security baseline for RHEL 9 and compatible distributions (AlmaLinux 9, Rocky Linux 9). It covers:

- Filesystem configuration and partition layout
- Software and service hardening (disable unused daemons)
- Network parameter tuning via `sysctl`
- Logging and auditing with `auditd`
- User access controls and PAM configuration
- SSH server hardening
- Kernel module restrictions

---

## Key Hardening Areas

| Area | Controls |
|---|---|
| Services | Disable unused network services (avahi, cups, dhcpd, nfs, rpcbind, vsftpd); enable only required services |
| Auditing | Configure `auditd` to log privileged command execution, file modification, and account changes; ensure logs are persistent |
| Network | Disable IP forwarding, ICMP redirects, and source routing; enable TCP SYN cookies |
| PAM | Enforce password complexity, minimum length, history, and account lockout after failed attempts |
| SSH | Disable root login, password authentication (enforce key-based), enforce MACs and ciphers, set idle timeout |
| Filesystem | Separate `/tmp`, `/var`, `/home` partitions with `noexec`/`nodev`/`nosuid` mount options |

---

## Related

- [RHEL Benchmarks (all versions)](../rhel/) — RHEL 8, 9, and 10 benchmark PDFs
- [OS Benchmarks Overview](../) — All OS benchmark folders (Windows, Ubuntu, Debian, Oracle Linux)
- [Endpoint Hardening Overview](../../../README.md)
