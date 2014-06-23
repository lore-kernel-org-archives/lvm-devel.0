From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Jun 2014 14:55:09 +0000 (UTC)
Subject: v2_02_107 annotated tag has been created
Message-ID: <20140623145509.51C646119B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3cfd48c0960f99eca3cd6b667c5b2980882a376b
Commit:        3cfd48c0960f99eca3cd6b667c5b2980882a376b
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2014-06-23 13:51 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2014-06-23 13:51 +0000

annotated tag: v2_02_107 has been created
	    at 3cfd48c0960f99eca3cd6b667c5b2980882a376b (tag)
       tagging 0bb6ffb81fac3b51fb7986aa29b84687499a1c78 (commit)
      replaces v2_02_106

Release 2.02.107.

430 files changed, 9745 insertions(+), 4434 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlOoMQEACgkQIoGRwVZ+LBeAngCePncRfLAS+058cy4pKZ4z11iS
CisAnjlEe5sS8yGBry1qP2c5IocoN7nO
=U2OG
-----END PGP SIGNATURE-----

Alasdair G Kergon (25):
      post-release
      alloc: Refactor area reservation code.
      alloc: Access alloc_parms from alloc_state.
      alloc: Introduce A_POSITIONAL_FILL.
      alloc: Correct existing use of positional fill.
      pvscan: Use lvmetad_used().
      reports: Use X for unknown LV attr when no dm.
      metadata: Fix unlock on VG recovery error path.
      tools: Add --readonly support.
      test: Fix default.profile path.
      test: configurable write timeout
      pvremove: Catch CTRL-c during prompts.
      locking: Separate out flock and signal code.
      signals: Move sigint handling out to lvm-signal.
      signals: Add init_signals.
      man: Fix man7 dir dependency.
      allocation: Fix alloc anywhere with parity.
      report: Add metadata_percent to lvs_cols.
      pvmove: tidy
      pvvmove: add a few comments
      locking: Introduce LCK_ACTIVATION.
      locking: fix cluster locking
      man: More /dev/vg and /dev/mapper documentation.
      pre-release
      pre-release

David Teigland (3):
      man: more lvmthin discard references
      man: lvmthin cover snapshot merge and xfs
      man: lvmthin

Dongmao Zhang (1):
      systemd: use umask 022 for generated systemd units by lvm2-activation-generator

Jonathan Brassow (18):
      vgsplit: Make vgsplit work on mirrors with leg and log on same PV
      WHATS_NEW: Add message for commit 9ac858f
      test/vgsplit-operation.sh: Add vgsplit tests for RAID
      vgsplit: Make RAID 4/5/6 fail cleanly when too few PV specified
      test:  Move the RAID vgsplit test into a separate file
      test: Add the new vgsplit RAID test file forgotten in the last commit
      logging: Add LCK_REVERT_MODE to flags printed by decode_flags()
      activation:  Remove empty DM device when table fails to load.
      test: use direct I/O when injecting bad data into RAID images
      vgchange: Prompt when setting VG cluster attr if cluster is not setup
      WHATS_NEW:  For commit 9399b743 (prompt for VG cluster attr change)
      vgchange:  With '--yes', don't prompt the user
      cache: Properly rename origin LV tree when adding "_corig"
      poll_daemon:  Cleanly exit polling if the LV is no longer active
      pvmove: Enable all-or-nothing (atomic) pvmoves
      test: Clean-up pvmove-basic for atomic pvmove test
      pvmove: Clean-up iterator.
      pvmove: Fix code that looks up the "move pv" for display

Marian Csontos (1):
      test: add lvresize tests

