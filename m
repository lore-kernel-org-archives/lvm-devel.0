From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 24 Mar 2015 02:04:54 +0000 (UTC)
Subject: v2_02_118 annotated tag has been created
Message-ID: <20150324020454.5C79560F41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=efa5f89e8037998219144c1ae9f7781e37afdc43
Commit:        efa5f89e8037998219144c1ae9f7781e37afdc43
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-03-24 02:00 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-03-24 02:00 +0000

annotated tag: v2_02_118 has been created
	    at efa5f89e8037998219144c1ae9f7781e37afdc43 (tag)
       tagging 8bb1dfdd323cb70160f37a2d3a4cba48d5243be7 (commit)
      replaces v2_02_117

Release 2.02.118

83 files changed, 1153 insertions(+), 512 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlUQxTgACgkQIoGRwVZ+LBdgnACfTyP9aPeKczujHV6eDtFoh0zW
mGwAoKDbV78P5G6HfKhKqjFUVvk3yCTr
=LYtr
-----END PGP SIGNATURE-----

Alasdair G Kergon (15):
      post-release
      comments: Use full flag names.
      metadata: Detect internal use of LVM_WRITE_LOCKED.
      vgconvert: Check system ID compatibility.
      vgchange: Additional system ID warnings.
      systemid: Use temp status var for LVM_WRITE_LOCKED
      format_text: Set system id directly.
      metadata: Fix recent vg_validate message text.
      cache: Retain orphans while global lock held.
      systemid: Use correct mempool.
      pvs: Hide inaccessible clustered PVs.
      toollib: Reorder process_each_pv initialisation.
      cache: Store metadata size and checksum.
      format_text: Fix precommitted segfault.
      pre-release

David Teigland (12):
      system_id: enable the options in config file and command line
      Revert "systemid: Add ACCESS_NEEDS_SYSTEM_ID VG flag."
      system_id: make new VGs read-only for old lvm versions
      system_id: undo the previous changes to the lvm1 code
      system_id: avoid munging vg and lv fields
      man: add info to lvmsystemid
      tests: fix systemid uname test
      system_id: detect an lvm1 system id
      vgconvert: require lvmetad to not be used
      WHATS_NEW vgconvert -M fix
      tests: update to not run vgconvert -M with lvmetad
      reporting: should not fail with foreign option if lvm1 pvs exist

Ondrej Kozina (2):
      libdaemon: map error level properly
      tests: add omitted --atomic mode in pvmove-restart

Peter Rajnoha (4):
      report: fix seg_monitor field to display monitoring status for thick snapshots and mirrors
      systemd: blk-availability.service: add After=iscsi-shutdown.service
      lvmetad: pvscan: do not scan and read ignored MDAs from PVs
      pvmove: use safe version of iteration when iterating over vg->lvs list in _poll_vg

Zdenek Kabelac (38):
      devices: avoid extra open() syscall
      lib: zero returned labeller struct
      lib: return value
      cleanup: add stack trace
      lib: avoid reparsing same metadata
      lib: reduce parsing in vgname_from_mda
      lib: drop unneeded vg_read call
      tests: slightly more efficient vgcreate
      tests: speed of many PVS in a VG
      display: fix return values
      configure: check for sync-nand
      tests: extend test timeout to 180sec
      tests: enable kmsg by default
      tests: cleanup some cxx warnings
      tests: specify old mirror type
      tests: drop old workaround
      tests: extend race
      makefiles: split gcc -W options
      tests: do not leak in mem in destructor
      tests: capture and print thrown errors
      tests: drop unneeded comment
      tests: update makefile
      tests: update runner
      tests: avoid loop on older system
      tests: few more warnings for gcc only
      tests: drop unused ""
      tests: check for dmeventd first
      tests: fix select report
      tests: add ""
      lvchange: disable persistent minors for pools
      configure: detect st_ctim
      lvm-file: wrapper to read ctim from stat
      config: use timestamp with nanosecond precision
      pvscan: check sysfs dev entry before rescan
      makefiles: add more dirs for lcov
      tests: export shell vars
      tests: start clvmd without lib/
      tests: revert should removal in mirror test


