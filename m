From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 30 Oct 2015 15:45:48 +0000 (UTC)
Subject: v2_02_133 annotated tag has been created
Message-ID: <20151030154548.9E13A60F71@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af330ff842aef4d473f7dd9e17eb7a066f373528
Commit:        af330ff842aef4d473f7dd9e17eb7a066f373528
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-10-30 15:35 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-10-30 15:35 +0000

annotated tag: v2_02_133 has been created
	    at af330ff842aef4d473f7dd9e17eb7a066f373528 (tag)
       tagging 15a97cc610712efe818f96b9630b72de89a0cf57 (commit)
      replaces v2_02_132

Release 2.02.133.

This is a development release that provides us with a checkpoint.
(Any interface changes in this release might be modified further.)

329 files changed, 6524 insertions(+), 4152 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlYzj1YACgkQIoGRwVZ+LBc0rwCeI1s7/WqxlO4EDpeVuAfZvk4x
LyEAniwQZ5fUTo+VBx48GfmqvJHUukOb
=M010
-----END PGP SIGNATURE-----

Alasdair G Kergon (15):
      post-release
      segtypes: Use SEG_TYPE_NAME_ string constants.
      segtypes: Make constants ULL.
      style: lv_manip.c changes
      segtypes: Add and use new segtype macros.
      stripes: Introduce _round_to_stripe_boundary.
      alloc: Move _calc_area_multiple.
      test: Cope with stripe rounding message change.
      libdm: Move status fns from deptree to targets.
      raid: Fail if kernel status denominator is zero.
      raid: Add metadata dev information to reports.
      Revert "log: no file for external logging"
      thin: Fix typo in policy threshold message.
      device: Tidy DASD CDL format detection code.
      pre-release

David Teigland (26):
      man lvmthin: use --poolmetadatasize option
      lockd: fix changing lock type on VG with pool
      lockd: fix rescanning VG metadata
      lockd: add debug logging for metadata error
      lockd: add VG name to debug logging
      config: improve cache_settings description
      man lvmcache: updates for mode and policy
      lockd: add error message for EEXIST
      vgcreate: allow both --shared and --lock-type options
      vgcreate: improve error message for multiple lock managers
      man lvmsystemd: fix typo
      man lvmsystemid: fix typos
      Fix segfault when lvmlockd is running but not lvmetad
      lvmlockd: use flag to avoid blocking in sanlock_acquire
      pvscan: use process_each_pv
      libdaemon: allow all debug levels for stderr
      libdaemon: fix typo in last log enable commit
      man: document possible lvmetad -l values
      vg_read: sometimes ignore read errors
      vgextend: fix use of the wrong flag
      vg_read: remove unused inconsistent check
      pvs: fix missing PVs when VG is removed
      toollib: fix wrong paren placement
      vgs, lvs: ignore error if VG is removed
      pvs: don't treat duplicate PVs as missed
      New entries for pvs related fixes.

Heinz Mauelshagen (11):
      segtypes: Extend flags to 64 bits.
      style: Miscellaneous tidying up of metadata/lv*
      libdm: Improve raid segment parameter handling.
      raid: Fix raid target write_behind parameter.
      libdm: fix bogus macro causing false parameter count
      raid: Detect whether or not kernel supports raid0.
      raid: Add a segtype flag for each raid type.
      segtypes: Use flags in raid segtype macros.
      raid: Use loop for text uint32_t parameter import.
      raid: Introduce DEFAULT_RAID_MAX_IMAGES
      raid_manip: fix wrong image size allocation on raid10 "lvconvert --replace ..."

Lidong Zhong (1):
      pvcreate: don't support unpartitioned DASD devices with CDL formatted

Marian Csontos (2):
      test: Fix timeout handling
      cleanup: snapshots of snapshots message

Ondrej Kozina (6):
      polldaemon: fix missing mirror in-sync info with lvmpolld
      tests: add test for missing mirror in-sync info
      lvmetad: add optional timeout option
      lvmetad.8.in: update man page with timeout info
      tests: add lvmetad shutdown on idle test
      tests: replace invalid use of 'fail' with 'die'

Peter Rajnoha (37):
      systemd: use {local,remote}-fs-pre.target instead of {local,remote}-fs.target
      blkdeactivate: recognize and deactivate MD devices too
      report: identify LV hodling sanlock locks as 'private,lockd,sanlock' within lv_role report field
      metadata: format_text: provide more detailed error message when metadata too large for PV mda
      report: add vg_missing_pv_count field
      vgimportclone: cleanup the script and remove dependency on awk, grep, cut and tr
      vgimportclone: fix vgimportclone with -n to not add number unnecessarily to base VG name
      vgimportclone: make sure there's no prefix in VG name list
      tests: test vgimportclone and -n option
      wiping: make libblkid detect all copies of the same signature if use_blkid_wiping=1
      libdm: add dm_report_compact_given_fields
      config: add report/compact_output_cols to control which columns to compact in report output
      cleanup: typo in comment: compact_output_fields should be compact-output_cols
      conf: regenerate
      conf: clarify compact output settings
      pvremove: make sure even invalid info is removed from lvmcache on pvremove
      lvmcache: update cached info properly when moving from VG to orphan while lvmetad is used
      revert: 3d03e504cda6307f692c5879f6850b2e27af7d71: message about VG metadata size vs. PV mda size
      metadata: format_text: check metadata area size is at least MDA_SIZE_MIN
      metadata: format_text: check VG metadata do not overlap themselves
      WHATS_NEW: recent commits
      metadata: format_text: better check for metadata overlap
      tests: add test for minimum mda size
      metadata: format_text: also count with calculated mda size of 0
      str_list: also allow memory allocation without memory pool
      str_list: add str_list_to_str and str_to_str_list functions
      str_list: add str_list_destroy function
      refactor: move code detecting report options to a separate function
      report: make report options defined by "-o" groupable
      report: support "-o -field_name1,field_name2,...."
      report: add report_get_field_prefix function
      report: recognize known prefix when processing "-o -field_name1,field_name2,..."
      report: support "-o #field_name1,field_name2,..."
      tests: add report-fields.sh test
      man: pvs/vgs/lvs and -o+, -o-, -o#
      commands: update command help for -o|--options for reporting commands
      WHATS_NEW: reporting commands and -o-/-o+ extension

