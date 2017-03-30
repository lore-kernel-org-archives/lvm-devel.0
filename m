From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 30 Mar 2017 15:55:38 -0400
Subject: v2_02_169 annotated tag has been created
Message-ID: <201703301955.v2UJtcuB006556@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=60043ae1e3ae51523c4dfeb6ba244cfaefc98d45
Commit:        60043ae1e3ae51523c4dfeb6ba244cfaefc98d45
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2017-03-28 15:12 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2017-03-28 15:12 +0000

annotated tag: v2_02_169 has been created
	    at 60043ae1e3ae51523c4dfeb6ba244cfaefc98d45 (tag)
       tagging 396377bc03a9f8a13f5d851306f7d2a622a1a74e (commit)
      replaces v2_02_168

Release 2.02.169

This development release contains a substantial amount of change and we
recommend you use it only for testing at this stage.  Please wait for
follow-on releases before running it on live systems.

The syntax of every valid command has been encoded into the same format.
Given the large number of combinations, mistakes are possible, so please
check any of the more unusual commands that you use and let us know if you
discover a command that no longer behaves the way you expected.

Most man pages are now generated in part from these new definitions and
command help information has similarly changed completely.  This content
is still undergoing review and refinement.

The code also supports the new dm-cache metadata format 2 that improves
the performance and adaptation to workload changes, and the raid code
also supports several new formats and conversions.

446 files changed, 60538 insertions(+), 25701 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAljafXgACgkQIoGRwVZ+LBd8MQCfctT8HTr9eYSYzWbInbHJZvK0
CPsAn1La2ZKFFfvQOfLFL0zTcnIvA6ab
=igsB
-----END PGP SIGNATURE-----

Alasdair G Kergon (28):
      post-release
      devices: Recognise Veritas Dynamic Multipathing
      Makefile: all_man also requires man-generator now
      dmsetup: Indicate device repetition in usage summaries.
      git: Upstream repository moved to sourceware.org
      tools: Fix overriding of current_settings.
      man: Revise internal man page generation process.
      man: Adjust some wording and update examples style.
      make: Support for 'make -R'.
      man: specify man-generator path
      man: reinstate lvmchange man page for now
      man: Remove blank lines from pregenerated files
      lvmchange: Move to a built-in command.
      lvmsar/lvmsadc: Mention dmstats when run.
      man: Reinstate previous lvmsar and lvmsadc pages.
      man: Include lvmchange/lvmsar/lvmsadc content in lvm.8
      tools: Drop unused e2fsadm refs (replaced by fsadm).
      tools: Avoid man-generator compilation warnings.
      make.tmpl: Support per-object DEFS.
      man: Preserve template variables in pre-generated pages.
      man: Build man-generator in tools dir.
      man-generator: Remove unused variable.
      lvcreate: continue to accept --thinpool with -L and -V but not -T
      tools: Show configuration command line in lvm version.
      tools: Reinstate lvm script processing.
      make: Don't hard-code SHELL as /bin/sh
      man: pre-generated files weren't committed
      pre-release