Peter Rajnoha (79):
      profiles: comment out thin_pool_chunk_size in default.profile
      lvmdump: add -s to gather system info and context (currently systemd-related only)
      lvmdump: list also inactive units for lvmdump -s
      configure: use configure's --enable-udev-systemd-background-jobs by default
      man: minor fixes in lvmetad man page
      config: use devices/ignore_suspended_devices=0 by default
      libdevmapper: add dm_units_to_factor for size unit parsing
      cleanup: _move_pv is static
      systemd: make sysinit.target to pull in lvm2-lvmetad.socket, not sockets.target
      systemd: use lvm binary insetad of command symlink in lvm2-pvscan.service
      cleanup: fix compiler warning
      make: fix commit 1756bf6
      report: export DM_REPORT_FIELD_RESERVED_NAME_{HELP,HELP_ALT} and show help on '<lvm_command> -O help'
      config: add CONFIG_FILE_SPECIAL config source id
      config: attach cft_check_handle to each config tree instead of global cmd_context
      config: fix incorrect profile initialization on cmd context refresh
      dumpconfig: fix dumpconfig --type diff used in lvm shell as second and later command
      commands: do not register profile_ARG for lvcreate/lvchange separetely
      config: add CFG_PROFILABLE_METADATA flag
      config: differentiate command and metadata profiles and consolidate profile handling code
      dumpconfig: add --type profilable-command/profilable-metadata, --metadataprofile/--commandprofile
      tests: update profiles.sh test for latest changes
      systemd: install lvm2-cluster-activation script as executable
      cleanup: remove duplicate --commandprofile reference in dumpconfig's help string
      man: update dumpconfig man page for latest changes
      profiles: remove default.profile and add {command,metadata}_profile_template.profile
      man: update lvm.conf man page for latest changes
      man: more man page updates for --commandprofile and --metadataprofile split
      man: missing space between option name and value name
      lvm_init: don't use name mangling for LVM
      cleanup: use const for endptr in dm_units_to_factor
      udev: also print subsystem udev flags in debug message about udev flags + fix typo DM_SUBSSYTEM_UDEV_FLAG7 -> DM_SUBSYSTEM_UDEV_FLAG7
      report: fix report field type for lv_kernel_major/minor
      cleanup: commit c0f9c79 to work also with for non-clustered configuration
      cleanup: default.profile is not used (and it was split in two and renamed anyway)
      cleanup: move the "daemon is running" checks to lvm-wrappers
      tests: some more renames lib/test -> lib/inittest
      profile: add thin-generic.profile
      spec: new thin-generic.profile
      systemd: use RemoveOnStop for dm-event.socket and lvm2-lvmetad.socket
      report: select: add DM_REPORT_FIELD_TYPE_SIZE to make a difference between NUMBER and SIZE
      report: select: add structs for report selection
      report: select: add supporting infrastucture for token parsing in report selections
      report: select: add dm_report_init_with_selection to libdm
      report: select: add _check_selection fn to support checking fields against given selections
      report: select: use _check_report_selection in dm_report_object to report only objects that satisfy the report selection
      report: select: add --select arg to dmsetup
      report: select: add --select arg to pvs, vgs and lvs
      report: select: add --select arg to pvdisplay, vgdisplay and lvdisplay
      report: select: refactor: move str_list to libdm
      report: select: add dm_report_field_string_list to libdm
      report: select: add DM_REPORT_FIELD_TYPE_STRING_LIST to make a difference between STRING and STRING_LIST
      report: select: add support for processing string lists in selection
      report: select: add support for comparing string lists with selection defined
      report: select: add help for creating selections
      report: select: show field type in field list if in context of selection
      report: select: add support for reserved value recognition in report selection string - add struct dm_report_reserved_value
      report: select: refactor: move percent handling code to libdm for reuse
      report: select: add support for percent selection
      tests: select: add test for report selection feature
      report: add support for implicit fields, add implicit "selected" field
      report: select: add --select arg to lvm devtypes
      report: select: add man pages for report selection feature
      prop: update FIELD macro to accomodate the differentiation of number, size and percent field values
      tests: update lvcreate-thin for latest changes
      test: fix report_select test to work in cluster
      WHATS_NEW: commits 7dbbc05a69c4cb9756464720cad29e3c1ed971c3..b16f5633ab199dedfd25f08562f686a6fb4aba9d
      WHATS_NEW: commit 76467bdcfd297ffbe2c088b6340ecc7d17d56742
      cleanup: gcc warnings and report-select test vs snap_percent 0%
      man: add man page entry for dmsetup info -c -S/--select + minor cleanups
      compilation: fix warnings: build_dm_uuid now accepts whole struct logical_volume, not lvid
      select: add list of allowed types for each selection operator mentioned in help
      report: make "help" and "?" field implicit
      libdevmapper: revoke commit 7c86131233011c9fb81190bcb40d5d4ac54a533d
      report: display explicit fields first, then implicit fields in field help
      dmsetup: no need to check for "help" field name after report init
      select: add FLD_UNCOMPARABLE flag for fields which can't be compared
      select: also mark uncomparable/unselectable fields in field/selection help
      select: add message about 'help' field to get more help on each error hit during selection parsing

