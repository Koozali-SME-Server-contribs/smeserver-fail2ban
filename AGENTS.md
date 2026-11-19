# AGENTS.md

SME Server (Koozali) contrib RPM that integrates fail2ban. It ships config templates, a Server Manager UI, an smanager UI, and an sfail2ban CLI. `noarch` RPM, `Epoch: 9`, `AutoReqProv: no`.

## Layout
- `root/` — package payload staged as a filesystem tree (e.g. `root/etc/e-smith/templates/...`). This is the real source.
- `root/etc/e-smith/templates/` — e-smith template fragments. Fragments are numbered (e.g. `30Service10ssh`) and merged in numeric order into the target file during events. A fragment's *filename* determines ordering.
- `additional/` — extra files copied into the source tarball (legacy `smeserver-fail2ban.spec` lives here).
- `createlinks` — Perl script run during `%build` that wires template fragments to events (via `templates2events`) and creates service/panel links. **Editing this is required whenever you add a new template fragment or an event-triggered action.**
- `smeserver-fail2ban.spec` (repo root) — the authoritative spec. Do NOT edit `additional/smeserver-fail2ban.spec`; it is an obsolete legacy spec (e-smith, tar.gz, release 1).
- `0_*/`, `0.*/`, `*.src.rpm`, `*.log` — generated build artifacts. Do not edit or commit changes to them.

## Build / test
The shared build driver is `Makefile.common`, fetched from an external `common` module (not in this repo) by the `Makefile`; targets like `make prep` produce the source tarball.

Local build flow (from the mock/fred logs):
1. `make prep` — creates `smeserver-fail2ban-0.1.18.tar.xz` from `root/`, `createlinks`, and `additional/*` (strips `.gitignore`).
2. `rpmbuild --define "dist .el8.sme" --define "rhel 1" --define "el8_sme 1" --define "sme 11" --nodeps -bs smeserver-fail2ban.spec` — builds the source RPM.
3. `mock -r smeserver-11-x86_64-base --resultdir=... rebuild <src.rpm>` — builds the binary RPM in a chroot.

`%build` runs `perl createlinks`; `%install` runs `/sbin/e-smith/genfilelist` and explicitly assigns attributes to a handful of files (daemon.log, cleanup_fail2ban, apache-auth.local, sfail2ban). If you add a file needing special perms/config(noreplace) handling, it must be added to that `genfilelist` invocation in the spec.

## Changes to template fragments / events
Merging a fragment into the live config only happens when the associated e-smith event fires. On a live box test with `expand-template /etc/fail2ban/jail.conf` (or run the relevant event). A fragment change that is not registered in `createlinks` will silently never be applied.

## Version / release flow
1. Bump `%define release` in the root spec and add a `%changelog` entry (format: `* <Day> <Mon> <dd> <yyyy> <Name> <<email>> <ver>-<rel>.sme` with an `[SME: <bug>]` reference).
2. Commit; tag as `0_1_18-<rel>_el8_sme` (ver underscores, rel hyphen, `_el8_sme` suffix); push the tag.
3. Submit build: `koji build --nowait contribs11-contribs 'git+https://src.koozali.org/smecontribs/smeserver-fail2ban#<TAG>'`