Bryn M. Reeves (66):
      libdm-stats: fix dm_stats_delete_region() performance
      libdm-stats: clear dms->regions in _stats_regions_destroy()
      libdm-stats: clear dms->groups in _stats_groups_destroy()
      libdm: use correct region_id when cleaning up a failed filemap
      libdm: split off internal _stats_delete_region()
      libdm: fix performance of failed filemap cleanup
      doc: add filemap creation fixes to WHATS_NEW_DM
      libdm: use a private pool for filemap extent table
      libdm: fix filemap cleanup loop condition
      scripts: add lvmdump.sh to .gitignore
      scripts: add systemd unit files to .gitignore
      lvmdbusd: add path.py to .gitignore
      test: add results/ to .gitignore
      libdm: fix _stats_get_extents_for_file()
      libdm: fix region overlap tests
      libdm: fix segfault with invalid group descriptor
      libdm: check for non-existent region_id values in groups
      libdm: fix dm_stats_foreach_group() macro
      libdm: break up _stats_get_extents_for_file()
      libdm: fix start of file detection in _stats_map_extents()
      configure: check for __builtin_clz()
      util: add clz() and use __builtin_clz() if available
      libdm: add dm_bit_get_last()/dm_bit_get_prev()
      libdm: use dm_bit_get_last() in _stats_group_tag_fill()
      libdm: add min_num_bits to dm_bitset_parse_list()
      libdm: ensure first extent is always counted
      libdm: use destination size as limit in dm_bit_copy()
      man: fix 'dmstats <command>' formatting in dmstats.8.in
      man: fix 'dmstats list' option formatting in dmstats.8.in
      man: fix 'dmstats create' formatting in dmstats.8.in
      dmstats: improve tool help output and option coverage
      dmstats: use better interval estimate for usleep() timer
      dmstats: separate TIMERFD and useleep() exit conditions
      dmstats: fix interval number reporting with --count=0
      dmstats: fix TIMERFD _timer_running() test
      dmstats: don't declare _start_timestamp if HAVE_SYS_TIMERFD_H
      libdm: clear region table in dm_stats_list()
      libdm: add dm_stats_bind_from_fd()
      man: fix name of 'write_time' field in dmstats.8.in
      libdm: fix stats comment formatting in libdevmapper.h
      libdm: test for DM_STATS_GROUP_NOT_PRESENT in _stats_group_id_present
      libdm: add dm_stats_update_regions_from_fd()
      dmstats: allow --filemap groups to be updated
      man: add update_filemap to dmstats.8.in
      man: mention dmstats in lvmsar and lvmsadc man pages
      libdm: remove unnecessary backtrace in _stats_group_id_present()
      daemons: add dmfilemapd
      man: add dmfilemapd.8
      dmstats: start dmfilemapd when creating or updating file maps
      man: add dmfilemapd options to dmstats.8.in
      man: add FILE MAPPING section to dmstats.8.in
      configure: make --enable-dmfilemapd require fiemap.h
      libdm: don't nest FIEMAP and DMFILEMAPD ifdefs
      dmfilemapd: always set the program_id after listing regions
      libdm: move initialisation of group_id in _aggregate_histogram()
      dmsetup: always initialise 'mode' in filemap create functions
      tools: add generated headers to .gitignore
      man: add man-generator and build artefacts to .gitignore
      libdm: dm_stats_start_filemapd() mode can never be < 0
      libdm: make dm_stats_destroy(NULL) a no-op
      dmsetup: always initialise 'dms' in _stats_update_file()
      libdm: use correct value for NR_FILEMAPD_ARGS
      daemons: cleanup dmeventd references from dmfilemapd/Makefile.in
      daemons: use DEFAULT_PROC_DIR in dmfilemapd
      dmfilemapd: return error for wrong number of args
      dmfilemapd: ensure path argument is absolute

Christian Brauner (1):
      lvmetad: fix segfault on i386

