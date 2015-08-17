From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 17 Aug 2015 16:30:37 +0000 (UTC)
Subject: v2_02_128 annotated tag has been created
Message-ID: <20150817163037.1262F605AE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=411f73c0326dc6da96b770771cd4c6eff98977e2
Commit:        411f73c0326dc6da96b770771cd4c6eff98977e2
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-08-17 16:21 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-08-17 16:21 +0000

annotated tag: v2_02_128 has been created
	    at 411f73c0326dc6da96b770771cd4c6eff98977e2 (tag)
       tagging be1db6b6c17226894233f7d9629117b0cd554b88 (commit)
      replaces v2_02_127

Release 2.02.128.

We consider dmstats now to be ready for use.

For example, to monitor I/O to each segment of logical volume vg0/lvol0
separately at 5 second intervals:
  dmstats create vg0/lvol0 --segments
  dmstats report --interval 5

Direct integration into LVM and some more extensions will follow soon.

54 files changed, 1674 insertions(+), 697 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlXSCfgACgkQIoGRwVZ+LBeXMwCgmIoL4p/v67Wjw6u4yzkO1hCN
zksAni/p+/5UkqQUxoOOiS7SAO+cBRJh
=GMhq
-----END PGP SIGNATURE-----

Alasdair G Kergon (8):
      post-release
      dmsetup: Use #define for command names.
      dmsetup: Restructure arg handling.
      dmsetup: Fix dmsetup return code.
      WHATS_NEW: Update.
      device: Don't try to close config file on failure.
      conf: Regenerate example.conf.
      pre-release

Bryn M. Reeves (33):
      dmsetup: remove bogus !_report test in _stats_report (Coverity)
      libdm: fix FILE leak in _program_id_from_proc() (Coverity)
      libdm: fix stats handle leak in dm_stats_create (Coverity)
      dmsetup: don't free handle if dm_stats_create fails (Coverity)
      libdm: simplify stats nr_areas calculation (Coverity)
      libdm-stats: backtrace if fclose fails (Coverity)
      libdm: add dm_timestamp_copy()
      dmsetup: use timerfd for interval timing if available
      dmsetup: only free resources once in the final interval
      dmstats: don't output column headings when args checks fail
      dmstats: don't output column headings if report fails
      dmsetup: make timekeeping debug messages more readable
      dmstats: improve region creation messages
      dmstats: replace --force with new stats-specific --alldevices
      dmstats: do not use "region_id" in error messages
      dmstats: add 'interval' and 'interval_ns' report fields
      dmstats: cleanup _do_stats_create_regions()
      dmstats: separate stats meta fields into their own report type
      dmstats: make 'dmstats list' use common report infrastructure
      WHATS_NEW_DM: recent commits (stats field split and timestamp headers)
      dmsetup: do not track moving average for interval estimate
      dmstats: add 'stat_' prefix to stats report columns
      dmsetup: add prefixes for all report types
      dmsetup: add support for 'stats report --raw'
      libdm: ensure dm_stats_get_area_start includes region offset
      libdm: add dm_stats_get_{current_}area_offset()
      dmstats: add 'area_offset' field to stats reports
      dmstats: make -v enable per area reports for 'stats list'
      dmstats: change region fields prefix to 'region_'
      dmstats: fix new area count for 'create --areasize'
      dmstats: fix --length argument
      libdm: ensure dm_stats_get_area_offset() returns a value
      libdm-stats: only return uint64_t when required

David Teigland (6):
      vgremove: fix locking when lvmlockd global lock is removed
      lvmlockd: fix check for other sanlock lockspaces
      lvmlockd: add LV name to some debug logging
      lvrename: fix lockd LV locking
      lvconvert: fix lockd LV locking
      config: description updates

Marian Csontos (1):
      spec: Add cache-*.profile

Natanael Copa (1):
      libdm: do not in include internal bits/time.h header

Thomas B??chler (1):
      udev: use += for SYSTEMD_WANTS instead of =

Zdenek Kabelac (27):
      configure: --clear-need-check-flag needs 0.5.4
      cache: add cache_policy cache_settings
      cache: introduce mq and smq profiles
      cache: detect smq policy presence
      cache: runtime detect default policy
      cache: man updates
      toollib: get_cache_params
      cache: undefined policy is mq
      cache: api update
      cache: add more validation
      config: support longer config paths
      config: extend definition for Allocation
      libdm: cache target arg validation
      libdm: rename to data_block_size
      cleanup: use IEC KiB units
      cleanup: indent
      tests: link some new cache profiles
      tests: keep testing mq policy
      lvcreate: fix return value
      udev: fix missing escape for +
      cache: use undefined settings for cache_policy
      thin: restore transaction_id handling
      tests: Revert update for new thin pool messaging
      dmsetup: fix usage of ifdefs
      cache: move detection code to cache_set_policy
      tests: update thin test
      cache: more comments for new setting


