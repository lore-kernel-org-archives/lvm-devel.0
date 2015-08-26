From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 26 Aug 2015 22:18:08 +0000 (UTC)
Subject: v2_02_129 annotated tag has been created
Message-ID: <20150826221808.6485A61911@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd7efa7069096d5b5f4aab5785088f647faa528a
Commit:        dd7efa7069096d5b5f4aab5785088f647faa528a
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-08-26 22:12 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-08-26 22:12 +0000

annotated tag: v2_02_129 has been created
	    at dd7efa7069096d5b5f4aab5785088f647faa528a (tag)
       tagging a37fd93fbb51eed8b102b373f2338f6d2802ae5f (commit)
      replaces v2_02_128

Release 2.02.129.

58 files changed, 2760 insertions(+), 1784 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlXeOegACgkQIoGRwVZ+LBcO5ACg7SrYu/YLwnyurGHNF7gy51Td
eyAAoOB9Z5ZExcf7PzimVHyFcjAwrRtG
=rl8w
-----END PGP SIGNATURE-----

Alasdair G Kergon (5):
      post-release
      make.tmpl: Mark internal sharedlib symbols local.
      libdm: Drop ignored duplicate export designation.
      vgdisplay: Drop error message for exported VGs.
      pre-release

Bryn M. Reeves (18):
      libdm: do not read region before checking dms for NULL (Coverity)
      dmsetup: make sure subcommand is initialised (Coverity)
      dmstats: check for zero in _nr_areas_from_step() (Coverity)
      libdm: check for zero in _nr_areas() (Coverity)
      dmsetup: check timerfd reads for valid byte count (Coverity)
      dmstats: fix type formatting
      dmstats: reduce minimum field widths
      man: update dmstats.8.in examples
      configure: check for -lm and log10 function
      libdm: add dm_message_supports_precise_timestamps()
      man: fix program_id string in dmstats.8.in
      macros: fix default symbol export control
      libdm: add precise timestamps support to libdm-stats
      libdm: add per region precise timestamps property methods
      dmstats: add --precise switch to enable nanosecond counters.
      dmstats: add 'precise' flag field to stats report
      makefiles: fix ld version script generation for older make versions
      makefiles: remove stray ')'

David Teigland (16):
      config: explain automatic default values
      config: recognize a blank comment line
      config: add empty lines around examples
      config: create lists of accepted values in descriptions
      lockd: no error when unlock fails
      config: improve description text layout
      tests: fix lockd options in sanlock-prepare
      lvmlockctl: fix debug output
      lvmlockd: change log_error to log_debug for non error
      lvmlockd: ignore cmd close if no locks were taken
      lvmlockd: fix sending debug info to lvmlockctl
      test: allow tests with lvmlockd
      tests: create/remove improvements for lvmlockd testing
      tests: add lib function to test hidden LVs with lvs -a
      tests: add test for lvmlockd lock_args
      tests: fix check for lvmlockd test

Ferenc W??gner (6):
      cmirrord: move generic setup from daemonize() to init_all()
      cmirrord: add --foreground and --help options.
      cmirrord manual: add --foreground and --help options
      cmirrord: fix stack smashing
      cmirrord: avoid debugging buffer overflow in LOG_SPRINT
      cmirrord: avoid resync buffer overflow in LOG_SPRINT

Heinz Mauelshagen (1):
      WHATS_NEW: Update.

Zdenek Kabelac (26):
      lvmcache: check for too long pvid
      lockd: check for failing unlock
      libdm: simplify dmstats formula.
      cleanup: unused header files (Coverity)
      cleanup: add cast
      cleanup: add FMTssize_t
      cleanup: typo fix and drop \
      cleanup: check pthread result codes
      cleanup: trace error from lvmcache_update_vgname_and_id
      debug: vgdisplay trace failing result code
      Revert "lvmcache: check for too long pvid"
      cleanup: log_debug format matches args
      cleanup: preserve constness of some pointers
      cleanup: move var declaration
      cleanup: compare fgets pointer
      cache: enable setting cachepolicy in lvconvert
      thin: metadata size cannot be reduced
      man: fix sqm typo
      cleanup: add .
      tests: check cachepolicy with lvconvert
      WHATS_NEW
      cache: no report error for cpool without mode
      cache: report cache pool attrs also for pools
      cache: lvconvert accepts --cachemode for --cache
      man: replace to with for
      tests: update cache tests