David Teigland (150):
      lvmetad: fix segfault in daemon_reply_simple
      lvmlockd: test mode doesn't work
      commands: new method for defining commands
      process_each_lv: add check_single_lv function
      lvchange: make use of command definitions
      lvconvert: repair and replace: use command definitions
      lvconvert: remove unused calls for repair and replace
      lvconvert: snapshot: use command definitions
      lvconvert: add startpoll command using command def
      lvconvert: use command defs for thin/cache/pool creation
      toollib: find VG name in option values when needed
      lvconvert: use command defs for mergemirrors
      tests: use swapmetadata
      lvconvert: use command defs for raid/mirror types
      lvconvert: remove unused code
      args: use uint32 arg for maxphysicalvolumes
      args: add man page descriptions
      man lvm: remove options
      fix lvmcmdline warning
      help: accept positional args
      lvm shell: clear argv for each command
      command.h comment tidying
      command struct: remove command name refs
      ccmd: split into multiple files
      man: lvmthin updates
      args: split is a synonym for splitcache
      lvconvert: remove unused code
      commands: move command def parsing into lvm binary
      commands: recognize raid variations
      vgchange: fix uint32 parsing of logicalvolume arg
      lvconvert: add command to change region size of a raid LV
      lvconvert: remove code for changing region size
      args: use arg parsing function for region size
      generate man pages
      commands: suggest --help if command doesn't match
      lvconvert: enable previous syntax to swap metadata
      WHATS_NEW: items from command definitions patch set
      WHATS_NEW: changes for recent command defs
      coverity cleanups for recent command defs commits
      commands: improve help/usage output
      commands: skip parsing command defs for other command names
      man/help: use separator in units list
      man-generator: fix compiler warnings
      coverity cleanups
      Revert "lvconvert: enable previous syntax to swap metadata"
      lvcreate: LVM_VG_NAME applies even without name arg
      lvconvert: handle old arg quirk when combining snapshot
      toollib: skip dev prefix from lv names
      lvcreate: fix LVM_VG_NAME detection
      commands: use existing vg/lv name parsing functions
      commands: use dm wrappers for malloc/free
      help/man: remove commas from list of options
      commands: avoid factoring options until needed
      commands: initialize commands[] once
      commands: track errors in command def parsing
      lvconvert: include swap behavior in generic pool syntax
      args: in yes option mention qq for auto-no
      man/help: show recently added r|R unit
      man lvmconfig: refer to typeconfig option name
      man: mention force behavior in various places
      man pvmove: move details to notes
      man: print space before built-in name
      man/help: fix description of r|R unit
      lvresize/lvextend: accept type option
      man: add variables descriptions
      man lvcreate: add special option notes@the start
      man vgchange/lvchange: note special option usage
      man/help: print general raid type as "raid"
      man: use .HP instead of .TP
      man: expand type option description
      man lvm: update see also list
      commands: adjust default help output
      man: teaking output format
      man/help: use separate common option lists
      man/help: enclose each option in brackets
      man: improve writemostly PV arg
      man: indicate repeatable options
      man/help: improve the style of units indicator
      man/help: change syntax to UNIT
      man: improve line breaks
      man: use Size variable for a number with unit
      lvconvert: fix handling args in combining snapshots
      man: add ENVIRONMENT VARIABLES section
      man: change option sorting in synopsis
      commands: fixes for recent raid changes
      commands: fix lvconvert raid rule
      man: mention regionsize default is in lvm.conf
      commands: remove lvconvert raid rule
      man: fix syntax for PV ranges
      commands: include lvconvert cache options as group
      help: print full usage for lvm help all
      commands: SECONDARY flag changes in cmd defs
      man: put some commands into advanced usage section
      commands: tweak some descriptions
      man: fix typo
      man lvchange: mention special activation vals
      commands: adjust syntax error message
      lvcreate/lvresize: the --size option accepts signed values
      commands: handle including an optional opt multiple times
      lvcreate: allow chunksize option when creating cache
      man: change the synopsis option style
      lvcreate: munge size value in help output
      help: print info about special options and variables
      help: show extents option for lvcreate
      man lvcreate: remove the extents prefix
      man lvcreate: show extents option
      args: update select description
      args: in cachemode option fix passthrough value
      man/help: improve the PV range description
      man/help: rework extents and size output
      help: show short opt with long opt
      man/help: poolmetadatasize option can take relative value
      man: move the full UNIT description
      man lvextend: mention segment type
      man/help: improve stripes option wording
      help: avoid end notes repetition in lvm help all
      commands: combine duplicate arrays for opt and val
      commands: combine duplicate arrays for lv types and props
      commands: clean up and unify signed option value handling
      tests: add test for relative option values
      man: add more references to topical man pages
      man/help: use order of required options from cmd def
      help: fix missing required option
      lvresize: poolmetadatasize cannot use minus
      tests relative-sign-options.sh: skip without thin
      tests relative-sign-options: only skip thin part
      man lvmraid: remove fixmes, use consistent example name
      commands: coverity fixes
      commands: fix missing skip condition in coverity fixes
      commands: fix lvconvert options for mirrors/stripes
      commands: use correct relative signs with mirror option
      commands: fix lvcreate mirrors/stripes options
      commands: fix command matching for unused options
      man clvmd: mention attempt for deactivate
      args: clarify repeated --options lists
      man: remove redundant line breaks
      man: remove more unnecessary line breaks
      man: remove blank lines
      man: remove blank lines in included files
      help: fix missing newlines
      man: remove blank lines from end/des files
      lvconvert: disable lvmetad for repair
      WHATS_NEW: disable lvmetad for repair
      lvmetad: fix bug in snprintf of disable reason
      help: align option list in pv/lv/vgchange cases
      man: advise against mirrored mirror log
      Revert "lvcreate: continue to accept --thinpool with -L and -V but not -T"
      commands: fix combined thin pool and vol create defs
      commands: fix commands with run with path basename
      commands: improve error message for unknown command

