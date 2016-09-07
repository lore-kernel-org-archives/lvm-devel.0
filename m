From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  7 Sep 2016 01:35:26 +0000 (UTC)
Subject: v2_02_165 annotated tag has been created
Message-ID: <20160907013526.0B17460DAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70633e7a4d5f616e4a125b1834e320946b373881
Commit:        70633e7a4d5f616e4a125b1834e320946b373881
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-09-07 01:26 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-09-07 01:26 +0000

annotated tag: v2_02_165 has been created
	    at 70633e7a4d5f616e4a125b1834e320946b373881 (tag)
       tagging 3d2b1ff5c4cfbeec36b4ab93dc08e87a252b7fed (commit)
      replaces v2_02_164

Release 2.02.165.

An assortment of minor fixes.

65 files changed, 2721 insertions(+), 448 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlfPbOwACgkQIoGRwVZ+LBe4KQCgxt4r/avnkT39lT//8yU6esh0
B6QAoN/sZokVRK4yRcX6OqvivowRO9ef
=OVcM
-----END PGP SIGNATURE-----

Alasdair G Kergon (23):
      post-release
      tools: Suppress some unnecessary --stripesize warnings.
      lib: Move lcm and gcd to lib/misc for wider use.
      toollib: Record whether or not stripes/stripe_size args supplied.
      lvcreate: No longer adjust --stripes for raid types.
      lvcreate: Drop warning messages for number of raid stripes.
      lvconvert: Don't allow --repair on raid0 LVs.
      lvcreate: Never treat raid0 as linear.
      raid: Don't monitor raid0 or raid0_meta LVs.
      dmeventd: Fix unmonitoring when segtype changes.
      dmeventd: Start merging back replacement unmonitor code.
      dmeventd: Simplify replacement unmonitor code.
      dmeventd: Add fixed timeout when unmonitoring.
      lvconvert: Disallow raid10 mirror conversions.
      alloc: Move _log_parallel_areas.
      alloc: Record PV tags of parallel PVs in log.
      alloc: Avoid PV tags too when avoiding parallel PV allocation.
      lvconvert: Fix --splitmirrors segfault with incorrect PV.
      raid10: Fix #stripes in lvcreate msg when too many.
      config: regenerate
      lvmetad: Unused includes.
      man: Additional info on exit statuses.
      pre-release

David Teigland (8):
      man: lvconvert change location of sentence
      man: lvconvert mention required option
      libdaemon: add errno to error message
      lvmetad: use udev to ignore multipath components during scan
      man: add lvmraid(7)
      man lvmraid: remove rebuild example
      man lvmraid: comment out unfinished features
      man lvmraid: install

Heinz Mauelshagen (6):
      pvmove: prohibit non-resilient collocation of RAID SubLVs
      pvmove: fix regression introduced with 8e9d5d12ae3ac75852ebd74b64c28e31abb68d0e
      lvcreate: better error message creating RAID LV on < 4 KiB VG extent size
      vgsplit: fix regression processing thin external origins
      test: add missing lvchange-rebuild-raid.sh
      test: delay writes to all test PVs in lvchange-rebuild-raid.sh to avoid race

Peter Rajnoha (8):
      libdm: add some comments about DM_UDEV_DISABLE_LIBRARY_FALLBACK flag
      conf: fix typo in report/columns_as_rows config option name recognition
      tests: also fix typo in report/columns_as_rows in tests
      lvmdump: use lsblk -s and lsblk -O in lvmdump only if these options are supported
      lvmetad: check udev for mpath component several times if udev record not initialized yet
      refactor: move and rename _dev_is_mpath_component in lvmetad.c to udev_dev_is_mpath_component in dev-type.c
      dev-type: use more appropriate messages in udev_dev_is_mpath_component and use 10s timeout
      dev-type: check for DEVLINKS udev db variable existence if udev_device_get_is_initialized fn is not present

Tony Asleson (19):
      lvmdbusd: Always fork & exec background commands
      lvmdbusd: Add date & ts if running in a terminal
      lvmdbusd: Add support for using lvm shell
      lvmdbusd: Use udev until ExternalEvent occurs
      lvmdbusd: Be more explicit on return values
      lvmdbusd: Make job.Percent a double
      lvmdbustest.py: Remove '-' from tag ch set
      lvmdbusd: Be more specific on return types for Lv
      lvmdbusd: Correct return type for empty PeSegments
      dbus/testlib.py: Improve type checking
      lvmdbusd: Include lvm shell testing as the default
      lvmdbusd: Handle different daemon options
      test/lib/aux.sh: Remove '--udev' for lvmdbusd start
      test/lib/aux.sh: Remove incorrect comment
      lvmdbusd: Correct imports
      lvmdbusd/lvmdb.py: Make stand alone execution work
      lvmdbusd: WS/pep8 corrections
      lvmdbustest.py: Add tag regression test
      lvmdbusd: Prefix tag string with '@'

Zdenek Kabelac (6):
      cache: introduce cache_pool_max_chunks
      cache: do not monitor cache-pool
      cleanup: clean gcc6 minor/major types warnings
      debug: better verbose message
      dmeventd: typo and debug name fix
      tests: skip test for older cache target


