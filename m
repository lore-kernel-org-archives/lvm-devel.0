From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 15 Jul 2016 21:03:09 +0000 (UTC)
Subject: v2_02_161 annotated tag has been created
Message-ID: <20160715210309.3396960664@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e9b53f261310aa6481eb84f18017a31cc47dbdfe
Commit:        e9b53f261310aa6481eb84f18017a31cc47dbdfe
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-07-15 20:57 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-07-15 20:57 +0000

annotated tag: v2_02_161 has been created
	    at e9b53f261310aa6481eb84f18017a31cc47dbdfe (tag)
       tagging 3d717b52c144699ec1ad096f71088b455cd87faf (commit)
      replaces v2_02_160

Release 2.02.161.

dmstats extensions for monitoring I/O to individual files, together
with an assortment of bug fixes mostly related to the recently-added
raid0 code.

47 files changed, 2433 insertions(+), 928 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAleJTrcACgkQIoGRwVZ+LBdSzACg907pJ7rt2/U9FHyi9mrYSYpA
a2oAoOStGScOABpUBPhTLGN8v0j5qCmY
=cdtZ
-----END PGP SIGNATURE-----

Alasdair G Kergon (5):
      post-release
      macros: Add lv_is_not_synced.
      string: Add first_substring().
      Revert "lvcreate: raid0 needs default number of stripes"
      pre-release

Bryn M. Reeves (26):
      libdm: enclose dm_stats_walk_do/while() body in do..while
      libdm: fix resource leak in dm_stats_set_alias()
      libdm: improve comments in stats grouping functions
      dmstats: ensure dm_stats_delete_region() return is checked
      libdm: fix group resource leak in dm_stats_delete_region()
      libdm: add dm_stats_create_regions_from_fd()
      dmstats: add create --filemap
      doc: update dmstats.8.in for --filemap and --nogroup
      libdm: add aggregation support to dm_stats_get_histogram()
      libdm: allow regions with histograms in dm_stats_create_group()
      doc: mention group histogram restrictions in dmstats.8.in
      libdm: enable creation of filemap regions with histograms
      dmstats: allow --bounds with 'create --filemap'
      WHATS_NEW_DM: add --filemap and histogram aggregation
      dmstats: group regions by default with --segments
      doc: mention --segments grouping in dmstats.8.in
      WHATS_NEW_DM: add --segments grouping and resource leak fix
      doc: remove obsolete --statstype references from dmstats.8.in
      dmstats: use canonical path when reporting errors
      libdm: use SECTOR_SHIFT constant in _stats_add_extent()
      libdm: use a constant for FIEMAP buffer size
      dmstats: accept multiple arguments to --filemap
      doc: update --filemap usage in dmstats.8.in
      libdm: use macro for boundary test in _stats_get_extents_for_file()
      libdm: use 'goto_bad' if extent pool allocation fails
      libdm: add configure.in checks for fiemap.h and magic.h

David Teigland (15):
      man: clarify lvcreate size in extents
      vgcreate: allow pvcreate force option
      lvconvert: allow converting type mirror to type linear
      lvconvert: allow converting type raid1 to type linear
      man: more rewording for lvcreate size
      man: rewrite lvconvert
      man: more lvcreate size rewording
      lvconvert: don't show aliases in error output
      lvconvert: allow splitcache on hidden/used cache pool
      man: lvconvert changes
      man: lvconvert changes
      lvconvert: remove some FIXME comments
      Revert "man: restore lost synopsis for lvconvert"
      man: changes to lvconvert
      man: drop lvmraid references from lvconvert

Heinz Mauelshagen (7):
      man: enhance lvconvert
      vgsplit: temporary list pointer may be invalid
      vgsplit: use dm_list_next()
      lvchange: resync attempts on raid0 cause segfaults
      raid_manip: 'vgreduce --removemissing --force ...' segfaults on raid0 LV
      lv_manip: extension of raid0 causes livelock
      lvcreate: raid0 needs default number of stripes

Peter Rajnoha (3):
      blkdeactivate: add -m|--mpathoption disablequeueing and use it for blk-availability systemd service and initscript
      man: lvcreate: try to be clearer about -W|--wipesignatures
      lvmdump: include major and minor numbers for pvs and lvs reports

Zdenek Kabelac (20):
      tests: add LVM_LOG_FILE_MAX_LINES
      tests: increase max lines for clvmd
      tests: reduce amount of pvcreates
      tests: skip some tests for older cache driver
      cleanup: gcc warns removal
      cleanup: lvconvert  display_lvname and indent updates
      man: restore lost synopsis for lvconvert
      tests: cache error message changes too often
      tests: remove more test
      lvresize: fix zero size extension
      cleanup: add some dots to messages
      tests: resize of filesystem
      tests: skip more cache tests for older driver
      coverity: easier to follow set-up of vsn variable
      coverity: cleaning some PW.NOT_COMPATIBLE_WITH_PREVIOUS_DECL
      coverity: add some tests for function results
      tests: require better cache driver
      tests: check fail path on cache creation
      coverity: close socket before closing app
      cleanup: local static functions with _


