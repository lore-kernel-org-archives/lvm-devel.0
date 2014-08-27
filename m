From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 27 Aug 2014 22:41:36 +0000 (UTC)
Subject: v2_02_110 annotated tag has been created
Message-ID: <20140827224136.DFBA360F0D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e2df52bb287c2ed9c763efa5b1c78dcdb83d739
Commit:        7e2df52bb287c2ed9c763efa5b1c78dcdb83d739
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2014-08-26 15:34 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2014-08-26 15:34 +0000

annotated tag: v2_02_110 has been created
	    at 7e2df52bb287c2ed9c763efa5b1c78dcdb83d739 (tag)
       tagging 8b8d21f8733d800dd672bcc629b20d8585d2021a (commit)
      replaces v2_02_109

Release 2.02.110.

55 files changed, 1576 insertions(+), 687 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlP8qRwACgkQIoGRwVZ+LBfJlACfVYfCku+bPngyJU+QB69SrV7b
F8oAoPonrJliRJ0HLHFYAeDuUoP+UbGV
=tJaX
-----END PGP SIGNATURE-----

Alasdair G Kergon (8):
      post-release
      pvcreate: Fix cache state with filters/sig wiping.
      libdm: Add DM_DEFERRED_REMOVE to dm-ioctl.h.
      dmsetup: Support remove --deferred.
      lvresize: Fix raid/mirror and %PE handling code.
      configure: Fix shared lvm1 typo.
      autoreconf
      pre-release

David Teigland (1):
      lvcreate: disallow snapshot of cache lv

Jonathan Brassow (2):
      RAID: Fail RAID4/5/6 creation if PE size is less than STRIPE_SIZE_MIN
      cleanup: Remove extra ';' from the end of a line.

Peter Rajnoha (25):
      pvmove: remove spurious "Skipping mirror LV" message on pvmove of clustered mirror
      activation: if LV inactive and non-clustered, do not issue "Cannot deactivate" on -aln
      filter-mpath: fix primary device lookup failure for partition when processing mpath filter
      select: fix string list selection to match whole words only but not prefixes of searched string
      select: add support for selection to match string list subset, recognize { } operator
      tests: update report-select test for latest changes
      refactor: add defines for raid segtypes
      cache+thin: add lv_is_{cache,thin}_origin fn to identify origin LVs
      report: lvs: properly display 'o' for volume type bit and 'C' for target type bit in lv_attr field for cache origin LVs
      WHATS_NEW: previous commit
      Add lv_layout_and_type fn, lv_layout and lv_type reporting fields.
      man: missing (C)ache in target type lv_attr description
      cleanup: gcc warning
      cleanup: gcc warning
      report: fix thin external snapshot identification for lv_layout and lv_type fields
      report: also display "mirror" keyword in lv_type for pvmove LV and display "multiple" for external origin used for more than one thin snapshot
      report: also display "mirror" keyword in lv_layout for mirrored mirror log and "cache" keyword in lv_layout for cached cache pool
      lv: remove lv_type_name fn
      lvconvert: snapshot: allow using raid1 for snapshot and snapshot origin
      man: dmsetup: -n is shortcut for --notable, not --noheadings
      refactor: rename 'lv_type' field to 'lv_role'
      report: add dm_report_field_string_list_unsorted
      report: use dm_report_field_string_list_unordered for reporting lv_layout and lv_role fields
      cleanup: consolidate lv_layout and lv_role reporting
      revert: commit 8d00499167f010b82ea6ddebcc6b22ec170002f9

Zdenek Kabelac (33):
      lvconvert: show name of activated volume
      toollib: print ignoring vorigin
      man: show lv name for lvs
      man: add some more reserved names
      cleanup: postpone confirmation prompt for snapshot
      cleanup: move test for free arg
      cleanup: simplier struct initilization
      cleanup: drop unneeded inits
      cleanup: just easier word wrapping
      cleanup: drop extra braces
      cleanup: quite gcc warn
      cleanup: gcc warn fix
      cleanup: use display_lvname
      dmeventd: fix test for select return value
      metadata: check result of refresh and rescan
      lvscan: check result of id_write_format
      lv_manip: check for str_list_dup failure
      libdm: check version prints error
      cleanup: reindent and make obvious error path
      cleanup: use _ prefix for static functions
      cleanup: use just PATH_MAX size
      cleanup: avoid double assign
      cleanup: simplier struct init
      tests: proper /dev access
      thin: more forced ignoring of pool failure
      thin: fix volume_list support
      libdm: add check transaction_id after message
      cleanup: never return uninitialized buffer
      cleanup: use unsigned 1bit elements
      cleanup: check pv_count is not 0
      cleanup: indent and stacktrack
      tests: fix volume list test
      tests: thin and volume_list testing


