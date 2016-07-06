From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  6 Jul 2016 00:15:16 +0000 (UTC)
Subject: v2_02_159 annotated tag has been created
Message-ID: <20160706001516.C4DE060F9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb619c70699218ca148890f904e53d5f2754f692
Commit:        fb619c70699218ca148890f904e53d5f2754f692
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-07-06 00:00 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-07-06 00:00 +0000

annotated tag: v2_02_159 has been created
	    at fb619c70699218ca148890f904e53d5f2754f692 (tag)
       tagging 6022715c817953e48cfcec127e95f51a0b843ad3 (commit)
      replaces v2_02_158

Release 2.02.159.

This release defines groups to facilitate the aggregation of dm
statistics, introduces a new raid0_meta segment type in preparation for
future conversions between raid types, and improves and fixes parts
of lvconvert and vgsplit.

82 files changed, 6573 insertions(+), 1253 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAld8S1sACgkQIoGRwVZ+LBePEgCeJLLRg6M1YhkoRVrzFgKE+8Ct
EigAoMgyOYxyofmg/rmgCWHbTGjPf/xn
=rfYC
-----END PGP SIGNATURE-----

Alasdair G Kergon (7):
      post-release
      raid: Infrastructure for raid takeover.
      lvconvert: Conversions between striped and raid0.
      macros: Use is_power_of_2.
      raid0: Add raid0_meta segment type.
      vgsplit: Don't skip moving internal snapshot LV.
      pre-release

Bryn M. Reeves (40):
      docs: remove obsolete note from dmstats.8.in
      dmstats: fix RgStart and RgSize field widths
      dmsetup: fix timestamp leak
      libdm: fix histogram pool user-after-free (CWE-825)
      libdm: add dm_bitset_parse_list()
      libdm: rename dm_stats name, devno and uuid members
      libdm: cache dm name in stats handle
      libdm: add enum based counter and metric calls
      libdm: rename 'region' to 'skip_region' in _stats_walk_next
      libdm: add statistics groups
      libdm: use defined constants for buffer sizes
      libdm: add stats group and region iterators and properties
      libdm: allow deleting regions with dm_stats_delete_group()
      dmstats: add group_id report field type
      dmstats: add 'group' and 'ungroup' commands
      dmstats: add group alias support
      dmstats: add stats_name field
      dmstats: do not walk regions if deleting a single id
      dmstats: report groups and region summaries
      dmstats: report a list of members as a group's region_id
      dmstats: allow --statstype to override report defults
      dmstats: accept --groupid for 'dmstats delete'
      dmstats: fix region deletion message
      doc: update dmstats.8.in for groups
      dmstats: convert 'clear' to dm_stats_foreach_region()
      dmstats: convert 'print' to dm_stats_foreach_region()
      dmstats: convert 'delete' to dm_stats_foreach_region()
      dmstats: use 'statsname' and 'groupid' in default fields
      dmstats: rename 'type' field to 'obj_type'
      dmstats: add 'statsname' and 'obj_type' to default stats fields
      dmstats: replace --statstype with separate object switches
      libdm: clarify library's use of aux_data
      dmstats: rename 'aux_data' to 'user_data'
      dmstats: rename --auxdata to --userdata
      libdm: fix <backtrace> in dm_stats_get_nr_regions
      libdm: fix <backtrace> in dm_stats_populate
      dmstats: fix <backtrace> in _display_info_cols()
      doc: document --area, --region, and --group in dmstats.8.in
      libdm: ensure flags constants have ULL suffix
      libdm: cast walk flags to uint64_t when logging.

David Teigland (10):
      lvmlockd: fix coverity report
      WHATS_NEW: add recent changes
      lvmetad: remove unused code for other format types
      lvmetad: two phase vg_update
      lvmetad: two phase vg_remove
      lvconvert: rework routing of operations
      lvconvert: remove unused code
      lvconvert: add missing alias for a thin-pool conversion
      lvconvert: add comments describing conversions
      lvconvert: improve arg checks in new operation routing code

Heinz Mauelshagen (1):
      vgsplit: fix moving RAID LVs to split off VG and check for LVs not to skip moving with other LV types

Peter Rajnoha (4):
      coverity: fix issues detected in recent code
      reporter: simplify --configreport handling for -S|--select and fix an issue reported by coverity
      libdm: report: fix field width calculation when using dm_report_column_headings
      libdm: do not issue 'Failed to create directory' message for failure in dm_create_dir

Tony Asleson (13):
      lvmdbusd: Initial support for json output
      lvmdbusd: Add hidden in for json too
      lvmdbusd: Remove sorting in db layer
      lvmdbusd: Correct command line args for JSON
      lvmdbusd: Correct pv_seg_start -> pvseg_start
      lvmdbusd: request.py, initialize _job to None
      lvmdbusd: Fix hang when lvm compiled with 'enable-notify-dbus'
      lvmdbusd: Remove unused imports and function parameter
      lvmdbusd: Clean up ws
      lvmdbusd: Remove unneeded comment
      lvmdbusd: Remove WARNING for 'lvm help'
      lvmdbusd: Add --nojson command line option
      lvmdbustest: Comment out refresh check for LV create

Zdenek Kabelac (13):
      dmeventd: thin plugin umount over 95%
      thin: fix link validation for unused thin-pool
      cleanup: add extra test for argc==0
      cleanup: drop unused assignments
      cleanup: lvchange uses display_lvname
      cleanup: warns from older gcc
      tests: test foreign users of thin-pool
      dmeventd: improved logged messages from thin plugin
      cleanup: drop unused header files
      tests: try to force remove higher minor first
      tests: add mke2fs.conf
      tests: add line for mixing dmeventd with log
      tests: using  mkfs config file