Zdenek Kabelac (118):
      alloc: fix update or area_len
      man: update dmsetup and dmstats pages
      man: update lvm pages
      tests: use proper target name for check
      tests: ensure test will not block
      cleanup: fix compiler warning
      man: fsadm
      man: lvcreate continue
      tests: check devices with prefix aren't in use
      libdm: enforce writethrough mode for cleaner
      thin: check for overflown pool earlier
      dmeventd: correct ret code for fail
      thin: enhance logging
      toolcontext: do not change already set dm_log
      log: no file for external logging
      dmeventd: fix loging report
      dmeventd: log all commands with CMD: prefix
      libdmevent: add dm_event_log
      dmeventd: syslog -> log_xxxxx
      dmeventd: use log_ macros in plugins
      dmeventd: enable new logging
      dmeventd: enable new logging
      dmeventd: drop changing logging
      dmeventd: add more debug messages
      man: dmeventd update
      dmeventd: handle snapshot overflow
      cleanup: static with _
      dmeventd: support logging on stdout
      cleanup: more readable code
      cleanup: always set nsec
      cleanup: remove multilog
      cleanup: avoid using private
      cleanup: move system defines before structs
      cleanup: typo in comment
      dmeventd: new initialization of plugin threads
      dmeventd: introduce macro for init
      dmeventd: use new macros to init mempool
      dmeventd: add local mempool for raid and mirror
      dmeventd: less locking for snapshot and thin
      dmeventd: less locking mirror
      dmeventd: rework raid plugin
      makefiles: generate Local
      makefiles: drop explicit linking
      makefiles: src dirs have depth 5
      tests: show status in in_sync
      tests: better regex check
      tests: start logging dmeventd output
      tests: wait for initial sync
      tests: more extend testing
      dmeventd: compilable without DEBUG CFLAG
      makefiles: older gcc needs hint with rpath
      dmeventd: fix missing '!'
      makefiles: switch to rpath-link
      thin: enforce local activation when creation new thin
      dmeventd: use matching function
      lib: better reporting of threshold
      memlock: report memlock daemon counter
      tools: preselect some setting for memlocked daemons
      tools: do not change signals for memlocked daemons
      libdm: add dm_hold_control_dev
      dmeventd: check for malloc return
      dmeventd: lvm2 plugin correctly debug
      dmeventd: raid plugin reporting
      dmeventd: mirror plugin update
      dmeventd: snapshot plugin updates
      dmeventd: snapshot plugin device removal
      dmeventd: thin plugin update
      dmeventd: no registering of 0 event mask
      dmeventd: using warning level
      dmeventd: move dso handling into single code section
      dmeventd: use dm_hold_control_dev
      dmeventd: wake up timer when setting new timeout
      dmeventd: drop unneded test
      dmeventd: minimize locking time for get_imeout
      dmeventd: code mode _get_device_status
      cleanup: use enums
      dmeventd: rework locking code
      dmeventd: handle signal from plugin
      dmeventd: snapshot plugin unmonitor
      dmeventd: debug signals
      dmeventd: exit on idle
      cleanup: declare vars before code
      cleanup: easier to read code
      cleanup: drop uneeded header file
      cleanup: indents
      tests: enable raid test on 4.3
      dmeventd: debug error paths
      dmeventd: ensure filter is empty
      tools: update for lvm2_disable_dmeventd_monitoring
      cleanup: gcc warning for old-style
      cleanup: fix gcc compile with older pthread
      cleanup: drop debug
      thin: fix percentage compare
      lv_manip: ensure it will fit bellow threshold
      libdm: dm_tree_node_size_changed recognizes reduction
      dev_manager: enabled no_flush for suspend
      dev_manager: no flush for extension
      libdm: enable no_flush for driver version > 11
      tests: snapshot now respects threshold
      dmevent: fix referencing
      thin: limit  no-flush using only for thin-pool
      tests: extend timer for 4 hours
      tests: support skip flags
      tests: use skip flags
      dmeventd: event string parser handles empty field
      tests: avoid reading utils when skipping
      tests: use more SKIP
      tests: using matching type
      thin: dmeventd plugin check number of failures
      thin: enable usage of kernel low_water_mark
      cleanup: easier error messages
      cleanup: use same type
      cleanup: remove thin low_water_mark from metadata
      cleanup: error is not a WARNING
      tests: no point in using should
      tests: fix wrong line has been commented
      tests: let pass bigger readahead
      tests: update test for resize