Petr Rockai (13):
      NIX: Fix failure mode for "make check".
      NIX: Use VM images with the correct root module list.
      metadata: Make it possible to write partial VGs obtained from lvmetad.
      test: Make it possible to enable/disable devices silently.
      test: Fail devices silently in lvconvert-repair-transient.sh.
      test: Fix the vgck test after vg_write change.
      lvm1: Fail vg_write graciously when devices are missing.
      test: Try harder to vgremove in lvmetad-lvm1.sh.
      lvmetad: Avoid "connect failed" spamming when lvmetad is not available.
      pvremove: Update lvmcache => avoid spurious error messages.
      test: Reflect that --sysinit only treats lvmetad specially with -aay (not -ay).
      libdaemon: Keep track of client threads, wait before shutdown.
      lvmetad: Drop active connection upon lvmetad_set_active(0).

Zdenek Kabelac (197):
      polldaemon: ret invalid cmd for negative interval
      pvmove: remove locked flag from error pvmove0
      memlock: ignore more libraries
      clvmd: fix test mode race
      clvmd: move mutex init and detroy
      clvmd: set finished flag with mutex
      clvmd: drop reply_mutex
      clvmd: improve mutex usage in request_timed_out
      clvmd: skip adding reply when finished
      clvmd: use thread-safe ctime_r when debugging
      cleanup: clvmd reindent local_pipe_callback
      cleanup: clvmd drop unused enum state
      cleanup: corrent indent level
      tests: implement lv_attr_bit
      tests: check there is really pvmove lv
      tests: correct test condition
      unknown: fix mempool used for name allocation
      thin: dmeventd plugins support more minors
      asprintf: fix test for error result
      dmeventd: check for list size within lock
      devmapper-event: always initialize timeout
      makefiles: wait till include is populated
      makefiles: clear targets in with make clean
      makefiles: compile files on make
      makefiles: drop linking of deamon libs to plugins
      makefiles: move subdir into same section
      libdaemon: header cleanup
      cleanup: include stdarg.h where needed.
      cleanup: reduce inclusion of unnecessary headers
      cleanup: drop inclusion of devmap - merge
      cleanup: set _REENTRANT in header
      cleanup: skip zeroing of cleared areas
      cleanup: add some comment indents...
      cleanup: dmeventd abstract lvm2cmd interface
      cleanup: dmeventd reorder _fill_device_data
      cleanup: dmeventd simplify status processing
      cleanup: dmeventd simplify buffer write loop
      cleanup: dmeventd improve _get_status
      cleanup: dmeventd set next_time when registering
      cleanup: dmeventd improve _clien_write code
      cleanup: dmeventd improve _handle_request
      cleanup: dmeventd drop setting of size
      cleanup: dmeventd simplify restart message parsing
      tests: fix creation of scsi debug
      display: use Virtual for virtual LV
      display: show monitoring status
      thin: display info when -tpool is running
      thin: move segment info display to correct code section
      lvscan: drop test for snapshosts
      cleanup: put all tests within switch
      tests: improve coverage
      display: check for dmeventd support
      configure: corrected ioctl option
      libdm: cleanup complation without DM_IOCTLS
      devmapper: fix compilation without devmapper
      devmapper-event: always initialize timeout
      lv: show X attr when lv_info fails
      makefile: fix regression
      unknown: add_target_line is not needed
      cleanup: indent in devmapper-event
      cleanup: indent
      cleanup: modules_needed only for devmapper
      tests: lets the test continue
      locking: use sigaction signal handling
      debug: add more debug message for signal handling
      signals: better nesting support
      cache: avoid expression overflow
      coverity: check for profile
      coverity: error for undefined origin
      coverity: ignore ret val
      cleanup: drop uneeded headers
      cleanup: cosmetics.
      cleanup: missed conversion to dm_malloc/free usage
      clenaup: drop unused assigns
      cleanup: constify pointers
      cleanup: use enum return codes
      configure: drop siginterrupt
      configure: improve needs_check thin_check test
      coverity: catch unwanted path
      conf: document new thin_check option
      cleanup: cast int to typedef
      cleanup: drop unused header
      tests: replance hostname call
      tests: updates
      cleanup: improve error message
      man:misc updates
      tests: speedup
      display: print skipped prompt
      man: lvmcache
      debug: backtrace error path
      cleanup: device extent_size first
      man: lvmcache
      tests: drop nosync
      thin: lvconvert warn before conversion
      lvconvert: check ret code of mirror_remove_missing
      debug: fix backtracing
      man: cleanup style
      cleanup: unneeded initialization
      cleanup: indent
      cleanup: use print when displaying info
      thin: improve lvconvert messages
      tests: update lvconvert test
      tests: wait before down-convert
      tests: add have_cache and have_raid
      tests: rebuild paths when Makefile is updated
      spec: configurable cache build
      tests: lvconvert needs --yes
      tests: checking mirror_remove_missing
      man: call installers only when there are set vars.
      tests: notify lvmetad after udev transation
      tests: notify loop needs maj:min
      tests: skips on unsupported systems
      tests: restore disable_dev behavior
      vgcfgrestore: return invalid cmd line
      cleanup: indent
      cleanup: make error message more readable
      tests: more vgcfgrestore testing
      tests: more pvchange tests
      tests: raid and dmeventd
      cleanup: use y/n instead of y|n
      tests: detect raid presence
      tests: add check vg_attr_bit
      tests: swap tests
      tests: check more things with vgchange
      dev_manager: disable extra udev loop
      cleanup: add seg_is_pool macro
      cleanup: use directly segtype->name
      cleanup: indent
      vgextend: allow --yes to skip prompt
      tests: increase min version for raid testing
      tests: add unusable kernel for raid5 testing
      tests: improve command coverage
      dmsetup: add warning
      man: cleanup dmsetup
      cleanup: internal error for impossible path
      tests: update aux disable_dev
      tests: support thin_restore configurable
      activate: cleanup lv_check_not_in_use
      raid: cleanup error messages
      tests: detect same uuid on PV
      tests: raid syncaction activation race
      tests: dd needs to hit disk
      revert: restore original timeout
      tests: rename test
      man: document DM_DEFAULT_NAME_MANGLING_MODE
      configure: accept 'none' as mangling mode
      configure: cleanups
      configure: reconfigure
      tests: fix use of double apostrophes in get
      tests: use shell arrays to keep device names
      tests: add get_devs function
      tests: use manglename none for dmsetup
      tests: use get_devs
      tests: typo
      configure: do not exit with error code
      tests: adapt test for newline delimit
      tests: fix test compare
      tests: disable python failing test
      configure: update libcpg test
      activation: retry cleanup deactivation
      cleanup: drop inline keyword
      cleanup: add missing log_error
      tests: make timeouts longer
      tests: rename test to inittest
      man: advertise  lvmcache, lvmthin
      man: use bullets
      man: properly escape -
      man: more compliant
      man: update lvmthin
      man: kiB uppercase
      man: dmsetup manglename
      tests: update vgchange -c
      tests: change to inittest
      report: avoid passing NULL label
      libdm: dm_report_object avoid duplicat strlen call
      libdm: dm_report_object report error for no data
      test: pvs bz1108394
      snapshot: check it's still snapshot
      snapshot: check snapshot exists
      snapshot: do not spawn when origin is not active
      snapshot: report proper error message
      snapshot: %ORIGIN is relative to data size
      cleanup: use stack for small buffer
      cleanup: we already know max device name size
      tests: wait for udev
      tests: detect version of thin_restore command
      tests: check new snapshot skills
      lvconvert: print warning when not convert thinpool
      cleanup: use insert_layer_for_lv implicit rename
      lvchange: better --refresh of raid and mirrors
      cleanup: more readable
      cleanup: rename variable wait
      tests: remove dmeventd usage
      memlock: skip more entries
      cleanup: use simplier test
      tests: add udev sync point
      lv: fix lv_is_raid


