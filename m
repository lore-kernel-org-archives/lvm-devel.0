From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 30 Nov 2016 23:22:46 +0000 (UTC)
Subject: v2_02_168 annotated tag has been created
Message-ID: <20161130232246.D3CA56096F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c09aa3a299201a0cf34485fb8b1738fb81215bfa
Commit:        c09aa3a299201a0cf34485fb8b1738fb81215bfa
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-11-30 23:15 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-11-30 23:15 +0000

annotated tag: v2_02_168 has been created
	    at c09aa3a299201a0cf34485fb8b1738fb81215bfa (tag)
       tagging 57e24817b70cf577eea5e57e30a6c3d21ac550fc (commit)
      replaces v2_02_167

Release 2.02.168

59 files changed, 1663 insertions(+), 1143 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlg/XeoACgkQIoGRwVZ+LBeBxACfeV5nIv3nXba0q1+KEPrfzHku
6WMAoPzr6td3KBlnWf0esLqTZB5ydToz
=rtKi
-----END PGP SIGNATURE-----

Alasdair G Kergon (4):
      post-release
      lvconvert: Introduce enum to separate cases.
      raid: Remove fixed FIXME
      pre-release

Bryn M. Reeves (1):
      libdm: separate dm_stats_populate() error cases

Heinz Mauelshagen (5):
      dmsetup: return 0 for [--]{version,help}
      dmsetup: [v2] return 0 for [--]{version,help}
      lvchange: allow a transiently failed RaidLV to be refreshed
      WHATS_NEW: Allow a transiently failed RaidLV to be refreshed
      raid: fix sync percent on large RaidLVs

Peter Rajnoha (4):
      dbus: only log msg as debug if lvm2-lvmdbusd unit missing for D-Bus notification
      dbus: also recognize error state for missing service that comes from original D-Bus
      man: remove duplicate paragraph about selection criteria from lvm(8) man page
      scripts: fix comment about blk-availability init script

Tony Asleson (35):
      lvmdbustest.py: Remove raid4 use
      lvmdbus: Make bus name configurable
      lvmdbusd: Use one thread to fetch state updates
      lvmdbusd: Long running operations use own thread
      lvmdbustest.py: Support concurrent test runs
      lvmdbusd: _lv_create, simplify return path
      lvmdbusd: Add cfg.load to pv remove
      lvmdbusd: WS corrections
      lvmdbusd: Remove un-used import
      lvmdbustest.py: Reduce test client introspection calls
      lvmdbusd: Bubble up invalid JSON
      lvmdbusd: Extra report FD read on no data
      lvmdbusd: Place Manager.UseLvmShell request on queue
      lvmdbustest: Move std_err_print to testlib
      lvmdbustest: Reduce dbus object churn
      lvmdbusd: Remove debug JSON file
      lvmdbusd: cmdhandler.py, fix imports
      lvmdbusd: Fix source documentation
      lvmdbusd: Remove extraneous finally
      lvmdbusd: Only read whats buffered
      lvmdbusd: Make lvm shell read more robust
      lvmdbusd: Simplfy reading streams
      lvmdbusd: WS fix
      lvmdbusd: Remove debug log_error
      lvmdbusd: Remove unused variable
      lvmdbusd: Add --blackboxsize command line argument
      lvmdbusd: Supress protected member access warning
      lvmdbusd: Remove TODO on concurrent access to properties
      lvmdbusd: Emit signal on Job completion
      lvmdbustest.py: Re-enable test_vg_uuid_gen
      lvmdbustest.py: Remove outdated TODOs
      lvmdbustest.py: Remove redundant import
      lvmdbustest.py: Rename env test variable
      WHATS_NEW: New argument --blackboxsize
      lvmdbusd: Only allow 0..N for --blackboxsize argument

Zdenek Kabelac (34):
      raid: faster rmeta clearing
      tests: test raid0_meta type
      tests: for repair we need neewer version
      lvconvert: repair accepts interval and background
      cleanup: skip checking for just assigned string
      conf: support zero for missing_stripe_filler
      tests: update make targets
      tests: avoid using polling
      tests: do not set zero interval in aux lvm.conf
      cleanup: add dots to debug messages
      cleanup: avoid using double __ in extracted image name
      cleanup: debug trace and indent change
      tests: fix checking for pvmove LV
      raid: implement transient status check
      raid: lvconvert uses transient check for raid
      mirror: preserve MIRRORED status for temporara image
      cleanup: use display_lvname and msg cleanup
      cleanup: make this error an internal error
      cleanup: use lv_update_and_reload
      cleanup: hide gcc warning
      cleanup: single LVM_SYSTEM_DIR string
      cleanup: add doc for raid status states
      cleanup: deactivate has builtin check for active lv
      cleanup: use predefined macro for tmp image name
      cleanup: defines
      cleanup: indent changes
      debug: stack tracing corrections
      debug: more stacktrace corrections
      cleanup: add some dots and use display_lvname
      cleanup: add missing WARNING into log_warn
      cleanup: indent
      gcc: quiet warning about unused function
      makefiles: drop file source and indent
      tests: ensure there is dbus config file


