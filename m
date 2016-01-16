From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 16 Jan 2016 02:15:19 +0000 (UTC)
Subject: v2_02_140 annotated tag has been created
Message-ID: <20160116021519.A86CC60092@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b77933b1036c5d96b103eef04ea57558ea418f9f
Commit:        b77933b1036c5d96b103eef04ea57558ea418f9f
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-01-16 02:11 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-01-16 02:11 +0000

annotated tag: v2_02_140 has been created
	    at b77933b1036c5d96b103eef04ea57558ea418f9f (tag)
       tagging 0faa27d4f55abcda5fa94ef92343eb44e95ada89 (commit)
      replaces v2_02_139

Release 2.02.140.

49 files changed, 828 insertions(+), 448 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlaZpt0ACgkQIoGRwVZ+LBcFzACg7Z0algrfyu0ifBFqFlvwAhbt
t14AmgISR9XyLbWcS5PKBKrxQwRw3Er7
=AOPY
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      vgcfgrestore: Retain allocatable PV attribute.
      pre-release

David Teigland (8):
      pvmove: disallow moving PVs under sanlock leases
      man lvmlockd: mention pvmove restriction
      process_each_pv: remove unnecessary workaround
      lvmlockd: fix exit code
      vgchange: fix lockd_gl results
      Revert "process_each_pv: remove unnecessary workaround"
      Revert "lvmcache: skip drop when vg_write lock is not held"
      lvmlockd: fixes for test mode

Ondrej Kozina (4):
      pvscan: restore polling in autoactivation handler
      test: add test for autoactivation regression
      vgchange: drop redundant check
      test: conditional skip of auto-activation bg polling test

Peter Rajnoha (25):
      report: fix invalid memory read when reporting cache LV policy name
      cleanup: use _field_set_value and _string_disp consistently in report.c
      report: use brackets to signify LVs which are not visible when reporting lv_parent
      report: use proper string reference in _string_disp call for _cache_policy_disp fn
      lv: add common lv_convert_lv fn for use in report and dup, use brackets for invisible devices
      lv: add common lv_origin_lv fn for use in report and dup, use brackets for invisible devices
      lv: add common lv_mirror_log_lv for use in report and dup, use brackets for invisible devices
      lv: add common lv_data_lv fn for use in report and dup, use brackets for invisible devices
      lv: add common lv_metadata_lv fn for use in report and dup, use brackets for invisible devices
      lv: add common lv_pool_lv fn for use in report and dup, use brackets for invisible devices
      lv: use brackets for invisible devices when formatting device segments
      conf: add report/mark_invisible_devices
      conf: regenerate
      conf: update command_profile_template.profile.in
      cleanup: cleanup lv.h and put fns into categories for better readability
      tests: update tests to deal with invisible devices consistently
      test: add report-invisible.sh test
      WHATS_NEW: reports and invisible devices
      cleanup: rename 'invisible devices' to 'hidden devices'
      cleanup: rename 'invisible devices' to 'hidden devices'
      conf: fix 'the volume list' vs 'volume list' and '@*'
      cleanup: rename 'invisible devices' to 'hidden devices'
      lv: fix check for NULL origin_lv in _do_lv_origin_dup, cleanup _do_lvconvert_lv_dup
      report: add kernel_discards report field to display thin pool discard used in kernel
      lvm2app: fix lvm2app to return either 0 or 1 for lvm_vg_is_{clustered,exported}

Zdenek Kabelac (11):
      lvmanip: add lv_is_snapshot
      lvresize: check for poolmetadatasize arg earlier
      segtype: check for activation
      snapshot: relocate alloc_snapshot_seg
      cleanup: more readable check
      cleanup: simplier formula
      cleanup: explicit prohibition for virtual segs
      cleanup: replace log_warn
      cleanup: spaces
      cleanup: order ac members
      lvmanip: fix last commit and drop else