Heinz Mauelshagen (121):
      lvchange: allow a transiently failed RaidLV to be refreshed
      lvchange: allow a transiently failed RaidLV to be refreshed
      lvconvert: add segtype raid5_n and conversions to/from it
      lvconvert: add segtype raid5_n and conversions to/from it
      WHATS_NEW: New segment type raid5_n
      lvconvert: add segtype raid6_n_6 and conversions to/from it
      WHATS_NEW: New segment type raid6_n_6
      lvconvert: add segtypes raid6_{ls,rs,la,ra}_6 and conversions to/from it
      lvconvert: add support to change RAID region size
      lvconvert: add segtype raid5_n and conversions to/from it (cleanup)
      lvconvert: add support to change RAID region size (fixup)
      lvconvert: avoid setting segment flag
      lvconvert: add support to change RAID region size (fixup)
      lvreduce/lvresize: add ability to reduce the size of a RaidLV
      lvconvert: add conversion from/to raid10
      test: lvresize-raid.sh missing conditional
      lvconvert: add region size checks
      lvconvert: remove test code
      lvchange: reject writemostly/writebehind on raid1 during resync
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert: add infrastructure for RaidLV reshaping support
      raid: typo
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert: add infrastructure for RaidLV reshaping support
      lvconvert/lvcreate: raise maximum number of raid images
      lvconvert: allow regionsize on upconvert from linear
      lvconvert: add missed new test scripts for reshaping
      WHATS_NEW: add entry
      lvconvert: fix 2 issues identified in intesting
      lvconvert: impose region size constraints
      lvconvert: limit libdm to maximum of 64 RAID devices
      lvconvert: libdm RAID API compatibility versioning
      lvconvert: adjust reshaping check to target version
      lvconvert: adjust mininum region size check
      lvconvert: add missing reshape_len initialization
      raid: rework _raid_target_present()
      lvconvert: add new reporting fields for reshaping
      lvconvert: libdm RAID API compatibility versioning; remove new function
      lvconvert: add new reporting fields for reshaping
      lvs: enhance stripes and region size field descriptions
      man: cover reshaping
      dev_manager: remove reshape message
      man: fix term in lvmraid(7)
      report: raid enhancements for --select
      test: fix typo
      man lvs: describe new 'R' volume health character
      test: add delay to lvchange-raid1-writemostly.sh
      report: display proper LV size for reshapable RaidLVs
      lvconvert: adjust --stripes on raid10 convert
      raid: cleanup _lv_set_image_lvs_start_les()
      raid: fix raid LV resizing
      report: correct lv_size for 2-legged raid5
      raid: define seg->extents_copied
      metadata: comments
      report: fix segfault
      test: Copyright
      lvconvert: fix --repair after vgreduce
      raid: fix function description
      test: "lvconvert --repair" after vgreduce
      lvconvert: prompt when converting raid1 to linear
      lvconvert: prompt when splitting off a tracked LV of a 2-legged raid1 LV
      test: raid1 down convert to linear / split and track tests
      lvconvert: remove superfluous compile time conditonal code
      test: raid1 down convert to linear
      test: raid1 down convert to linear
      lvconvert: prompt when splitting off LV of a 2-legged raid1 LV
      dmeventd: (workaround) fix mirror DSO to work with lvmetad
      raid: add missing lv_merge_segments() call
      man: add more examples to lvmraid(7)
      lvconvert: add raid1 <-> raid4 conversion
      raid: fix compile time warning
      lvcreate: fix "striped" limit
      raid: enhance lv_raid_convert() header relative to reshaping
      raid: fix compile time warning
      man: add more info/examples to lvmraid(7)
      report: fix lv_size with reshape space allocated
      man: fix typo
      raid: check more cautious on region size changes
      dmeventd: reintroduce fix mirror DSO to work with lvmetad
      dmeventd: adjust mirror/raid DSOs to new repair design
      test: adjust to proper dm-raid target version
      lvconvert: ensure upconversion restrictions
      WHATS_NEW: adjust mirror+raid DSOs to lvconvert --repair
      WHATS_NEW: ensure raid6 upconversion restrictions
      man: lvmraid(7) clarifications
      raid: conditionally reject convert to striped/raid0*
      raid: name variables consistently
      raid: cleanup
      raid: cleanup; remove unused function
      WHATS_NEW: conditionally reject raid convert
      raid: conditionally reject convert to striped/raid; fix
      raid: check target version for shrink support
      raid: adjust to misordered raid table line output
      WHATS_NEW: adjust to misordered raid parameters
      metadata: cleanup flags definition to be consistent
      Revert "raid: adjust to misordered raid table line output"
      raid: adjust to misordered raid table line output
      libdm: typo
      man: escape all double '-'
      man: revert erouneous '-' escapes in Makefine.in
      man: escape all single '-'
      man-generator: emit escaped '-'
      man-generator: cleanup escape '-'
      WHATS_NEW: man-generator escape '-'
      man/help: avoid escaping of '-' with --help
      man-generator: fix buffer length calculation
      man-generator: more escaped '-'
      man: a few more missed '-' to escape
      lvchange: reject setting all raid1 images to writemostly
      man-generator/man/help: simplify hyphen escaping
      man: enhance man postprocessing regexp
      man: fix / typo

