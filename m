From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 3 Nov 2017 00:43:40 -0400
Subject: v2_02_176 annotated tag has been created
Message-ID: <201711030443.vA34hegA005217@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ba95d0d3ca8588510986bc35f9cded24b01819e3
Commit:        ba95d0d3ca8588510986bc35f9cded24b01819e3
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2017-11-03 02:29 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2017-11-03 02:29 +0000

annotated tag: v2_02_176 has been created
	    at ba95d0d3ca8588510986bc35f9cded24b01819e3 (tag)
       tagging 29300e72eebe974d90ebd2b55925bd728f81a326 (commit)
      replaces v2_02_175

Release 2.02.176.

Another assortment of small fixes.

121 files changed, 2955 insertions(+), 3395 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAln71MQACgkQIoGRwVZ+LBeSqwCfWdmUzoSlfa0BhH2D4qcUVzCO
za8AmQG0BERRK691O9u/jrBQUgb3101b
=Wl6C
-----END PGP SIGNATURE-----

Alasdair G Kergon (11):
      post-release
      man: regenerate
      thin: Improve overprovisioning and repair warnings.
      device: Separate errors for dev not found and filtered.
      tidy: Add missing underscores to statics.
      liblvm: Move lib code used exclusively into metadata-liblvm.c
      dmsetup: Add unknown device error to dmsetup status.
      vgsplit: Fix detection of moved PVs.
      metadata: Avoid accessing ignored metadata.
      liblvm: Fix segfault in lvm_pv_remove.
      pre-release

Bastian Blank (1):
      systemd: remove Install sections from socket-activated services

David Teigland (2):
      replicator: remove the code
      lvmlockd: check error for sanlock access to lvmlock LV

Heinz Mauelshagen (10):
      raid: return previous reshape space allocation properly
      raid: fix validation checks for segment data_offset member
      lvcreate: fix region size on striped RaidLVs
      raid: fix validation check for raid0 segment data_offset member
      raid: cleanup raid4/5/6/10 validation check
      lvcreate: allow 100%FREE creation of "--type mirror" to work
      test: remove 'should's from test to test target status race fix
      raid: ignore --stripes/--stripesize on takeover
      lvcreate: error message with dot.
      WHATS_NEW: ignore stripes/stripesize on RAID takover

Jonathan Brassow (5):
      clean-up:  Correct the comment to match the particular test case
      test: clean-up failing test case and document 'should' cases
      testsuite: Add and document a 'should' for "idle" -> "recover" RAID test
      testsuite:  Fix problem when checking RAID4/5/6 for mismatches.
      testsuite:  Forgot to pull 'should's after fixing RAID4/5/6 mismatch test

Marian Csontos (3):
      test: "Disable" lvconvert-raid-reshape
      Update WHATS_NEW
      configure: autoreconf

Ondrej Kozina (13):
      fsadm: add support for crypt devices
      test: add fsadm crypt test
      fsadm: minor fixes for crypt support
      test: fsadm-crypt.sh fixes
      fsadm: respect DM_DEV_DIR variable
      fsadm: fail 'check' explicitly on unsupported fs type
      fsadm: implement 'check' for a fs on top of LUKS
      test: update fsadm-crypt to pass with legacy cryptsetup
      fsadm: add luks specific error message for small devices
      fsadm: fix bug in LUKS grow/shrink decision branch
      test: add regression test for fsadm bug
      fsadm: rename local variables to avoid confusion
      fsadm: refactor resize_crypt function

Zdenek Kabelac (39):
      activation: fix locking resource name for activation lock
      activation: fix activation lock
      thin: monitor also external origin
      tests: check external origin is monitored
      libdm: fix typo in libdevmapper.pc
      lvconvert: preserve names of converted LV
      lvextend: detect stacked cache lv used for thinpool
      lvcreate: skip checking for name restriction for caching
      tests: check stacked cache dataLV of thin-pool
      lvconvert: fixing extraction of vgname
      tests:check lvconvert with /dev in vglvname
      snapshot: improve validation
      typo: fix invalid
      tests: snapshot conversions
      configure: improve support for sbindir path
      systemd: use proper sbindir path
      scripts: paths update
      shellcheck: some apostrophe changes and cleanups
      commands: drop secondary for lvconvert --type snapshot
      WHATS_NEW: missed
      log: better message when reached log limit
      Makefile: help shows hint about LVM_LOG_FILE_MAX_LINES
      tests: allow override of LVM_LOG_FILE_MAX_LINES
      tests: better clustering support
      man: Makefiles with V=1 support
      snapshot: relocate common code validation for snapshot origin
      tests: update checked messages
      pool: drop create spare on error path
      thin: fix merging messages
      devcache: track more udev errors
      validation: capture store of LV without segment
      lvreduce: check LV has segment
      tests: load reiserfs
      raid: setup LV size earlier
      tests: revert commit change
      pvmove: simplify name generation
      lv_manip: hide layered LV temporarily
      cleanup: pvmove messages
      cleanup: use segtype_is_raid_with_meta


