From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 21 Jan 2015 13:25:37 +0000 (UTC)
Subject: v2_02_115 annotated tag has been created
Message-ID: <20150121132537.1A03560DAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=972a6f4b1972eb661bbcd6b487b3b250257da67c
Commit:        972a6f4b1972eb661bbcd6b487b3b250257da67c
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-01-21 13:08 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-01-21 13:08 +0000

annotated tag: v2_02_115 has been created
	    at 972a6f4b1972eb661bbcd6b487b3b250257da67c (tag)
       tagging fa01faaa4aa96de834ba7e8fbb9d9aff908571c3 (commit)
      replaces v2_02_114

Release 2.02.115.

67 files changed, 1428 insertions(+), 445 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlS/pRsACgkQIoGRwVZ+LBfA5QCgt3KrilCXnFUQqqEGndew8T/K
f0wAn0K25dCX6HhDqAI5+R621/Zh9QSI
=6l77
-----END PGP SIGNATURE-----

Alasdair G Kergon (10):
      post-release
      mirror: Restrict region size to power of 2.
      mirror: Validate raid region size config setting.
      libdm-report: Fix order of NULL dm_report check.
      man: Remove renamed writebehind field from lvs.8.
      vgimportclone: Say safe to ignore lvmetad message.
      report: Fix warning in _str_list_append.
      libdevmapper: Improve incompatible version msg.
      dmeventd: Reduce waitevent EINTR message severity.
      pre-release

David Teigland (8):
      toollib: process_each_pv should match by device
      toollib: handle duplicate pvs in process_in_pv
      toollib: override the PV device with duplicates
      toollib: pvs -a should display VG name for each duplicate PV
      toollib: search for duplicate PVs only when needed
      WHATS_NEW: previous commits related to duplicate PVs
      vgimportclone: remove arg check that uses pvs
      lvmthin: include errorwhenfull

Heinz Mauelshagen (3):
      raid: fix mirror image naming when converting from mirror to raid1
      raid_manip: fix multi-segment misallocation on 'lvconvert --repair'
      raid_manip: v2 fix multi-segment misallocation on 'lvconvert --repair'

Peter Rajnoha (37):
      pool: fix typo in error message: then -> than
      libdm: remove unimplemented dm_report_set_output_selection fn
      libdm: report: add dm_report_compact_fields
      config: add report/compact_output lvm.conf setting to enable or isable field compacting
      libdm: report: compact output applicable only if report is buffered
      libdm: report: return immediately from dm_report_compact_fields without error if there are no rows
      configure: fix automatic use of configure --enable-udev-systemd-background-jobs
      libdm: report: fix incorrect memory use while using --select with --unbuffered for reporting
      WHATS_NEW: f94f846 actually fixes DM issue, not LVM issue
      vgimportclone: replace awk with dumpconfig to generate temporary lvm.conf for vgimportclone
      vgimportclone: also notify lvmetad about changes if it's used
      man: remove reference to --binary in {pv,vg,lv}display man page
      tools, man: --binary option is available with -C for {pv,vg,lv}display
      man: put back the --binary reference in {pv,vg,lv}display man page
      WHATS_NEW: previous commit
      libdm: report: also check whether field type is supported for field-specific reserved value
      report: dup cache policy name string for report in cache_policy field
      refactor: rename existing helper macros for reserved value handling and add GET_FIELD_RESERVED_VALUE macro
      cleanup: use helper macros to get reserved value from values.h for vg_mda_copies and lv_read_ahead fields
      report: properly set "undefined" reserved value for cache_policy field
      report: fix segfault on NULL value hit in cache_settings field
      libdm: report: add more comments about helper macros to get reserved values
      cmirror: check for cmirror availability during cluster mirror creation and activation
      cmirror: do not check for cmirror availability when creating deactivated cluster mirrors
      mirror: do not try to reactivate inactive mirror when removing its LVs which have missing PVs
      WHATS_NEW: previous commit
      dev_manager: do not mark snapshot origins as unusable devices just because of possible blocked mirror underneath
      WHATS_NEW: line for previous commit
      metadata: log_error instead of log_warn on failed mda write
      metadata: add "Failed to write VG <vg_name>." on failed vg_write and revert previous patch
      scripts: clvmd: replace awk functionality with LVM's selection
      pvscan: notify lvmetad about device that is gone and pvscan is run with device path instead of major:minor pair
      dev-type: filter out partitioned device-mapper devices as unsuitable for use as PVs
      tests: pvscan --cache DevicePath does not fail if the device is just filtered
      report: add separate LVSINFOSTATUS field type for info+status combined fields
      report: rename lv_error_when_full field to lv_when_full and display either "error", "queue" or ""
      cleanup: for commit 7bcb3fb02d6aacc566871326c0d01c331497a5b2

Petr Rockai (4):
      report: Add cache_policy and cache_settings (LV) segment fields.
      lvmetad: Re-use fmt from the VG for PVs when possible.
      pvremove: Avoid metadata re-reads & related error messages.
      dmeventd: Call lvscan --cache also for mirrors (in addition to RAID).

Zdenek Kabelac (19):
      raid: properly rename split image
      cleanup: update API for segment reporting
      cleanup: properly align code lines
      lv_status: track layered device
      lv_status: enable lv_status for thinpool
      cleanup: missed for build without devmapper
      thin: errrorwhenfull support
      WHATS_NEW
      cleanup: add lv_is_error_when_full() macro
      thin: lvchange support for errorwhenfull
      report: reporting unknown status
      report: use same info also for  lv_attr
      report: update report_object API
      report: seg_monitor  undefined
      man: errorwhenfull doc
      cleanup: indent
      report: use info
      thin: support errorwhenfull with thin creation
      report: proper lv_attr_dup emulation


