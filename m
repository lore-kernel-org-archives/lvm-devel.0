From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 21 Feb 2023 14:39:03 +0000 (GMT)
Subject: v2_03_19 annotated tag has been created
Message-ID: <20230221143903.170033858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a84d53c113371f1908325dbada488c233f04e97
Commit:        8a84d53c113371f1908325dbada488c233f04e97
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2023-02-21 14:36 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2023-02-21 14:36 +0000

annotated tag: v2_03_19 has been created
	    at 8a84d53c113371f1908325dbada488c233f04e97 (tag)
       tagging f7dd2562c53347cec69bc060f838c95839770586 (commit)
      replaces v2_03_18

Release 2.03.19

Bugfix release
-----BEGIN PGP SIGNATURE-----

iQJIBAABCAAyFiEE1QGkeEQK4v0TChvouREkMeUJA58FAmP01xIUHG1jc29udG9z
QHJlZGhhdC5jb20ACgkQuREkMeUJA58w+BAA+rIdyFgCtsELFU/Q/lMPhmhJqxh4
y25qKnlclywQRN/obFum//BC4wyJkk4AgGn/CUmj2SXLCoZgR/pkc5dAacnMPHZ/
4lpKk7UxfOsPhUu7Arp7w3MSePK0jD+lLVKFpwKdk9wmrlcrL5/Xz+r0tfqoFPaQ
l0LH6jPbs8ju4BNAYpfA3ej5YHZ8NxtPBoyUEMK9/OasYZkBmqwcHlx6DXAFikft
7Ql+JiFVT4J36hxxYmQ8e1l7YHGEAd+8Yb6vE4/TlmWUZtEjpasy7g3ClM0r1lQP
sHtOIAQKoGaiiczd5+jq1MQtHCatCZskHz+u0Z0UaXpMhkhButjP+orn2h89f5Nt
yjT2p5HTHr6CTd6Cl3YX0nMhXdCqwBls4OOVZ08oIXrc+fP16LNrKbhtTBVmRCSJ
efQ+LgubHzmA3C6NeL75Y+mXeHy6OzwtLzdFBtEC2cB2moSlxSA22GTQYAyT+cj5
CIhdw33jR+dqP06XG6wChEGdCdnhZUEVYvf7GB0UqH6hPqbE2OBg3WifXEBKvESZ
R92KZKY83uyV3m4c3RLiO9RCxmUdU5rQ2Ug8pN7aIi1YhgqD1pQ+odubksOhUOs3
iXyOwiErdunFGeC3HXJq3xwnX3p0rgyFNYhDZ5m/EaDsXSPpyuBWtrRDapf+tTE0
ASy9Y9yjblVnYrk=
=nYaZ
-----END PGP SIGNATURE-----

David Seifert (3):
      configure.ac: use only portable POSIX shell
      configure.ac: only use `AS_IF` for conditional blocks
      configure.ac: only use `AS_CASE` for conditional blocks

David Teigland (18):
      lvresize: fix cryptsetup resize in helper
      tests: lvresize-fs-crypt using helper only for crypt dev
      vgimportclone: fix importing PV without metadata
      tests: vgimportclone with incomplete pv list and nomda pv
      lvmlockd: fix report of lv_active_exclusively for special lv types
      lvresize: only resize crypt when fs resize is enabled
      lvresize: enable crypt resizing with --force
      Revert "lvresize: enable crypt resizing with --force"
      lvresize: fail early if mounted LV was renamed
      lvresize: fail early if crypt device is missing
      pvscan: use alternate device names from DEVLINKS to check filter
      vgchange autoactivation: skip regex filter containing symlinks
      pvscan: recognize "pci" as a common symlink component in filters
      vg_read: remove unused code for md components
      device_id: ignore quotes in device id
      vgimportclone: fix non-duplicate PV with non-unique basevgname arg
      pvscan: filter does not need to be checked for symlink names
      pvscan: remove warning about excluded root dev

Jory Pratt (1):
      vgimportdevices: LOCK_EX requires <sys/file.h> include

Marian Csontos (5):
      pre-release
      post-release
      lvmlockd: Fix syntax error in previous commit
      Revert "makefiles: fix grep warning from make"
      pre-release

Peter Rajnoha (2):
      udev: don't reset SYSTEMD_READY in udev for PVs on MD and loop
      udev: remove rule for explicit creation of /dev/mapper/control

Samanta Navarro (1):
      doc: fix typos in documentation

Tony Asleson (3):
      lvmdbusd: Fix grammar
      lvmdbusd: Disable collecting lvm debug data by default
      lvmdbustest: Check and remove lvm debug collection files

Yu Watanabe (1):
      udev: import previous results of blkid when in suspended state

Zdenek Kabelac (64):
      lvresize: use standard extent conversion function
      vdo: check memory only in non critical section
      vdo: read live vdo size configuration
      vdo: fix and enhance vdo constain checking
      vdo: resize requires active vdopool volume
      tests: vdo resizing
      libdm: correcting ifdef possition
      makefiles: comment out hiding dir entering
      makefiles: fix grep warning from make
      archive: update message
      device_mapper: reduce unnecessary looping passed
      device_mapper: reactivate siblings for snapshot
      debug: compatibility with x32 ABI
      lv/vgchange: when refreshing whole vg skip snapshot
      lvm: fix typos
      metadata-exported.h: correcting definition
      lvresize: better detection of BLKID_SUBLKS_FSINFO
      configure.ac: remove some lvmetad leftovers
      configure.ac: misc updates
      configure: update
      lvresize_fs_helper: cleanup shellcheck warns
      makefiles: keep removing anchient files
      makefiles: avoid piping
      tests: fix cutandpaste bug in wrapper
      tests: remove blank line
      tests: avoid using length
      tests: cleanup some shellcheck warns
      tests: reduce shellcheck warns
      configure.ac: better blkid test
      configure.ac: support systemd-run binary path
      configure: update
      WHATS_NEW: update
      configure.ac: check for blkid  when required
      configure: update
      filesystem: use PATH_MAX for linux paths
      libdm: improve parallel create of control node
      libdm: match reactivation of sibling for snapshot
      WHATS_NEW_DM: update
      makefiles: use configured systemd library paths
      makefiles: allow using configure cppflags
      makefiles: update doc
      man: update lvmcache cache setting
      cov: drop unneeded header
      tests: skip test without mkfs.ext4
      tests: use PWD for dbus testing
      acinclude.m4: add local copy of PKG_CHECK_VAR
      configure.ac: fix support for LOCKDIDM
      configure.ac: remove UDEV_SYSTEMD_BACKGROUND_JOBS
      configure.ac: more cleanup
      configure: update
      lvconvert: fix return codes
      lvconvert: use log_print_unless_silent
      cov: avoid using strcpy
      debug: missing backtraces
      configure.ac: use LIBSYSTEMD
      configure.ac: use standardized LIBS and CFLAGS
      configure.ac: fix incorrect check for valid configuration
      configure.ac: remove unneded vars and settings
      configure.ac: various minor updates
      makefiles: move include earlier
      tests: check failing vdo conversion
      tests: lvmdbus testing use --debug optinally now
      tests: safety first...
      configure: update

lilinjie (1):
      fix typo

