From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 23 Nov 2018 03:19:24 -0500
Subject: v2_02_65 annotated tag has been created
Message-ID: <201811230819.wAN8JOvp032086@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c3e6117f097ff1fd7926b29b05d3a26b4cfe848c
Commit:        c3e6117f097ff1fd7926b29b05d3a26b4cfe848c
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-11-22 16:51 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-11-22 16:51 +0000

annotated tag: v2_02_65 has been created
	    at c3e6117f097ff1fd7926b29b05d3a26b4cfe848c (tag)
       tagging 3eb97ffa2589c0ec1932916ecf6fb37f7ceabc9f (commit)
      replaces v2_02_42

Release 2.02.65
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJb9t6PAAoJELkRJDHlCQOfoREQALnCd7ktuL//zrj00juXqFU3
LopdRKksLTw6kbmF+VdGKvthnMD4rFaIV2qJycu+SkKBlajQLZi5JgI66AqGmC3D
Pmn+fLErHA0qMIRf+QxUraO8MzulHCepOAYWCBrT4Re0zpdlKBZedhwSHWac6WFa
W6WqURGwQmzJq92Ir6RrAEJ57OXzJFW9254cm95y3OV9GmQlCZSB6GfFMZrtiw83
SoZbga2k11dVlR7NwcOIL90LWzQ0OFqq9LAKXRCwSxV2Bb300EEvUlvAndURm5/1
FWGGwREHrguChQwZs6UgMaEV3awcgGVo2zIDgqLsuPUz7OFK9N8ktt/yQTWN25BW
fVz5VgGuLD7h0i0DWkommRbWETtHD2LAEQtJRAzEKgM4XTuPn1n4Q7lb8ivP5ppp
PFr6FCYDO0HhuLACO25TNBfbp0+Rhy633urvlxXNb31c/FbA/rTQE7qCVlcVBw4I
eZWF889mQCgmFHExQdJFZmSPjgWNGYKKYVW4N+RToOq+/FSyaXcwr0JViU7LXnx5
KW3vBB8DMuzlCgju7yz71dWpWIPxXFBWpUDlMMK6zjoN4/llvXiIB6a5PPswxyfG
JyG89v0z5/yG9lLoLcJg1lWY8wT5kgvD1I+XuvGsDmaj13w2kpws0oBQ7u3012fj
o6u28ppqexnbIA+RElC7
=KHQ4
-----END PGP SIGNATURE-----