Jonathan Brassow (1):
      man:  Minor clarifications and grammar corrections for lvmraid.7

Marian Csontos (8):
      man: Handle empty MAN8GENERATED
      spec: lvmchange is built-in command
      man: Make dmfilemapd.8 optional
      spec: Profiles are not %config(noreplace)
      spec: Update requirements for lockd
      spec: Use %global instead of %define for constants
      spec: Replace remaining %define by %global
      spec: Disable sanlock only, keep lockd_dlm enabled

Mikulas Patocka (1):
      build: fix x32 arch

Ondrej Kozina (1):
      dmsetup: do not suppress kernel key descriptions in tables

Peter Rajnoha (2):
      report: order fields by type for field defintions in columns.h
      blkdeactivate: also unmount mount point on top of MD device if using blkdeactivate -u

Tony Asleson (34):
      lvmdbusd: Remove un-needed main thread execution
      lvmdbusd: Use cfg.reload() instead of dbo.refresh
      lvmdbusd: Use timeout_add instead
      lvmdbustest: Print messages if timeout value > 10%
      lvmdbusd: lv.py, remove duplicate code
      lvmdbusd: vg.py, remove duplicate code
      lvmdbusd: pv.py, remove duplicate code
      lvmdbusd: lvmdb.py, remove duplicate code
      lvmdbusd: manager.py, remove duplicate code
      lvmdbusd: cmdhandler.py, remove duplicate code
      lvmdbustest.py: Use _lookup function
      lvmdbustest.py: Verify lookups work immediately after vg create
      lvmdbustest.py: Re-name validation function
      lvmdbustest.py: Validate PV device
      lvmdbustest.py: Validate LV lookups
      lvmdbustest.py:  Remove un-used variable
      lvmdbusd: Add FlightRecorderDump
      lvmdbusd: Use work queue for queries too
      lvmdbusd: Disable notify_dbus for service command use
      lvmdbusd: Correct src doc for Manager.UseLvmShell
      lvmdbustest.py: Remove un-used `import time`
      lvmdbustest.py: Add unit test for external VG create
      lvmdbustest.py: Add unit test for external LV create
      lvmdbustest.py: Add unit test for external PV create
      lvmdbusd: Add debug message to lvm ID lookup
      lvmdbusd: Correct utils.add_no_notify doc
      lvmdbusd: Simplify add_no_notify for loop
      lvmdbustest.py: Correct call_lvm doc
      lvmdbustest.py: Correct debug & assert order
      lvmdbusd: Only disable notify_dbus after getting external event
      lvmdbusd: Call add_no_notify for *move commands
      lvmdbusd: Limit state refreshes for udev events
      lvmdbusd: Update state during pv move
      lvmdbusd: Rename ee to got_external_event