Alasdair Kergon (378):
      post-release
      Use lvm-types.h
      Add libdm subdir to begin merging the device-mapper tree.
      Split out dm-logging.h from log.h
      Split out lvm-logging.h from log.h.
      Separate out globals from the logging code.
      separate lvm-globals
      drop explicit libdevmapper.h
      Add dm-logging.h ready for libdevmapper.
      remove ancient debian dir
      libdevmapper version - will change once the merger's settled in
      first attempt at merging configure
      autoreconf
      drop configure --with-dmdir
      dmeventd plugins move
      dm+lvm2 macros
      no DMDIR
      autoreconf
      add libdevmapper-event.h
      export DM_LIB_VERSION
      further progress
      autoreconf
      Use simple x.y.z library version in libdevmapper.pc
      autoreconf
      Rename a couple of variables that matched function names.
      more tweaking to get things to compile - dmlib.h for log fns, list.h
      add list fns
      Right, a simple build (without options) is working again.
      more tweaks for dmeventd - not finished yet
      more missing bits
      more fixes
      dmeventd
      clvmd
      make install_device-mapper
      quick review of docs
      First test release of the merged code base.
      no need for libdevmapper.h on system any more
      clarify
      some makefile fixes for liblvm2cmd & remove some hardcoded .so
      post-release (retrospective)
      Generate clvmd init script at configuration time for Red Hat-based distros.
      regenerate
      generate init script
      Add tinfo to termcap search path for pld-linux.
      Don't skip updating pvid hash when lvmcache_info struct got swapped.
      Suppress 'duplicate PV' message when it's only a cache update not a real
      Fix uninitialised lv_count in vgdisplay -c
      Use dm_snprintf to avoid duplicating the snprintf compatibility code.
      lvm2cmdline.h:31: warning: declaration of `is_static' shadows a global declaration
      Display a 'dev_size' of zero for missing devices in reports.
      Add an "all" field which expands to all fields of the report type.
      Add <report_type>_all to help text.
      More fields can cause segfaults with orphans.
      ...and a few more uninitialised dummy fields.
      pre-release
      Add stuff people missed.
      and another one missing
      post-release
      Rename vg_read() to vg_read_internal(). (mornfall)
      Introduce as-yet-unused _vg_lock_and_read() and associated header file
      Properly enforce cluster locking in as-yet-unused _vg_lock_and_read. (mornfall)
      Replace internal vg_check_status() implementation.  (mornfall)
      Introduce as-yet-unused replacement vg_read() and vg_read_for_update()
      Add as-yet-unused vg_read_error() and vg_might_exist().  (mornfall)
      If kernel supports only one dm major number, use in place of any supplied.
      Index cached vgmetadata by vgid not vgname to cope with duplicate vgnames.  (dwyso)
      Mention the restriction on file descriptors at invocation on the lvm man page.
      Provide da and mda locations in debug message when writing text format label.
      Fix interrupt unblocking after vgcreate, for example: drop_cached_metadata()
      Add --dataalignment to pvcreate to specify alignment of data area.  (mbroz)
      Add system_dir parameter to create_toolcontext() and call it system_dir
      Move tools/version.h to lib/misc/lvm-version.h.
      Use pkgconfig to obtain corosync library details during configuration. (kabi)
      autoreconf  (using fedora 10 for this now)
      fsadm cleanups & release prep
      .
      Attempt cleanup in child before execing new binary in exec_cmd()
      .
      Fix last check-ins: seg can be NULL.
      pre-release
      post-release
      Add missing 'device-mapper' internal subdir build dependency.
      fix typo reported by "A. Costa" <agcosta@gis.net>
      Fix linux configure --enable-debug to exclude -O2.
      Add sparse devices: lvcreate -s --virtualoriginsize (hidden zero origin).
      better variable name for snapshot counting
      Revert:
      Missing entries.
      Pre-release cleanups.
      Reinstate version in liblvm2cmd.so soname. (2.02.44)
      Rename liblvm.so to liblvm2app.so and use configure --enable-applib.
      post-release
      Attempt to load dm-zero module if zero target needed but not present. (mbroz)
      0->NULL (mbroz)
      Fix counting of virtual origin LVs in vg_validate. (mbroz)
      Skip virtual origins in process_each_lv_in_vg(). (mbroz)
      Make --snapshot optional with lvcreate --virtualsize.
      Suppress 'removed' messages displayed when internal LVs are removed.
      Rename internal vorigin LV to match visible LV.
      Remove /dev/vgname/lvname symlink automatically if LV is no longer visible.
      When creating new LV, double-check that name is not already in use.
      Handle multi-extent mirror log allocation when smallest PV has only 1 extent.
      Remove verbose 'visited' messages.
      Make mempool optional in dm_split_lvm_name()
      Add subsystem, vg_name, lv_name, lv_layer fields to dmsetup reports.
      Add splitname.
      test commit
      test commit
      test commit
      Abort operation if automatic metadata correction in lvconvert fails.
      Abort if automatic metadata correction fails when reading VG to update it.
      revert last patch - let's do a release first
      pre-release
      pre-release tidy up
      update date
      post-release
      clarification
      Add device number to more log messages during activation.
      Fix whitespace in linear target line to fix identical table line detection.
      .
      Permit several segment types to be registered by a single shared object.
      Add dm_log_with_errno and dm_log_with_errno_init, deprecating the old
      Fix dev name mismatch in vgcreate man page example.
      Make cmd->cmd_line const.
      Exclude VG_GLOBAL from vg_write_lock_held so scans open devs read-only again. (mbroz)
      pre-release
      New LOG_MESG macro to fix file/line number logging for memory leaks after
      pre-release clarification
      pre-release
      post-release
      Revert broken commit:
      Use log_error macro consistently throughout in place of log_err.
      Store any errno and error messages issued while processing each command.
      Add lvm_errno and lvm_errmsg to liblvm to obtain failure information.
      Add log_errno to set a specific errno and replace log_error in due course.
      Fix so only log_error and log_fatal set EUNCLASSIFIED.
      Return EINVALID_CMD_LINE not success when invalid VG name format is used.
      Add an API version number, LVM_LIBAPI, to the VERSION string.
      Use newly-independent LVM_LIBAPI in liblvm soname.  E.g. liblvm2app.so.2.1.
      fix dir in generated file list for cflow
      Add liblvm2app Makefile installation targets.
      check in the correct pkgconfig file
      All LV locks are non-blocking so remove LCK_NONBLOCK from separate macros.
      remove no-longer-needed NONBLOCK
      Add global/wait_for_locks to lvm.conf so blocking on locks can be disabled.
      pre-release
      pre-release
      clean up a bit for release
      

      post-release
      Remove pv_t, vg_t & lv_t handles from lib.  Only liblvm uses them.
      renamed include files
      Fix lvm2app.pc installation filename.
      Fix configure script to handle multiple clvmd selections.
      corosync not cman...
      Prepare for udev synchronisation code.  (options don't work yet)
      add not-yet-working udev options
      configure --udevdir
      Add libdevmapper functions to support synchronisation with udev.
      another fixme
      Add udevcomplete and --noudevwait to dmsetup.
      Set cookies in activation code and wait for udev to complete processing.
      dummy makefile for now to keep builds happy
      lvchange --noudevsync
      deal with error-related FIXMEs
      cleanup some ignored return values & 'stack's
      Manage without dm_udev_cleanup?
      Only create LV symlinks on ACTIVATE not PRELOAD.
      Add warnings to check udev did what it was meant to.
      Add udev checks.
      Add default udev rules.
      Add activation/udev_sync to lvm.conf.
      detect udev mk_link problems
      Additional logging
      pre-release
      pre-release
      post-release
      Rewrite clvmd configuration code.
      change clogd to cmirrord
      rename clogd dir to cmirrord
      clogd->cmirrord
      Add lots of missing stack debug messages to tools.
      More cmirror makefile fixes from Fabio.
      pre-release
      dm release cleanup
      missing (C) reminders
      pre-release cleanup
      post-release
      Remove test/api which should only be under 'make test'.
      Update lvm2_monitoring script.
      drop -ing suffix
      Enable dmeventd monitoring section of config file by default.
      Fix dmeventd _temporary_log_fn parameters. (2.02.50)
      Handle any path supplied to dm_task_set_name() by looking up in /dev/mapper.
      remove unused var & rename fn
      ensure dm_strdup succeeds
      pre-release
      pre-release
      missing dm_snprintf
      Fix log fn prototype.
      post-release
      Add global/si_unit_consistency to enable cleaned-up use of units in output.
      Treat input units of both 's' and 'S' as 512-byte sectors.  (2.02.49)
      Consolidate LV allocation into alloc_lv().
      Provide alternative implementation of obsolete siginterrupt().
      Don't attempt to deactivate an LV if any of its snapshots are in use.
      Generalise polldaemon code by changing mirror-specific variable names.
      Don't attempt to restart pvmoves when deactivating LVs in vgchange.
      look up pvmove by pvmove LV when PVMOVE flag is set
      Distinguish between powers of 1000 and powers of 1024 in unit suffixes.
      Factor out poll_mirror_progress and introduce progress_t.
      Make poll_mirror_progress a function that can be replaced.
      Introduce percent_range_t and centralise snapshot full/mirror in-sync checks.
      Add percent_range to copy_percent too.
      Allow for a build directory separate from the source.
      Only include selinux libs in libdevmapper.pc when selinux build enabled.
      Correct example.conf to indicate that lvm2 not lvm1 is the default format.
      More makefile cleaning up and fixing.  (gentoo)
      linking parms missing from o->so conversion.
      Extra libs must be appended, not defined first.
      More build cleanups (linker parameter ordering).
      Attempt to build dmeventd.static.
      .
      Remember to clear 'global lock held during cache refresh' state after use.
      Fix clvmd segfault when refresh_toolcontext fails.   (brassow, bz 506986)
      Cleanup mimagetmp LV if allocation fails for new lvconvert mimage.
      Permit snapshots of mirrors.  (brassow)
      pre-release
      add copyright lines
      .
      post-release
      Insert some missing stack macros into activation code.
      Fix hash lookup segfault when keys compared are different lengths.
      Tidy some uses of arg_count and introduce arg_is_set.
      Add support for querying a device's inactive table.
      .
      pre-release
      .
      post-release
      pre-release
      .
      Post-release.
      Log failure type and recognise type 'F' (flush) in dmeventd mirror plugin.
      Internal errors triggering abort cannot be suppressed. (kabi)
      Use _LOG_FATAL when aborting on an internal error.
      Add missing items to WHATS_NEW files.
      .
      Revert so-called "redundant" log until after next release.
      disable 'redundant' tests
      pre-release
      post-release
      Fix allocation code not to stop at the first area of a PV that fits.
      pre-release
      Note some problems still to be addressed.
      post-release
      Misc compilation clean-ups.
      Clean up include files.
      more build fixes
      And more fixes for cmirror build.
      Signal handling FIXMEs.
      remove no-longer-used files
      remove no-longer-used header
      remove more compiler warnings
      Remove mknod() and add FIXMEs.
      Deal with a few more compiler warnings.
      Add libdevmapper-event-lvm2.so to serialise dmeventd plugin liblvm2cmd use.
      pre-release
      fix lib include
      missing header
      post-release
      pre-release
      Fix dmeventd snapshot plugin build dependency.
      Remove pointless versioned symlinks to dmeventd plugin libraries.
      pre-release
      post-release
      use lvm2app to refer to library now
      Extend core allocation code in preparation for mirrored log areas.
      Misc cleanups in the new mlock code, incl. improving some variable names
      .
      some missing debug messages
      pre-release
      pre-release cleanups
      post-release
      Introduce is_missing_pv().
      Look up missing PVs by uuid not dev_name in _pvs_single to avoid invalid stat.
      replace existing_pv with existing_pvl
      Remove unnecessary full_scan parameter from get_vgids and get_vgnames calls.
      Only do one full device scan during each read of text format metadata.
      fix last checkin
      Suppress repeated errors about the same missing PV uuids.
      autoreconf & add missing WHATS_NEW entry
      Fix libdevmapper-event pkgconfig version string to match libdevmapper.
      Avoid duplicate definitions.
      Allow dynamic extension of array of areas selected as allocation candidates.
      Introduce pv_area_used into allocation algorithm and add debug messages.
      improve a few comments in last check-in
      add debug output and attempt to control which device gets log as intended perhaps
      add debug mesgs and attempt to control which device is used for log as perhaps intended
      .
      add debug mesg
      more diagnostics
      more diagnostics
      Add some assertions to allocation code.
      Use INTERNAL_ERROR definition consistently in internal error messages.
      .
      Allow ALLOC_ANYWHERE to split contiguous areas.
      Fix --alloc contiguous policy only to allocate one set of parallel areas.
      Attempt to fix non-ALLOC_ANYWHERE allocation code after recent changes broke
      remove unused var
      Change most remaining log_error WARNING messages to log_warn.
      Improve vg_validate to detect some loops in lists.
      Improve vg_validate to detect some loops in lists.
      Limit number of error messages when checking LV segments.
      initialise log_allocated to 0
      Avoid endless loop if lv->segments list is corrupted
      Try to fix tracking of whether or not log extents need allocating.
      temporarily downgrade the 'open while suspended' error till we fix it properly
      A few more log_error to log_warn changes for mirrors.
      remove compiler warning
      Display PVs created during tests
      Disable broken test.
      Fix is_partitioned_dev not to attempt to reopen device.
      disable another broken check in a test
      Fix incorrect removal of symlinks after LV deactivation fails.
      Issue a message if the new type of deactivation failure happens.
      Only fail if the top-level LV fails to be deactivated - allow deactivation
      Fix pvmove allocation to take existing parallel stripes into account.
      suppress bogus compiler warning
      missing ?:
      another incorrect test that should have been failing before
      And another test that should have been failing - normal allocation policy
      Permit mimage LVs to be striped in lvcreate and lvresize.
      Don't ignore error if resuming any LV fails in resume_lvs.
      Add activation/polling_interval to lvm.conf as --interval default.
      Add --stripes to lvconvert too.
      Use typedefs for toollib process_each functions.
      Only pass visible LVs to tools in cmdline VG name/tag expansions without -a
      pre-release
      .
      pre-release
      pre-release
      fix broken 'make install' for lvm_dump.sh
      touch file
      post-release
      Change daemon lock filename from lvm2_monitor to lvm2-monitor for consistency.
      Speed up dm_bit_get_next with ffs().
      Simplify dm_bitset_create. (ejt)
      fix last commit
      Add dm_bit_and. (ejt)
      missed files from last commit
      Move function up file
      typo in comment
      Add dm_bitset_equal to libdevmapper.
      Add a regex optimisation pass for shared character prefixes.
      add -r to print out closer to original regex format
      Still not satisfactory...
      isprint
      fix leftmost rotation
      Fix rightmost rotation, and use LEFT and RIGHT to make symmetry more obvious.
      Don't walk rightmost through NULL pointers.
      Move regex printing code from test to main tree (may use in debug messages).
      avoid ORs rightmost
      Cache bitset locations to speed up _calc_states. (kabi)
      don't optimise anything with TARGET_TRANS to avoid intefering with the matcher's counting
      add comments
      Fix lvconvert error message when existing mirrored LV is not found.
      Mention how to get PV to LV mappings.
      Remove no-longer-used arg_ptr_value.
      .
      .
      change awk path
      pre-release
      typo
      post-release
      Fix truncated total size displayed by pvscan.
      Fix static build.
      Use -d to control level of messages sent to syslog by dmeventd.
      pre-release

Christine Caulfield (23):
      Fix a starup race in clvmd that could result in huge waits for the first command to be processed.
      Add a corosync/DLM cluster service to clvmd.
      Mention --with-clvmd=corosync in ./configure
      Allow clvmd to be built with all cluster managers & select one on cmdline.
      Allow clvmd to start up if its lockspace already exists.
      Add option to /etc/sysconfig/cluster to select cluster type for clvmd.
      Remove duplicate cpg_initialize from clvmd startup.
      Add a fully-functional get_cluster_name() to clvmd corosync interface.
      Fix error returns in clvmd-corosync interface to DLM.
      Fix unlocks in clvmd-corosync.
      Block SIGINT & SIGTERM in clvmd subthreads so they don't delay shutdown.
      Make sure clvmd-corosync releases the lockspace when it exits.
      Fix clvmd-corosync to match the new corosync API.
      Document the -I option to clvmd
      Fix locking in clvmd
      Fix compilation warning in clvmd.c
      Add some code to clvmd to look in the corosync confdb to see what cluster
      Stop clvmd from automatically doing lock conversions. Now, if a lock
      Add LCK_CONVERT flag I missed on the last checkin.
      Make clvmd return 0 on success rather than 1.
      Make clvmd -V return zero status rather than 1.
      Fix a thread race in clvmd that could cause lockups on very busy systems
      Add -S command to clvmd, so it can restart itself and still

Dave Wysochanski (362):
      Fix vgdisplay return code and exit status.
      Fix lvhange and lvcreate man pages to properly describe permissions option.
      Make man pages consistent with either-or options (use "|" everywhere).
      More man page cleanup - convert "+/-" to "+|-"
      Fix "lvremove -f vgname" when vgname contains snapshots.
      Fix vgcreate race which could allow two parallel vgcreates to succeed,
      Fix test-utils.h for rhel4 backward compatability.
      Add generic function to read /dev/urandom, used in uuid calculation.
      Make _init_rand() thread safe - use rand_r() instead of rand().
      Add liblvm interactive test infrastructure to build.
      Replace _apply_settings() after create_toolcontext() with equivalent inline.
      Remove init_debug() calls immediately after create_toolcontext() call.
      Remove init_verbose() calls immediately after create_toolcontext() calls.
      Remove handles_missing_pvs assignment after call to create_toolcontext().
      Move init_test() from _apply_settings into _init_logging().
      Remove archive_enable() calls after create_toolcontext() calls.
      Remove backup_enable() calls after create_toolcontext() calls.
      Remove redundant set_activation() call after create_toolcontext() calls.
      Remove redundant init_msg_prefix() and init_cmd_name().
      Move initialization of cmd->fmt into init_formats().
      *** empty log message ***
      Create _init_globals() and call from bottom of create_toolcontext().
      Fix segfault when invalid field given in reporting commands.
      Rename 'cmd' to 'clvmd_cmd' to remove ambiguity.
      Move arg_* functions from toollib.c to lvmcmdline.c.
      Remove struct arg * from struct cmd_context and create_toolcontext().
      Create global is_static() to eliminate from the library init function.
      Add pv_mda_size to 'pvs' and vg_mda_size to 'vgs'.
      Add pv_mda_size to pvs and vg_mda_size to vgs.
      Fix pvs segfault when run with orphan PV and vg_mda_size or vg_mda_free fields
      Fix fsadm lvresize for filesystem block sizes != 1024.
      Add skeleton of fsadm nightly test but skip (doesn't work yet).
      Rename _parse_options() to _parse_fields() for naming consistency.
      Add --rows option to pvs, vgs, lvs man pages.
      Add --nameprefixes to pvs, vgs, lvs man pages.
      Add missing --segments to pvs man pg.
      Add --unquoted to pvs, vgs, lvs man pages.
      Rename get_vgs() to get_vgnames() and clarify related error messages.
      Move locking_type reading inside init_locking().
      Update vgchange and vgmknodes man pages to include --refresh.
      Rename liblvm to liblvm-internal.
      Add new liblvm build directory and move lvm_base.c.
      Move lvm.h from lib to liblvm.
      Add DSO generation for new LVM application library.
      Remove unnecessary linker flags for liblvm.
      Fix liblvm version symlink.
      Add missing liblvm/.exported_symbols
      Fix error messages when PV uuid or pe_start reading fails.
      Remove unnecessary includes in lvm_base.c.
      Fix some distclean rules.
      Fix some clean rules, fix previous distclean checkin.
      Fix whitespace in t-mdata-strings.sh
      Add libdevmapper to test/api building.
      Remove some trailing whitespace so git won't complain.
      Update columns.h comment to describe macro args.
      Fix error path in vg_make_handle().
      Use liblvm.so instead of .a
      Fixup whitespace.
      Fixup whitespace.
      Update columns.h comment.
      Validate chunksize and originsize for snapshots.
      Add tests to check vgcreate --physicalextentsize and field vg_extent_size.
      Add tests to check pv_mda_size and vg_mda_size.
      Update tests for region_size.
      Add test for seg_start, seg_count, seg_start_pe
      Update t-read-ahead.sh to validate lv_read_ahead and lv_kernel_read_ahead.
      Remove NON_BLOCKING lock flag from tools and set a policy to auto-set.
      Update test-utils to cope with ":" in device names and allow configurable names.
      Add test - lvconvert from linear (on multiple PVs) to mirror.
      Add vgrename test to check for existence of new vg.
      Add vg_lock_newname() library function.
      Update vgrename to use vg_lock_newname.
      Update vgcreate to use new vg_lock_newname().
      Update vgsplit to use new vg_reserve_newname() function.
      Update WHATS_NEW
      In the new _vg_read_for_update(), we always do the check for CLUSTERED vg
      Cleanup pvs, vgs, and lvs "-o" section in man pages (rhbz 500861).
      Convert the straight instances of vg_lock_and_read to new vg_read(_for_update).
      Fix incomplete revert for lvconvert.
      Convert the straight instances of vg_lock_and_read to new vg_read(_for_update).
      Rework the toollib interface (process_each_*) on top of new vg_read.
      Convert vgreduce to use vg_read_for_update.
      Convert vgrename to vg_read_for_update.
      Don't segfault in vg_release when vg->cmd is NULL.
      Convert vgsplit to use vg_read_for_update.
      Add lvmcache_init() to polldaemon initialization.
      Fix t-inconsistent-metadata.sh.
      Update WHATS_NEW for vg_read commits
      Fix vg_read() error paths to properly release upon vg_read_error().
      Fix compile warning in lvmcmdline.c - use C99 PRIu64 for uint64_t.
      Remove LOCK_KEEP and READ_CHECK_EXISTENCE from vgsplit.
      Remove unneeded LOCK_KEEP from vg_read() interface.
      Remove READ_CHECK_EXISTENCE and vg_might_exist().
      Remove unneeded LOCK_NONBLOCKING from vg_read() API.
      Update WHATS_NEW for vgread cleanup
      Make destroy_toolcontext() better able to handle NULL pointers.
      Fix segfault in persistent_filter_dump() if lvm init fails.
      Add t-lvm-init.sh - test lvm init routines and error paths.
      Refactor a couple log_error() statements in prep for larger log_error() patch.
      Make exit paths more robust when some init function fails.
      .
      Fix memory leak in vgsplit when re-reading the VG.
      Update t-vgcreate-usage.sh to check for default vg properties.
      Add defines for default vgcreate parameters.
      Update vg_change_pesize() to contain all validity checks.
      Remove unused 'cmd' from vg_change_pesize().
      Rename vg_change_pesize to vg_set_extent_size and use vg_t.
      Add vg_set_max_lv() liblvm function and move vgchange logic inside.
      Add vg_set_max_pv() liblvm function and move vgchange logic inside.
      Add vg_set_alloc_policy() liblvm function and move vgchange logic inside.
      Change vg_create() to take only minimal parameters and obtain a lock.
      Update WHATS_NEW for recent vgcreate changes
      Remove unnecessary parameters from vg_remove_single().
      Remove force parameter from vg_remove_single, now the liblvm function.
      Move orphan lock inside vg_remove_single.
      Move orphan lock obtain/release inside vg_extend().
      Change lock ordering of vgcfgrestore to be consistent with other tools.
      Update WHATS_NEW for vgremove and ORPAHN_LOCK refactoring
      Remove unused code vg_lock_and_read() and related flags.
      Remove READ_REQUIRE_RESIZEABLE from vgextend by moving check inside vg_extend.
      Refactor vgsplit - move move_pvs_used_by_lv and move_pv inside library.
      Remove READ_REQUIRE_RESIZEABLE flag from vgsplit.
      Remove READ_REQUIRE_RESIZEABLE flag from vg_read() interface - no users.
      Define handles to liblvm objects for pv, vg, lv, lvseg, pvseg.
      Add default cmd->cmd_line initialization for liblvm lvm_create().
      Add lvm_vg_* APIs to create and modify VGs.
      Add VG APIs to liblvm/.exported_symbols.
      Add liblvm test case for creating of a vg.
      Add a few negative tests which should fail cleanly if pv, vg, lvs don't exist.
      Fix vgck and vgremove segfault if non-existent vg given.
      Fix pvremove test breakage.
      Fix FAILED_INCONSISTENT case in vg_backup_single - typeo on 'if' condition.
      Check for certain vg_read errors in _process_one_vg iterator.
      Fix memory leak in _process_one_vg error path.
      Fix memory leak in process_each_pv path.
      Change default errno value to 0 (no error) and add prototypes in lvm.h
      Remove extraneous messages for extent_size and alloc_policy upon vgcreate.
      Remove 'is already' message from vg_set_* functions.
      Fix compile warnings in vgcreate liblvm api unit test case.
      Rename test/api/vgcreate.c to vgtest.c to reduce filename conflicts in tree.
      Fix build environment of test/api: Make it usable for more than one test case.
      Export lvm_errno and lvm_errmsg in liblvm.
      Fix lvm_vg_close() when locking fails.
      Update test/api/vgtest.c to use lvm_errno and lvm_errmsg.
      Update api/test/vgtest.c error handling.
      Add lvm_vg_open() to open an existing VG for reading or writing.
      Add a couple lvm_vg_open() calls to vgtest.c.
      Update lvm_vg_create to use NULL / non-NULL return for the time being.
      Remove lvseg_t and pvseg_t typedefs from liblvm/lvm.h.
      Add list structure definitions for liblvm objects.
      Add lvm_vg_list_{pvs|lvs} - return lists of pv/lv handles for a vg.
      Add lvm_{pv|vg|lv}_get_{uuid|name}.
      Update test/api/test.c for simple tests involving pv/vg/lv name/uuid attributes.
      Update WHATS_NEW for liblvm commits
      Update test/api/test.c to not segfault if null lists of pvs/lvs returned.
      Remove redundant validate_name in vgreduce.
      Add lvm_list_vg_names and lvm_list_vg_ids liblvm functions.
      Add lvm_scan_vgs liblvm fn to scan the system for LVM metadata.
      Add tests for lvm_vg_name_list, lvm_vg_id_list and lvm_scan_vgs.
      Revert previous patch that moved VG_ORPHAN lock inside vg_extend.
      Update lvm_vg_extend() to obtain VG_ORPHAN.
      Eliminate compile warning introduced by previous commit.
      Remove unneeded pv_create wrapper function.
      Move bulk of pvcreate logic into library.
      Allow pvcreate_single to be called with NULL for default pvcreate params.
      Change pvcreate_single to return pv_t and update function description.
      Move ORPHAN_VG lock outside pvcreate_single.
      Update lvm_vg_extend to do an implicit pvcreate on the device.
      Remove use of void * from pvcreate_single.
      Refactor _lvcreate - move *_ARG into _lvcreate_params and get 'cmd' from 'vg'.
      Refactor extents calculations / updates in _lvcreate.
      Move percent_t from struct lvcreate_params to struct lvcreate_cmdline_params.
      Move 'size' from lvcreate_params into lvcreate_cmdline_params.
      Comment lvcreate_params struct.
      Move pvs and pv_count fields from lvcreate_params to lvcreate_cmdline_params.
      Move _lvcreate into the internal library and rename to lv_create_single.
      Move extents_from_size from lvcreate into internal library so we can reuse.
      Add lvm_vg_create_lv_linear liblvm function.
      Update test/api/test.c to handle read/write open modes.
      Update test/api/test.c to call lvm_vg_create_lv_linear.
      Update WHATS_NEW for recent checkins
      Rename vg_size to vgsize to avoid naming conflicts.
      Refactor a few report field calculations into separate functions.
      Use vg_size in vg_set_extent_size.
      Add most all liblvm 'get' functions needed for anaconda.
      Update test/api/test.c for liblvm 'get' functions.
      Update test/api/test.c - correct list_vg_names and list_vg_ids.
      Add lvm_vg_remove_lv liblvm function.
      Update test/api/test.c to call lvm_lv_remove.
      Rename lvm_vg_get_free_count to lvm_vg_get_free_extent_count.
      Rename lvm_list_vg_ids to lvm_list_vg_uuids.
      Rename lvm_vg_get_free to lvm_vg_get_free_size.
      Update lvm.h handle and handle list comments.
      Update lvm.h - comments describing function behavior, divide into sections.
      Rename lvm_scan_vgs to lvm_scan.
      A few more lvm.h updates that got missed.
      Update liblvm status return codes to be consistent.
      Update a few liblvm calls with log_errno.
      Update test/api/*.c to use consistent liblvm error returns.
      Implement lvm_lv_activate and lvm_lv_deactivate liblvm calls.
      Add lvm_lv_is_active and lvm_lv_is_suspended.
      Update test/api/test.c to call lv_deactivate and lv_activate.
      Update test/api/test.c to display lvm_lv_is_active and lvm_lv_is_suspended.
      Update WHATS_NEW for latest liblvm changes
      More liblvm header file cleanups.
      Update display.c to use vg_free(vg) instead of duplicating the calculation.
      Rename lvm_reload_config to lvm_config_reload.
      Update error return and comments for lvm_list_vg_names/uuids.
      Add vg_reduce to metadata.c and metadata-exported.h
      Add lvm_vg_reduce to liblvm2app
      Update test/api/vgtest.c to include lvm_vg_reduce.
      Update test/api/test.c to include lvm_vg_reduce and lvm_vg_extend.
      Add skeletons of lvm_lv_resize and lvm_pv_resize - not yet implemented.
      Refactor _override_settings to take the new config string as input.
      Rename _override_settings into override_config_tree_from_string and move.
      Add lvm_config_override - allow caller to override config, similar to --config.
      Update return code for lvm_config_reload.
      Add config_reload and config_override to test.c, change prompt.
      Remove unnecessary 
's from log_error in liblvm.
      Update WHATS_NEW for latest liblvm changes
      Add warning to lvm.h stating API development in progress.
      Update lvm.h to address feeback.
      Rename lvm_create to lvm_init and lvm_destroy to lvm_quit.
      Use dm_malloc and dm_free in liblvm instead of malloc/free.
      Add lvm_library_get_version() and update unit tests to display version.
      Fix lvm.h formatting.
      Update lvm.h - remove remaining FIXMEs, note limitations of a few functions.
      Add lvm_vg_get_seqno, updating lvm.h and unit test.
      Update interactive unit test for liblvm - add vg_write, general cleanup.
      Update interactive unit test - fix silly vg_close error.
      Add an open_mode to the vg struct for liblvm - enforce read / write semantics.
      Add doxygen mainpage tag to lvm.h
      Remove unneeded struct on return from lvm_lv_create_linear.
      Don't include lvm-version.h in exported liblvm file!
      Move FIXME from user visible lvm2app.h to lvm_vg.c
      Update test/api/test.c to call lvm_vg_create and lvm_vg_remove.
      Remove useless _pv_write wrapper.
      Update man pages to clarify usage of PE ranges.
      Fix vgextend error path - if ORPHAN lock fails, unlock and release vg.
      Update WHATS_NEW for recent checkins.
      Make lvm2app vg_t handle definition consistent with lvm_t.
      Make lvm2app lv_t handle definition consistent with lvm_t.
      Make lvm2app pv_t handle definition consistent with lvm_t.
      Update WHATS_NEW
      Fix error paths for vgcfgrestore when locking fails.
      Add alphabetical vgname ordering tests for vgsplit, vgmerge, vgrename.
      Fix vgsplit test to require -M on ordering of vgnames.
      Refactor vgsplit to move existing_vg logic in a separate 'if' statement.
      Refactor vgsplit - remove bad2 label.
      Refactor vgsplit - add 'lock_vg_from_first' flag.
      Refactor vgsplit - create _vgsplit_to function which creates or opens dest vg.
      Refactor vgsplit - create _vgsplit_from function to open source vg.
      Refactor vgsplit: _vgsplit_from or _vgsplit_to failure cleanup depends on order.
      Refactor vgsplit - reorder _vgsplit_from and _vgsplit_to based on flag.
      Change vgsplit behavior to open/lock first vg based on alphabetical ordering.
      Refactor vgmerge - introduce lock_vg_from_first flag.
      Refactor vgmerge - create _vgmerge_from and _vgmerge_to.
      Refactor vgmerge - combine _vgmerge_to and _vgmerge_from into _vgmerge_vg_read.
      Change vgmerge behavior to open/lock first vg based on alphabetical ordering.
      Refactor vgrename into vg_rename_old and vg_rename_new.
      Update vgrename to take into account vgname lock ordering.
      Enforce an alphabetical lock ordering for vgname locks.
      Rename internal library function vg_remove to vg_remove_mdas.
      Split vg_remove_single into 2 functions - the second part commits to disk.
      Update vg_remove_single_* functions to use the removed_pvs list.
      Update lvm_vg_write() to handle the deferred commit of lvm_vg_write().
      Update lvm2app vgtest to take vgname and devices as parameters.
      Restore umask when device node creation fails.
      Add lvm2app.sh to nightly testsuite.
      Remove 'test' interative api unit tests from 'TARGET' line.
      Fix path to test/api/vgtest in nightly testsuite.
      Add daemons/cmirrord files to git - somehow got messed up with cvs rename.
      Restore umask when device node creation fails.
      Add lvm2app.sh to nightly testsuite.
      Remove 'test' interative api unit tests from 'TARGET' line.
      Fix path to test/api/vgtest in nightly testsuite.
      Update lvm2app unit test vgtest - fix remove bug.
      Add max_pv and max_lv vg 'get' lvm2app exports.
      Update lvm and vgs man pages to clarify 'partial' is a VG missing PVs.
      Add most relevant vg_attr fields as lvm2app 'get' functions.
      Use vg_is_exported(vg) macro everywhere.
      Fix build failure when enabling dmeventd and applib.
      Fix process_each_vg / _process_one_vg when vg_read() returns FAILED_LOCKING.
      Add vg_is_resizeable() and cleanup references.
      Fix lvm2app test to run under test/api subdirectory only when configured.
      Trivial cleanup to lvcreate man page - use virtualsize in example.
      Update nightly tests to deal with unit changes.
      Refactor vg_extend - add vg_extend_single_pv.
      Add pvcreate_params to vg_extend_single_pv.
      Add pvcreate_params to vg_extend.
      Allow calling fill_default_pvcreate_params from tools.
      Refactor pvcreate - split pvcreate_validate_params into recovery/non-recovery.
      Refactor vgcreate/vgextend validation of vgname/pvname(s).
      Move pvcreate_validate_params into toollib to allow calling from mutiple tools.
      Add implicit pvcreate support to vgcreate and vgextend.
      Update vgcreate and vgextend man pages to clarify implicit pvcreate.
      Add implicit tests for implicit pvcreate during vgcreate and vgextend.
      Update help messages for vgextend / vgcreate to mention PHYSICAL DEVICE OPTIONS.
      Add --pvmetadatacopies as a synonym for --metadatacopies in various commands.
      Add --pvmetadatacopies as a synonym for --metadatacopies in various commands.
      Cleanup comment and some whitespace.
      Minor fix to vgcreate/vgextend man pages for PHYSICAL DEVICE OPTIONS.
      Update lvcreate/lvconvert man pages to explain PhysicalVolume parameter.
      Document --all option in man pages, cleanup {pv|vg|lv}{s|display} man pages.
      Add to vgcreate and vgextend nightly tests.
      Add vg_mda_count library function.
      Add vg_set_clustered() - move logic from vgchange.
      Update vgcreate to call vg_set_clustered().
      Update vgsplit to call vg_set_clustered().
      Rename pvcreate_params processing functions to better match <object><action>.
      Add vgcreate_params_set_defaults().
      Rename fill_vg_create_params to vgcreate_params_set_from_args.
      Rename validate_vg_create_params to vgcreate_params_validate.
      Remove old, and now incorrect, vgextend man page description of pvcreate options.
      Remove unnecessary / duplicate dm_list macros and functions.
      Fix setting of readahead in lvcreate.
      Add tests to check for readahead value in lvcreate.
      Update a few more uint64_t's related to the 64-bit status change.
      Fix activated/deactivated log_verbose message
      Correct 'void *' usage in pvcreate_single.
      Remove useless memory allocation for pv->vg_name in _alloc_pv().
      Call _alloc_pv() inside _pv_read() and clean up error paths.
      Remove unnecessary "dmsetup resume" after "dmsetup create".
      Add copy constructor for struct metadata_area.
      Fix off by 512 sizes for lvm2app.
      Export lvm_pv_get_size(), lvm_pv_get_free(), lvm_pv_get_dev_size in lvm2app.
      Update simple lvm2app unit test for new size apis.
      Update lvm2app.h comments to remove hidden VG comment list vgnames/vgids.
      Add get_{pv|vg|lv}_field() nightly test helper functions.
      Add nightly test to cover vg/lv tags add/delete.
      Refactor _vgchange_tag() to vg_change_tag() library function.
      Refactor vgcreate to call new vg_change_tag() function.
      Refactor lvchange_tag() to call lv_change_tag() library function.
      Add dm_pool_strdup to allocate memory and copy a tag in {lv|vg}_change_tag()
      Add tag_list_copy() supporting function inside lvm2app.
      Add lvm_vg_get_tags(), lvm_vg_add_tag(), and lvm_vg_remove_tag().
      Add lvm_lv_get_tags(), lvm_lv_add_tag(), and lvm_lv_remove_tag().
      Update lvm2app interactive unit test for vg/lv tags.
      Update doxygen comments for lvm2app.h.
      Add Doxygen file for lvm2app to generate documentation from lvm2app.h.
      Update WHATS_NEW.
      Add pvchange -u --all to testsuite.
      Avoid scanning all pvs in the system if operating on a device with mdas.
      Update WHATS_NEW for last checkin.
      Add pv to vg->pvs after check for maximum value of vg->extent_count.
      Refactor _read_pv() code that updates vg->extent_count and vg->free_count.
      Refactor format1 vg->pvs list add and vg->pv_count.
      Add add_pvl_to_vgs() - helper function to add a pv to a vg list.
      Update WHATS_NEW
      Check for duplicate paths (pvids) on the commandline of vgcreate.
      Remove unnecessary parameter from import_pool_pvs().
      Move increment of vg->pv_count from import_pool_vg() to import_pool_pvs().
      Add del_pvl_from_vgs() and move prototypes into metadata-exported.h
      Call add_pvl_to_vgs() and del_pvl_from_vgs() from more places.
      Use del_pvl_from_vgs() in vgreduce paths.
      Add pv->vg to solidify link between a pv and a vg.
      Update WHATS_NEW
      Fix teardown in t-pvcreate-operation-md.sh nightly test.
      Add missing readline linkage to lvm2app test.
      Use vg->vgmem to allocate vg/lv/pv string properties instead of dm_malloc/fr
      Change lvm2app version number from 1 to 2.
      Add device creation to basic nightly test.

Fabio M. Di Nitto (1):
      Fix clvmd init script stop function to not deactive non-clustered volume groups.

Jonathan Earl Brassow (52):
      Initial import of the cluster log daemon from the 'cluster' repository.
      - Updating cluster log with latest code changes/bug fixes before
      Rebasing the cluster log daemon code from the most current
      After rebasing the cluster logging code, adjustments need to be
      Making adjustments to go along with the changes to the kernel.
      Remove old custom list macros and replace with libdevmapper list
      Cluster log daemon (clogd): use LVM bitops in place of ext2 bitops
      cluster log daemon (clogd): Add to LVM build system
      update WHATS_NEW
      mirror table generating code:  Properly handle 'block_on_errors' and 'cluster' features
      configure script:  A couple unwanted changes snuck in.
      Cluster log server (clogd):  Add new build files.
      cluster log daemon (clogd): Adjust for kernel CTR arg reordering
      '_emit_areas_line' returns 1 for success and 0 for failure.  This always
      I saw this in a bug report:
      Clarify message:
      s/=/==/  Typo was causing sub test to always return success.
      The patch fixes some lvconvert issues (WRT mirror <-> mirror).
      - forgot to update WHATS_NEW along with bug fix for keeping
      This patch adds the capability to split off a mirror legs.
      udpate WHATS_NEW file for --splitmirror checkin
      Add the new mirror log type "redundant".  The options are now:
      update comment
      Found 2 problems with my previous check-in:
      Testsuite updates and fixes for recently added features.
      Add new test cases for mirrors that are under snapshots.
      Off-by-one count was causing not all the mirror table parameters
      At some point "clustered_[core|disk]" was changed to "clustered-[core|disk]".
      udpate WHATS_NEW*
      When moving the cluster log server into the LVM tree, the in memory
      Make the intermachine communication structures architecture independant
      initial cmirrord man page
      Initial version of the cmirrord init script
      Use tabs, not spaces.
      Fix some compiler warnings.
      Fill in a little more on the man page for cmirrord
      a little more information for the cmirrord man page
      Was using dm_list_iterate_items when I should have been using
      Adding a new mimage (leg/copy) to a mirror behaves differently
      Add ability to create mirrored logs for mirror LVs.
      For the mirror repair tests, we should use --ignoremonitoring because
      We only need one extent for the mirror log.  So, when specifying
      Arguments to the --mirrorlog option are described in the synopsis as
      Disallow the primary mirror image from being removed when the
      Disallow the addition of mirror images while a mirror up-convert
      The following tests in the testsuite have race conditions:
      Patch to fix bug 586021 and mantain historical behavior of
      Fix comment from last commit.  Additionally, there is no need
      Don't attempt to convert the log type of an LV if the LV
      Test all combinations of mirror conversion, both while the LV
      If we are checking if '--nosync' was called with the mirror argument,
      Disallow toggling the cluster attribute of a volume group if there

Mike Snitzer (68):
      Switch status from 32-bit to 64-bit
      Add a [--poll {y|n}] flag to vgchange and lvchange to control whether
      Return error to dm_tree_preload_children() and
      Return error to dm_tree_suspend_children() callers.
      Return error to dm_tree_deactivate_children() callers.
      Add missing 'stack;' for all suspend_lv and resume_lv callers.
      Add missing 'stack;' for all activate_lv and deactivate_lv callers.
      Use snapshot metadata usage to determine if snapshot is empty
      update WHATS_NEW and WHATS_NEW_DM with previous commits' changes
      . update documentation for --poll in the vgchange and lvchange man pages
      Change background polldaemon's process name to "(lvm2)".
      remove unused variable 'i' that was recently introduced in lv_add_segment
      Reset _vgs_locked in lvmcache_init()
      remove errant comment fragment
      Only allow one return from poll_daemon().  If a child polldaemon was
      Add 'SNAPSHOT_MERGE' lv_segment 'status' flag.
      Add support for "snapshot-merge" target.
      Conditionally push down either the "snapshot-origin" or
      Merging device is loaded with "-cow" suffix and with base name of the
      Add --merge support to lvconvert to start merging a snapshot into its
      Do not allow merging over mounted logical volumes.
      Report merging snapshot as 'S' instead of 's':
      When there is merging snapshot, report percentage on the origin LV.
      Background poll for lvconvert --merge command.
      Start background polling of merging stores on:
      Reload origin if merging has stopped.
      When turning merging origin into non-merging origin, there is bad sequence:
      Merge on activate support.
      Update lvconvert manpage for snapshot --merge
      Add snapshot merge wrappers to abstract the associations and flags used
      Rename segment and lv status flag from SNAPSHOT_MERGE to MERGING.
      update WHATS_NEW and WHATS_NEW_DM to include snapshot-merge changes
      Improve target type compatibility checking in _percent_run().
      Detect case of both merging_store and cow_store supplied in
      Change dev_manager_mirror_percent()'s 'struct logical_volume *' to be
      update test/t-pvcreate-operation-md.sh attempt loading raid0.ko if raid0
      Add a common way to establish a scsi_debug-based 4K drive for use by an
      test/t-topology-support.sh requires scsi_debug from >= 2.6.31
      add test/t-snapshot-merge.sh to provide coverage of snapshot-merge support
      Add t-topology-support.sh and t-snapshot-merge.sh tests.
      Preload the origin prior to suspend IFF snapshot(s) still exist after a
      Removed inactive_table check from _lv_has_target_type.  This check
      Eliminate extra ioctls just to check open_count in _add_new_lv_to_dtree.
      Default to checking LV's progress before waiting in _wait_for_single_lv.
      move WHATS_NEW entries whose changes were made after 2.02.60 to 2.02.61
      Add %ORIGIN support to lv{create,extend,reduce,resize} --extents option
      Prepare for _get_lvconvert_vg() reuse as part of a larger lvconvert.c
      lvconvert --merge @tag support
      Switch lvconvert_single() over to using get_vg_lock_and_logical_volume()
      Add multiple snapshot lv 'lvconvert --merge @tag' support via process_each_lv().
      Remove false "failed to find tree node for <lv>" error from _cached_info().
      Add 'fail_if_percent_unsupported' arg to _percent() and _percent_run().
      Add 'fail_if_percent_unsupported' arg to _percent() and _percent_run().
      Refactor snapshot-merge deptree and device removal to support info-by-uuid
      Do not reload origin again in lv_remove_single() if it had a merging
      Handle a misaligned device that reports a -1 alignment_offset.
      testsuite: get stacktrace if test drops core
      Don't allow resizing of internal logical volumes.
      Improve activation monitoring option processing
      Revert having clvmd consult the lvm.conf "activation/monitoring".
      Fix clvmd cluster propagation of dmeventd monitoring mode.
      Use a real socket for singlenode clvmd to fix clvmd's high cpu load.
      Do not allow {vg|lv}change --ignoremonitoring if on clustered VG.
      Add additional test to start the snapshot merge (which had just failed
      Re-enable t-topology-support.sh
      When removing a snapshot avoid preloading the origin if the
      Remove redundant check in _lvs_single now that the caller
      Disallow the direct removal of a merging snapshot.

Mikulas Patocka (2):
      Don't kill the parent if debugging.
      A missing space in the error message.

Milan Broz (195):
      Fix lvm2.static build.
      Remove status=noxfer from test, not all dd versions support this (RHEL4 for example).
      Fail add tree node when requested major/minor is used.
      Calculate mirror log size instead of hardcoding 1 extent size.
      Do not issue write behind lv size.
      Fix "Calculate mirror log size" commit, the le_count should be always set.
      Fix lvmdump /sys listing to include virtual devices directory.
      Fix problems with static build
      Use tools.h in for lvm-static.
      Fix pvs segfault when pv mda attributes requested for not available PV.
      Separate PV label attributes which do not need parse metadata when reporting.
      Fix lvm.static build dependence (to properly propagate changes in libdevmapper).
      Comment out pvcreate pagesize alignment test for now.
      Fix validation of dataalignment value introduced in previous commit.
      Try to avoid full rescan if label scan is enough.
      pe_start can be overwritten in VG metadata, so it is not PV label-only field.
      vgname_from_mda now tries to parse for vgname even
      Fix possible increasing in memory allocation if refreshing_context
      Fix clvmd build after liblvm commit.
      Fix lv_count when manipulating with snapshots and max_lv is set.
      Fix warning in previous commit.
      Fix segfault for vgcfgrestore on VG with missing PVs.
      fix some issues when compiling with -D DEBUG_POOL
      Add some more special chars for device name test.
      Do not use pointer from released memory pool (cmd->cmd_line).
      Allocate new pv->vg_name from pool, it can be destroyed later.
      Fix debug pool grow object to properly support delta=0
      Fix memory pool leak.
      Use pv from newly read_vg to avoid possible use of not initialized memory.
      Enable use of cached metadata for pvs & pvdisplay.
      Fix mirror log convert validation question.
      Always return exit error status when locking of volume group fails.
      Properly copy the whole pv structure for later use.
      Helper function to catch memory pool leaks.
      Introduce memory pool per volume group.
      Properly release VG memory pool in activation code and clvmd.
      Properly release VG memory pool in archiver code.
      Properly release VG memory pool in metadata manipulation code.
      Properly release VG memory pool in all CLI tools.
      Fix dmsetup.static build.
      Add MMC device type to filters.
      Fix pvs -a for segmented output
      Fix pvseg report for orphan PVs and other devices.
      Tidy lv_hash[_lock] use inside clvmd.
      Move metadata backup call after vg_commit.
      Alloc PV internal structure from VG mempool if possible.
      Fix remote metadata backup for clvmd
      Clean a lot of extra extra whitespaces.
      Fix vgreduce --removemissing failure exit code.
      Fix pool leak in lvmcache_read_vg error path.
      Use zalloc in initialization of device manager (to zero pvmove mirror count).
      Fix PV datalign when for values starting prior to MDA area.
      Do not use generic install if running install_device-mapper.
      Fix device-mapper static build targets.
      Introduce lvm2_install target.
      Fix previous commit (scripts/Makefile targets order)
      Fix first_seg() call for empty segment list.
      Remove snapshot_count from VG and use function instead.
      Fix snapshot segment import to not use duplicate segments & replace.
      Remove vg->lv_count and use counter function.
      Tidy format1 import LV function.
      Introduce link_lv_to_vg and unlink_lv_from_vg functions.
      Fix lv_is_visible to handle virtual origin.
      Introduce lv_set_visible & lv_set_invisible and use lv_is_visible always.
      Merge lv_is_displayable and lv_is_visible.
      Remove unneeded import parameter from lv_create_empty.
      Check max_lv on only place and force the check only for new volume.
      vgcfgrestore should not quietly fail when backup file has missing PVs.
      Use PV UUID in hash for device name when exporting metadata.
      If pvmove fails activating mirror volume, try restore to previous state.
      Fix compilation warning.
      Use lvconvert --repair in dmeventd DSO (mornfall)
      Fix lvconvert check for multiple-segment mirrors (mornfall)
      Add infrastructure for queriying for remote locks.
      Use suspend with flush when device size was changed during table preload.
      Use lock query instead of activate_lv_excl
      Use readahead of underlying device and not default (smaller) one.
      Fix readahead test.
      Fix locking query compatibility with old external locking libraries.
      Temporary disable one of lvconvert tests.
      Fix readahead calculation problems.
      Fix log allocation segfault (fix previous commits).
      Fix convert polling to ignore LV with different UUID.
      Fix rename of active snapshot with virtual origin.
      Build shared parts with 'make' command (mpatocka)
      WHATS_NEW!
      Use lvconvert --repair instead of vgreduce in mirror dmeventd DSO (mornfall)
      Fix double releasing of vg when repairing of vg is requested.
      Suspend virtual origin before real snapshot.
      Fix various problems in tests
      Round readahead more inteligently and print warning.
      Fix the same readahead rounding in lvcreate.
      Support crypt segment in libdevmapper tree.
      Unlock vg when requested automatic update failed.
      Unlock VG in recover_vg if metadata read failed.
      Fix compiler warning.
      Re-instate partial activation support in clustered mode. (mornfall)
      Fix WHATS_NEW - Allow metadata correction even when PVs are missing.
      Fix memory leaks in toolcontext error path.
      Fix lvconvert to not poll mirror if no conversion in progress.
      Destroy toolcontext on exit in clvmd (fixes memory pool leaks).
      Do not fork daemon when dmeventd cannot be found.
      Suggest use lvchange --resync when up converting not yet synced mirror.
      Add WHATS_NEW items.
      Properly destroy toolcontext.
      Fix backward compatibility for major:minor query.
      Fix segment import functions to print segment name and logical volume name.
      Fix confusing metadata syntax error messages.
      Fix and precise metadata read errors for segment areas.
      Enable use of new multi-segment registration for static registration too.
      Fix uuid warning in pvcreate to use terminated (and dash formatted) UUID string.
      Fix global locking in PV reporting commands (2.02.49).
      Do not run mdadm tests if MD module is not loaded.
      Return fail if lv_deactivate did not removed device from kernel.
      Recognise DRBD device part and handle it similar to MD devices.
      Fix lvcreate processing of %PVS argument.
      Fix compilation warning:
      Fix install_device-mapper Makefile target to not build dmeventd plugins.
      Fix pvmove region_size overflow for very large PVs.
      Never activate hidden volumes directly in vgchange.
      Revert vg_read_internal change, clvmd cannot use vg_read now. (2.02.55)
      Fix memory lock imbalance in locking code.
      Return error status if vgchange fails to activate some volume.
      Refresh device filters before full device rescan in lvmcache.
      Move persistent filter dump to more appropriate place.
      Do not try to unlock VG which is not locked.
      Add missing vg_release to pvs and pvdisplay to fix memory leak.
      Use locking_type 3 (compiled in cluster locking) in lvmconf.
      Do not allow creating mirrors of more than 8 images.
      Fix memory leak in lv_info_by_lvid
      Fix tools to report error when stopped by user.
      Print error if VG already exist.
      Fix pvmove test mode to not fail and do not poll.
      Fix memory lock imbalance in lv_suspend if already suspended.
      Remove newly created log volume if initial deactivation fails.
      Get rid of hardcoded 0xffdf cluster lock flag.
      Get rid of magic masks in cluster locking code.
      Get rid of magic masks in cluster locking code - clvmd part.
      Allow implicit "convert" to the same lock mode.
      Allow implicit lock conversion for pre/post callbacks.
      Never ever use distributed lock for LV in non-clustered VG.
      Add memlock information to do_lock_lv debug output.
      Allow manipulation with precommited metadata even when a PV is missing.
      Fix missing include.
      Use more descriptive variable name for temporary layer lv.
      Call explicitly suspend for temporary mirror layer.
      Remove missing flag if PV reappeared and is empty.
      Drop metadata cache after device was autorepaired and removed from VG.
      Explicitly use non-clustered vgcreate in test.
      Fix previous vgcreate commit to not call unpaired unlock.
      Resume volumes in reverse order to preserve memlock pairing.
      Do not set precommitted flag in cache when precommitted metadata does not exist.
      Properly decode flags even for VG locks.
      Move processing of VG locks to separate function (similar to LV locks).
      Add possibility to handle precommitted metadata in lvmcache.
      Proper mask lock mode for vg lock.
      Propagate commit and revert metadata event to other nodes in cluster.
      Use fixed buffer to prevent stack overflow in persistent filter dump.
      Remove empty "repaired" devices if empty in lvconvert.
      Rename mirror_device_fault_policy to mirror_image_fault policy
      Fix clvmd automatic target module loading crash.
      Never scan suspended devices in clvmd.
      Move error message to locking constructor and print
      Fix exported symbols for lvm2 dmeventd wrapper.
      Fix syslog prefix in the first message (dmeventd->lvm).
      Switch memory debugging off for now if compiled with dmeventd,
      Document undocumented commits which fixed some bugs.
      Fix syntax error in cmirror init script
      Fix return code of info callbacks.
      Unlock shared lock if activation calls failed.
      Add some missing vg_revrts calls when pvmove aborts.
      Always query device by using uuid only and not name in clvmd.
      Fix pvmove abort when temporary mirror fails to be cluster-aware.
      Always query device by uuid only.
      Remove lvs_in_vg_activated_by_uuid_only call.
      Add --showkeys parameter description into dmsetup man page.
      Add --help dmsetup option as the synonym for help command.
      Fix clvmd Makefile to not overwrite LIBS from template definition
      Fix pvcreate device check.
      Disable long living process flag in lvm2app.
      Use hash table for quick lv reference when reading metadata.
      Remove vg_validate call when parsing cached metadata.
      Optimise PV segments search.
      Do not traverse PV segment list twice.
      Fix all segments memory is allocated from vg private mempool.
      Always use blocking lock for VGs and orphan locks.
      Wipe dm-ioctl parameters in memory after use.
      Mask LCK_HOLD flag in cluster VG locks for compatibility reasons.
      Remove -n argument from vgcfgrestore.
      Currently if clvmd is running and user issues vgscan,
      Do not print encryption key in message debug output.
      Skip also special lvm devices in scan (if ignore suspended is used).
      Fix device_is_usable to properly detect only internal LV names.
      Fix empty layer detection is scan devices.
      Another one internal device layer fix...

Peter Rajnoha (73):
      Fix segfault when using -U, -G and -M options in dmsetup.
      Fix wrong arg in lv_is_virtual_origin call while creating snapshots.
      Fix a typo in udev rule (splitname, NOT namesplit)
      '--noudevsync' -- update relevant man pages
      Add --noudevsync option for relevant LVM tools.
      Add --noudevsync option for relevant LVM tools.
      Forgotten '%s' in one of _mk_link warning messages.
      Detect udev problems in _rename_dev_node.
      Fix failure situations in dm_task_run for udev sync.
      Add 'udevcomplete_all' command for dmsetup. Export DM_COOKIE_MAGIC in libdevmapper.h.
      Add 'udevcookies' command for dmsetup.
      Rename template rule file 11-dm-permissions.rules to 12-dm-permissions.rules.
      Remove 11-dm-permissions.rules (is now in 12-dm-permissions.rules).
      Fix semaphore includes in dmsetup for udev sync.
      Use new blkid instead of vol_id in udev rules.
      Fix Makefile to take into account dmsetup's reconfiguration.
      Add y|--yes option for dmsetup to provide a default 'YES' answer to questions.
      Add libudev configuration check.
      Check that udev is running and set internal state appropriately.
      Add one define that is necessary for older (experimental) libudev to work.
      Several changes in udev rules:
      Add manpage entry for dmsetup's udevcomplete_all and udevcookies commands.
      Move dm_cookie_supported check into dm_udev_get_sync_supprt function.
      Add some advisory comments for users in 12-dm-permissions.rules.
      Add more hints in 12-dm-permissions.rules. Add 'dmsetup splitname' and 'y|--yes' to dmsetup manpage.
      Use the same default umask for /dev dirs (DM_DEV_DIR_UMASK).
      Just a cleanup from previous commit. We don't need pvname local var in _activate_lvs_in_vg anymore...
      Add udev flags support in libdevmapper and provide 'dmsetup udevflags' command to decode them.
      Use udev flags support in LVM and provide dm_tree_add_new_dev_with_udev_flags wrapper for dm_tree_add_new_dev.
      Use udev flags in the rules and cleanup the rules:
      Add manpage entry for dmsetup udevflags.
      Rename 11-lvm.rules to 11-dm-lvm.rules and 12-dm-disk.rules to 13-dm-disk.rules.
      Several changes to udev support code:
      Cleanup of previous commit with latest changes in udev support code.
      More cleanup in udev rules:
      Remove 'last_rule' from udev rules.
      Support udev flags even when udev_sync is disabled or not compiled in.
      Give better message for pvmove when all data on source PV is skipped.
      WHATS_NEW for previous commit.
      Disable udev rules on change event with DISK_RO=1.
      Add --noudevrules option for dmsetup to disable /dev node management by udev.
      Add activation/udev_rules config option in lvm.conf.
      Always set environment variables for an LVM2 device in 11-dm-lvm.rules.
      Add support to disable udev checking: DM_UDEV_DISABLE_CHECKING=1 env. variable.
      Add support to disable udev checking: LVM_UDEV_DISABLE_CHECKING=1 env. var.
      Enable udev_sync and udev_rules in lvm.conf by default while running tests.
      Define {DM, LVM}_UDEV_DISABLE_CHECKING=1 env. variables for tests.
      Show a warning message when libudev not found and we're using --enable-udev_sync.
      Substitute UDEV_SYNC value for use in the other files and show a warning message when libudev not found and using udev_sync.
      This is related to liblvm and its lvm_list_vg_names() and lvm_list_vg_uuids() functions
      Rename "stat" to "status" in dmeventd_snapshot.c.
      Several changes in dmsetup and libdevmapper:
      Don't use LVM_UDEV_DISABLE_CHECKING environment variable anymore.
      Use udev transactions in testsuite.
      Update man page for dmsetup: --udevcookie, udevcreatecookie and udevreleasecookie.
      Remove hard-coded rule to skip _mimage devices in 11-dm-lvm.rules.
      Add LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES environment variable to suppress error
      Add support for ioctl's DM_UEVENT_GENERATED_FLAG.
      Strictly require libudev if udev_sync is used.
      Autoreconf.
      Export and use only valid cookie value in test suite.
      UDEV_SYNC_SUPPORT, not UDEV_SYNC!
      Use UUIDs instead of names while processing event handlers.
      Allow VGs with active LVs to be renamed.
      Do not reset position in metadata ring buffer on vgrename and vgcfgrestore.
      Set appropriate udev flags for reserved LVs.
      Also include udev libs in libdevmapper.pc when udev_sync is enabled.
      Add support for new IMPORT{db} udev rule.
      Don't run any complex initialisation for the "version" lvm2 command.
      And be consistent with return code as well (previous commit).
      Synchronize "remove" dm task while reverting unsuccessful "create" dm task
      Specify exactly which ioctl doesn't have a cookie set (for better debugging).
      Add new --sysinit option for vgchange and lvchange.

Petr Rockai (130):
      Use $(abs_top_builddir) instead of @DMDIR@ and update paths appropriately.
      Also report the tests that have been skipped, at the end of harness.sh.
      Fix typo.
      Set LD_LIBRARY_PATH in init.sh, as it is required to run dmsetup now as well,
      Explicitly check after lvremove -ff vg that it did its job. By jstava.
      Use separate locking directory for each of the tests, as they never share a
      Add bz186013 check -- lvcreate rejects an invalid regionsize (jstava).
      bz429342 lvcreate --nosync
      add bz264241 check
      Minor code and documentation cleanups and changes by jstava.
      Fix t-pool-labels to pass again after the vgdisplay error return fix from
      Include libdm in lcov reports.
      Import a bunch of new tests by jstava. Mostly everything pass, they however
      Add a bunch of sub-tests aimed at testing various bugzillas, by jstava.
      Document current state of inconsistent metadata behaviour of a few commands in
      Fix some checks in lvm-utils.sh. Note that "$(test ...)" is always empty, since
      A C implementation of "not" that handles fatal signals rather more
      Re-implement the test harness in C. This lets us pass through signals and
      Only fail when tests have failed, but not when they have been just skipped.
      Fix test output collection in harness.c.
      In testsuite's not.c, print a notice when program dies of a fatal signal.
      Detect and wipe swap signatures in pvcreate.
      Some extra (paranoid) checks on dev_is_{md,swap} result.
      Missed file from previous checkin.
      Do not include MISSING_PVs in allocation maps.
      A more thorough PV equality test (that also copes better with MISSING_PVs) in
      Refuse adding missing PVs in create_pv_list in toollib when allocatable_only is
      Implement, test and document (first iteration of) lvconvert --repair.
      Avoid scanning non-PV devices in functional tests, otherwise lvconvert --repair
      Update WHATS_NEW wrt a recent patch.
      Complain when lvconvert --repair is used on non-mirror LV.
      Allow metadata correction even when PVs are missing.
      - Ignore suspended devices during repair (Milan).
      Get rid of the mdadm presence check in t-000-basic: no actual test uses
      Refuse to open VG with MISSING_PVs for update unless handles_missing_pvs is set.
      Take just a read lock when activating in lvchange.
      Remove lockingfailed().
      Port process_each_pv to new vg_read.
      Fix bad prototype from previous checkin.
      Un-export vg_read_internal.
      Fix warning.
      Update synopsis in lvconvert manpage to mention --repair.
      Allow LV suspend while --ignorelockingfailure is in force.
      Add test for RHBZ 481793 (passing, thanks to vg_read changes checked in
      Slightly refactor mirror log conversions in lvconvert.
      Make lvconvert honour log mirror options combined with downconversion.
      Refactor file locking, lifting the flock wrapper code into separate
      Make lvchange --refresh only take a read lock on volume group.
      Implement write lock prioritisation for file locking and make it default.
      Do not override the distclean target in liblvm's Makefile, it annoys make and
      Handle metadata with unknown segment types more gracefully.
      Fix the "const discarded" warnings introduced in the unknown segment patch.
      Only announce mirror monitoring to syslog after initialisation succeeds.
      Rudimentary support for running testsuite in a builddir != srcdir situation.
      Issue an Internal error message whenever _memlock_count drops below 0.
      Add an extra memlock_inc() to _remove_mirror_images to properly balance
      Fix another bug in memlock handling, this time the "global" dmeventd memlock
      What's new.
      Fix the dmeventd LD_LIBRARY_PATH in the testsuite.
      Add a missing #include (fix compiler warning).
      Un-export vg_read_internal.
      The double resume in remove_mirror_images does not happen *always*. Only call
      In case we refuse to continue due to missing PVs, print a hint about using
      Add a basic test for snapshots of mirrors, thanks to Jon Brassow.
      More fixes for the testsuite in the $(builddir) != $(srcdir) situation.
      Fix test/api to work with srcdir != builddir.
      Don't fail in the builddir == srcdir case, though. (testsuite)
      The sourcedir instances of the test scripts are not PHONY.
      Optionally abort on internal errors (and leverage this option in the
      If aborting due to an internal error, always print the message causing this.
      #define an INTERNAL_ERROR macro and use it throughout LVM.
      Revert unintended change that slipped in with last checkin.
      Also clean up MISSING devices in --removemissing --force in vgreduce.
      Fix removal of multiple devices from a mirror (+ regression test).
      Revert another unintended change that snuck in.
      In lvconvert --repair --use-policies, for the allocate policies, return success
      Allow vgremove of a VG with PVs missing.
      Make lvconvert --repair --use-policies exit with success when no action is needed.
      In testsuite, catch also failures that happen in the middle of a pipeline.
      Relax a check on blkid exit value, which seems to be different in different
      Add _mlog devices to dependency trees using UUID, not name, in activation.
      Add infrastructure for running the functional testsuite with locking_type set
      Skip locking_type 3 tests instead of failing when system-wide clvmd is running.
      Run both locking_type 1 and 3 tests (forgot to uncomment locking_type 1 before
      Also honour abort_on_internal_errors when log_fn is set.
      When a scsi_debug modprobe fails, skip the test instead of failing it.
      Enforce distinct-PV allocation of snapshot/origin pairs in vgsplit test.
      Work around a problem in t-mirror-lvconvert: different PV order on the
      Re-run failing tests with log/verbose=4 (-vvvv) to help with debugging.
      Do not pass NULL to setenv in the test harness.
      Put back the `lvconvert -m+1 --mirrorlog disk' test in t-lvconvert-mirror.sh.
      Move a fragile testcase toward the end of t-mirror-lvconvert.sh.
      Keep the testsuite stats correct in spite of failed-test repetition.
      In test harness, use fwrite(3) in place of write(2) to avoid mixing fd-level
      Refactor the test utilities, dropping the legacy test-lib.sh and curtailing
      Avoid spurious skips in the testsuite due to obsoleted
      Set ulimit -c to unlimited to allow coredumps to be collected and analysed in
      Fix a mis-override of $PWD in test-utils.sh.
      Don't forget to cd into $TESTDIR in test-utils.sh / prepare_testdir.
      Do not pollute /tmp with testing byproducts.
      Add a new helper script for the testsuite, that makes checking for various
      Explode t-mirror-basic into a number of smaller tests.
      Absorb t-mirror-lvconvert-usage into t-lvconvert-mirror.
      More testsuite helpers for check.sh.
      For the testsuite, set a default polling interval to 0 in lvm.conf. Cuts down
      Fix t-lvcreate-usage, as lvcreate ... -i1 no longer prints "Redundant stripes
      Make it easy to run just a subset of tests by saying `make check T="regex"`.
      Disable the rather-dangerous prepare_scsi_debug_dev in the testsuite.
      Optionally disable the verbose repeat of a failed test (export
      Fix a reversed exit status from test harness.
      Process all core dumps that exist upon a test failure (this would hopefully
      Add check_cluster and check_local targets in addition to just "check".
      SIGTERM testing clvmd before SIGKILL-ing it.
      Allow incomplete mirror restore in lvconvert --repair upon insufficient space.
      What's new.
      Add a "should" alongside "not" to the test utilities. When a "should" command
      Suppress duplicate error messages about read failures and missing devices.
      What's new.
      Add some basic provisions for automated testing of dmeventd.
      Add a basic test for dmeventd triggering lvconvert --repair. Needs improvement.
      Improve the "check" testing utility: slightly refactor and provide
      The "should" testing utility should actually only give a warning when the
      Rename t-partial-activate to t-activate-partial (more activation tests coming).
      Add a test for activation in presence of missing devices. This partially covers
      Revert the huge device creation in t-lvconvert-mirror and downgrade the
      A fairly extensive refactor of the mirror testing code. The exhaustive
      Revert the "repeat failed tests with -vvvv" feature. Instead, dump debug logs
      Bump the debug.log level from 4 to 9 (the numbering is different from verbose).
      Run tests in alphabetical (and thus stable across machines) order.
      Chop up the big t-lvconvert-mirror-basic loop across 4 separate test scripts

Zdenek Kabelac (64):
      mlockall() -> mlock()
      Use '_' prefix for local static variable.
      Unconditionaly ignore also Virtual Dynamically-linked Shared Object
      Use mlock() only on 'r' memory maps
      Update comments for selecting maps
      Remove const modifier for struct volume_group* from process_each_lv_in_vg().
      Move declaration of struct dm_info info to declaration block.
      Updates .so links for plugins
      Fixing compilation warning: implicit declaration of function ???umask???
      Avoid hard sed replacement - i.e. quick test change in make.tmpl
      Add $(LIB_STATIC) to TARGETS so it's cleaned in the same way
      Use $(top_srcdir) for sources and add cscope.out to distclean targets.
      distclean fixes
      Update cflow file generation - support build dir and use $(top_srcdir)
      Fixing another set of distclean problems where we left some generated files
      Split long line in Makefile and keep $abs_top_buildir as shell variable
      Avoid modification of .in files outside man directory.
      Oops, avoid returning errors from shell to makefile for builddir == srcdir
      Fix also error code from clean:
      Remove mlockall() form dmeventd
      Fix resouce leak in error path
      Release pool in the same reversed order
      Updated syslog messages
      Force C locale
      Update memlock
      Count only readable size for memlock stats.
      Update for dmeventd changes.
      Use .commands created in builddir for symlink installation.
      Install generated 10-dm.rules from builddir.
      Update for make install.
      Missed to convert T -> SCRIPTS
      Set ret value to success initially.
      Better debug message for Un/Locked memory size.
      Fix lcov target
      Distcleanup config files only in toplevel directory.
      As lcov module is not installed with GD.pm dependency we need
      Using 'not' if the test 'should' fail.
      Add cleandir target.
      Use vpath instead of VPATH.
      INSTALL rules updates
      Update install rules for udev.
      Use C locales and use_mlockall for clvmd.
      Add error diagnostic for setenv failure.
      Added awk script relpath.awk to calculate relative paths.
      Fix double DESTDIR usage for infodir and mandir.
      Install symbolic .so links with relative paths between usrlibdir and libdir.
      Make matcher_t and parse_t compilable
      Small indent change
      Show string with invalid pattern
      Release pools for regex if there is error during processing
      Initialise _vginfos list staticaly so there is no problem with using uninitialised
      Install plugins to subdirs
      Add dm_list_splice() to join two lists.
      Headerfile <pthread.h> is no longer needed here
      Link liblvm2cmd.so with devmapper-event and devmapper libs.
      Link libdevmapper-event.so with libdevmapper.so.
      Plugins do not use pthread or lvm2cmd directly.
      Skip unneeded 'cat' command execution.
      Use Require.private: field for devmapper-event.pc
      Add UDEV_PC and SELINUX_PC substituted variables
      Switch to use Requires.private for devmapper.pc and lvm2app.pc
      Add pkgconfigdir for placement of .pc files
      Use /bin/bash for scripts with bashisms
      For lcov target there is no need to include source file dependencies

Zden??k Kabel???? (20):
      * minor compilator warning fix for improper function declaration.
      removed redundant redeclaration of init_indent() and init_msg_prefix() from lvm-logging.h
      minor compiler warning fix for function declaration prototype
      cleaner const char* usage for last_path_component()
      fix missing const char*
      daemons depends on liblvm2cmd - fixes parallel builds
      add simple test for dev node usability (detect devices mounted with nodev)
      operate on test subdirectory instead on main /dev
      Replace _dm_snprintf with EMIT_PARAMS macro for creating target lines
      add support for ext4 resize in fsadm
      Remove external dependency on the 'cut' command in fsadm
      Fixed bug where lvresize option -t was not properly passed to fsadm.
      Do not create some dm and lvm static librarie when they are not requested
      Avoid referencing files from DESTDIR during build process
      Do not query nonexistent devices for readahead.
      Use 'lvm lvresize' instead of 'lvresize' in fsadm.
      Minor replace of of ${top_srcdir} with $(top_srcdir) for lcov target
      Run distclean also for daemons/cmirrord
      Remove daemons/clogd from distclean dirs (replaced with cmirrord)
      Update distclean target for rename clogd to cmirrord. (2.02.52)

fabbione (8):
      Remove unwanted Makefiles and don't purge lvm2.po that's
      Fix --with-clvmd=all to deal with the case where no cluster managers are available.
      Drop clogd Makefile from CVS since it's always autogenerated from Makefile.in
      Fix cmirrod build directory while we wait to do a proper rename of the
      Merge Debian patch 05 debian: keep libdm-abi consistent.
      Disable realtime support by default.
      configure.in: don't set default file owner and group
      - fix whitespaces all over (tabs/spaces)

mpatocka (4):
      Suppress warning on 64-bit big-endian computers (Sparc 64).
      Change exit() to _exit() in the child process. exit flushes stdio file buffers,
      WHATS_NEW
      Pass struct cmd_context as a first argument to init_multiple_segtypes.

prajnoha (6):
      Added displayable_lvs_in_vg and lv_is_displayable functions to deal with
      Fix vgrename using UUID in case there are VGs with the same name.
      Fix incorrect return value in help function.
      Add "--refresh" functionality to vgchange and vgmknodes.
      Add "--refresh" functionality to vgchange and vgmknodes.
      Add checks for device names in dmsetup and show proper error messages.

snitzer (27):
      Add vgimportclone and install it and the man page by default.
      Fix rpmlint in clvmd initscript
      Fix 'service-default-enabled' rpmlint in clvmd initscript
      Various vgimportclone fixes:
      Use the MD device's stripe-width, instead of chunk_size, to align the
      Allow commandline sizes to be specified in terms of bytes and sectors.
      Reword the WHATS_NEW commandline sizes update.
      Continue to make --units and --size consistent (in code and man pages):
      Add extended device (blkext) and MD partition (mdp) types to filters.
      Check MD devices for a partition table during device scan.
      Cast MAJOR() and MINOR() to int when used with "%d" in dm_snprintf() call.
      Cast MINOR() in _md_sysfs_attribute_snprintf()'s dm_snprintf() call.
      Formalize pe_start policy as split between .pv_setup and .pv_write.
      Fix _mda_setup() to not check first mda's size before pe_align rounding.
      Remove legacy support for preserving pe_start if a PV already has data
      Preserve pe_start in .pv_setup and .pv_write if pe_start was supplied.
      Add --dataalignmentoffset to pvcreate to shift start of aligned data area
      Revert 'preserve_pe_start' related code in _text_pv_setup
      Disable the "new pe_start policy"
      Fix compile warnings from recently added log_very_verbose() in _text_pv_write()
      Add devices/data_alignment_offset_detection to lvm.conf.
      Add devices/data_alignment_detection to lvm.conf.
      Improve ability to lookup primary device associated with a partition
      Retrieve MD sysfs attributes for MD partitions
      Fix error handling of device-related stat() calls to be ENOENT aware.
      Added basic pvcreate --dataalignmentoffset testing to t-pvcreate-usage.sh
      Fix pvcreate on a partition (regressed in 2.02.51).

taka (6):
      Fix error message when adding metadata directory to internal list fails.
      Fix size and error message of memory allocation at backup initialization.
      Remove old metadata backup file after renaming vg.
      Restore log_suppress state when metadata backup file is up-to-date.
      Fix error message when archive initialization fails.
      Save and restore the previous logging level when log level is changed.

twoerner (2):
      Added files lib/lvm.h and lib/lvm_base.c:
      Fix include/.symlinks for lvm2.h to lvm.h renaming

zkabelac (50):
      Add fflush for the case the log is redirected to the buffered file.
      Export functions out_inc_indent(), out_dec_indent() for creating
      Update for outnl and indent functions
      minor code comment update
      minor whitespace indentation
      skip cast from (void*)
      minor indent change
      Fix coredump and memory leak for 'dmsetup help -c'
      Fix unlocking vg in some pvresize and toollib error paths.
      Destroy allocated mempool in _vg_read_orphans() error path.
      Cleanup returns for void functions.
      Fix typo  fsdam -> fsadm   (closes bug 552721)
      Just add '.' at the end of error message.
      Show all fields for 'dmsetup info -c -o all'.
      Error message prints unrecognized key.
      Use offsetof() macro and avoid defining dummy static union for FIELD() macro.
      Add macros outsize() for out_size() and outhint() for out_hint() that check
      Export function out_text_with_comment() and add outfc() macro that checks
      Use macro outsize() with check for error return value.
      Add few const modifiers.
      orig_status preserves 64bit status.
      lvol%d is generated for NULL name in lv_create_empty().
      Move initialization of the 'cmd' member of the struct alloc_handle
      Cleanup gcc warning: null argument where non-null required (arg.2)
      Cleanup gcc warning: cast from function call of type 'struct dm_list *'
      Cleanup gcc warning: cast discards qualifiers from pointer target type
      Cleanup const compiler warning
      Update entry for few previous gcc cleanup commits.
      Reset released pointer and counters.
      Log entry for the last lvmcmdline.c commit
      * add more 'const' - fixes gcc constness warning
      Cleanup float arithmetic gcc warning.
      Fix dm_report_field_uint64 to really use 64bit.
      * update for last 3 commits
      Use dm_report_field_int32 instead of dm_report_field_uint64 for printing '-1'
      Update
      Usage of AC_PROG_SED and AC_PROG_MKDIR_P requires autoconf version 2.61.
      Use datarootdir and fix warning during configure process:
      Use $(top_builddir) for inclusion of make.tmpl in Makefiles.
      Replace CFLOW_CMD only in make.tmpl and use it as variable elsewhere.
      Use consistently $() instead of ${} for all Makefile variables,
      This patch moves inclusion of the make.tmpl before DEFS modification,
      As fsadm is installed by default - it's a common practice to rather
      Introduce LVMINTERNAL_LIBS
      Readline linking update
      Pthread linking change
      Removes -rdynamic from linking of lvm.static and dmeventd.static.
      This patch add SELINUX_LIBS and STATIC_LIBS variables.
      Use DL_LIBS, remove -ldl from global LIBS and link -ldl only when needed.
      Use UDEV_LIBS, and link -ludev only when needed.