Zdenek Kabelac (231):
      snapshot: reporting uses statusinfo
      striped: implement compatible target name
      lv: always check status type
      activation: status check switch to warn
      activation: improve error handling for status reading
      cleanup: swap test order
      activation: lv_info_with_seg_status unify status selection
      activation: lv_info_with_seg_status API change
      activation: optimize away lv_has_target_type
      dev_manager: extend setup_task
      dev_manager: use setup_task_run for mknod
      cleanup: simplify code
      cleanup: indent and messsages updates
      cleanup: simplier code
      debug: add missing backtrace
      tests: check we recognize broken table entry
      tests: apostrof
      tests: more snaps
      cleanup: messages in raid
      cleanup: easier code for raid plugin
      cleanup: zero baton in struct initilizer
      tests: fix missing exclusive activation
      mirror: add prepare_mirror_log
      raid: fix raid1 to mirror conversion
      raid: fix delete on clustered vg
      raid: optimize clearing of lvs
      raid: avoid _ at end of name of extracted metadata LV
      pvmove: fix activation order
      libdm: validate vsnprintf
      cleanup: reuse existing function
      cleanup: use NAME_LEN stack buffer
      debug: missing stack traces
      cov: add internal error for impossible code path
      cov: declaration matching
      tests: slower device
      tests: test should clean devices it has created
      tests: remove some leaking device
      tests: remove unwanted exit
      tests: track leaked devices in tests
      cov: use unsigned for single bit values
      tests: no left devices check for skipped test
      tests: use prepare_vg more often
      tests: update seg_size_pe
      raid: improve table reload sequence
      segtype: check for seg type instead of status
      raid: avoid manipulation of segment status
      cleanup: allocate NAME_LEN size for lv name
      cleanup: more  lv_is_  usage
      cleanup: log message updates
      cleanup: remove wrapping function
      configure: just move new macro to right file
      raid: activation with list
      raid: split preserves local exlusive activation
      cleanup: use exiting function
      raid: fix activation of tracked image
      lvs: show status for layer
      thin: reload external origin with last thin
      validation: check external property is matching
      cache: improve wait for cache clear
      cache: prepare status checking for layer
      lv: fix lock holder for external origin
      libdm: drop callback on revert path
      cache: improve activation with -real
      lvconvert: support cache to external origin conversion
      backup: show warning once per command
      thin: add comment with future extension
      activate: further _info API refinement
      debug: add debug message showing new lv
      tests: using cached LV for external origin
      lvconvert: fix shown lv name for snapshot split
      cache: support cached origin for snapshot
      tests: usage of cached volume for snapshot
      validation: rework segment validation
      lv: more exact check for merging origin
      snapshot: validate merge has started
      report: show proper info for merging origin
      thin: refresh status when error processing fails
      tests: workaround failure on fc23
      tests: add device holding function
      tests: use hold_device_open
      validation: temporarily let pass linear with chunk_size
      tests: update test
      lvmcmdline: support uint32
      vgchange: max_pv limited to uint32
      cache: add missing udev wait
      cleanup: reuse existing code
      cleanup: defines
      cleanup: use macros
      cleanup: more use of lvseg_name
      cache: resize is still unsupported
      debug: show proper error message for layer mismatch
      report: report merged state for inactive LV
      tests: drop FIXME
      tests: slow down devs for raid more
      mirror: relax internal error for a while
      vgchange: also -l is uint32
      raid: postpone archiving until metadata are changed
      tests: make test more race immune
      tests: ignore racy test failure
      libdm: add human R|readable units
      cleanup: update config doc
      config: new option dmeventd/thin_command
      lvmcmd2lib: support new command
      dmeventd_thin: handling of internal command
      dmeventd_thin: switch to struct percent
      dmeventd_thin: better warning logic
      dmeventd_thin: add run_command
      dmeventd_thin: add wait_pid
      dmeventd_thin: init command
      dmeventd_thin: SIGCHLD handler
      dmeventd_thin: rework failure handling
      dmeventd_thin: drop umounting on error path
      dmeventd_thin: new logic for calling commands
      dmeventd_thin: enable support for external command
      dmeventd_thin: internal command without lvm prefix
      tests: enusure units in TiB
      tests: implement umount in script
      tests: properly quote heredoc
      tests: umount when above 95
      clean: move code to lib part
      dmeventd_thind: set LVM_RUN_BY_DMEVENTD
      toolcontext: action for LVM_RUN_BY_DMEVENTD env var
      clvmd: add mutex protection for cpg_ call
      cleanup: rename to use track_  prefix
      comment: update
      debug: add space before uuid
      cleanup: hide gcc warning
      tests: drop /tmp polution
      tests: drop zeroing
      libdm: avoid resume if preloaded device is smaller
      mem: add extra mem pages for pthread stack
      cleanup: drop double const specifier
      coverity: remove unneeded header files
      coverity: fix mem leak on error path in dm stats
      coverity: fix double free
      dmeventd: limit thin_command usage
      config: update doc
      cleanup: use proper printf specifier
      cleanup: fix warning about shadowed declaration
      cleanup: use fall through
      cleanup: use matching const type
      cleanup: use matching signed number comparation
      tests: fix dev path
      tests: update
      dmeventd: unify error handling
      activation: trust 'pending' status reported by dmeventd
      configure: update
      libdm: move code for _stats_resize_group
      makefiles: use configure vars
      makefiles: missing deps
      commands: cheap optimisation for parser
      commands: use dm_strncpy
      commands: optimize binary search
      cleanup: add comment for longer macro
      cleanup: use strchr for 1-byte lookup
      cleanup: unused uninit vars
      commands: some more dm wrappers
      commands: compensate --uuid
      lvresize: fix regressiong on accepting args
      commands: fix memleak
      man: dmsetup update
      man: dmstats update
      man: thin dmeventd plugin update
      cleanup: use const
      cleanup: use multiline string
      cleanup: same sign for compare
      cleanup: simplier code
      tests: update lvresize testing
      tests: use exclusive activation for mirror
      tests: paralelize creation and teardown
      tests: make sure which PV is used for allocation
      tests: ensure first call is version test
      tests: some debug code
      WHATS_NEW: add entry
      snapshot: improve removal of active origin volume
      tests: not slowing work with metadata
      tests: support zero_dev
      lvconvert: indent and code simplification
      lvconvert: validate name before prompt
      lvcreate: avoid rejecting  --metadataprofile
      cache: properly translate DM_THIN_DISCARDS
      thin: getting default chunk_size from single place
      pool: split chunk size validation
      pool: drop duplicated sign test
      thin: add new ZERO/DISCARDS_UNSELECTED
      cache: use UNSELECTED enum
      cache: set chunk_size as first param
      lvconvert: replacing with goto
      cache: get and set cache params
      cache: improve support for profile for cache settings
      cache: extend usability of cache_set_params
      lvcreate: respecting profile settings
      lvcreate: do not round cache volumes on cache chunks
      lvconvert: share function for cache params
      parser: allow --zero for pool conversion
      parser: enable --metadataprofile for pool lvconvert
      thin: single formula for estimation
      pool: rework handling of passed args
      cache: improve profile support for cache_set_policy
      cleanup: minor cosmetics
      tests: use LVM_SYSTEM_DIR for etc
      libdm: passthrough checks traling space char
      libdm: better code to enforce writethrough
      libdm: support cache metadata2 feature flag
      libdm: maintain binary interface for new FEATURE flag
      cache: introduce allocation/cache_metadata_format
      cache: LV supports cache segs with metadata format
      cache: use DM_CACHE_FEATURE_METADATA2 with libdm
      cache: validation for cache_metadata_format
      cache: reporting cache metadata format
      cache: allow to specify  cachemetadataformat
      cache: enable usage of --cachemetadataformat
      cache: enhance lvdisplay for cache volumes
      cleanup: easier code
      cleanup: use FMTu
      tests: cache profile and metadata2
      mirror: avoid scanning
      coverity: update models
      thin: remove unneeed test for NULL
      libdm: fix endless loop
      coverity: make sure segtype pointer is valid
      raid: use 64bit arithmetic
      mirror: revert 76f6951c3e8f0933df9730a42e9c46f273d1da24
      tests: add missing --yes
      tests: better disk delay
      lvm2app: correct internal API changes
      properties: only thin-pool provides discards
      tests: raise min dm cache version
      tests: early detect leaking error dev
      cleanup: use more common FMTd64 type
      tests: update to better fit


