From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 23 Nov 2018 03:19:33 -0500
Subject: v2_02_74 annotated tag has been created
Message-ID: <201811230819.wAN8JXe0032099@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=59310b51f33660f0196642c8424a877368e89682
Commit:        59310b51f33660f0196642c8424a877368e89682
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-11-22 16:50 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-11-22 16:50 +0000

annotated tag: v2_02_74 has been created
	    at 59310b51f33660f0196642c8424a877368e89682 (tag)
       tagging abf6c8eb4d9c460bc96b2096f2f4abc122972e1e (commit)
      replaces v2_02_65

Release 2.02.74
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJb9t5zAAoJELkRJDHlCQOfMycQALJDWKAjm2dFOacVGdw9zxAs
INJS0REM8eHPH3LLcS4vL3NnqLKWOmjH3UIldBaatZpB4i45Z0HQzqqi5w82cM5Z
CnUA2NIzmIpLIDNaVMWn/yiPphDJreKGikeI25NJJ06JCFURFNhU/XN0ClFeY/HW
UR2vQXSO5dq+BLarS8WJ4lAN5lGwNhOUDUJ4pMgsVTgE0uZB+xIt3vTL5quaJ4vY
IKipiHdpssqatFhE92BEfpJffRjPlfvhxgUiSeK3FCDParft1p2v6EO1UsHCsCOX
rmD1K0I6pPF2gz3q1h8MwQv2cGweWgTNOcU/SFY6nL7eE9tBxfYQ+SP++Rg5oZaJ
a2KDwO8Dx81O3TOxoN2D0ZdyEbau6uOBhcavaEO4e7tIU+FJaH8tUVBMAYcaUQ0X
yY8Qva1dlGlQ5hoUAj1PjOBjB7rbQIhK4uDjshHF9GnPlghQQEW6EahLJJVfdHsS
2oidmNG6VkgZbHupsRgIJBXeWbKBw/1/oR7zd4PfEv9nrTxqWilPmrV2qw+/X1Bj
FGrr0WRM+PaQR8PgpHdhuJkO87qj0mqgl5bbP1uLTSEov1wj0u/b/kerN3rHahh8
Ulnh+eXMuC4gNntQRsmOgtbpHXy+wDO4xTNcEfis81DRMtBz4BIKeoxZlB31L7gn
+KMZpvjrUccT+eTsMiXg
=OrON
-----END PGP SIGNATURE-----

Alasdair Kergon (95):
      post-release
      Use is_orphan_vg in place of hard-coded prefix tests.
      Accept orphan VG names as parameters to lock_vol() and related functions.
      Note that orphan lock is always obtained last
      Validate orphan and VG_GLOBAL lock order too.
      Add is_global_vg and split out from is_orphan_vg.
      Install lvmconf script by default.
      Generate example.conf so default lvm.conf contents can be configured.
      Add install_system_dirs makefile target.
      Add make install_initscripts
      If unable to obtain snapshot percentage leave value blank on reports.
      pre-release
      backup->cache
      Fix $(INSTALL_SCRIPT)
      post-release
      Update clustered log kernel module name to log-userspace.
      Choose between clustered log versions based on kernel version.
      Avoid selecting names under /dev/block if there is an alternative.
      Replace strncmp kernel version number checks with proper ones
      Don't merge unchanged persistent cache file before dumping if tool scanned.
      pre-release
      post-release
      Various cleanups following recent commits.
      Add lv_path to reports to offer full /dev pathname.
      In some C++ standards, typeof is not reserved.
      pre-release
      post-release
      Update liblvm2app exported symbols.
      actually, let's keep these in same order as in header
      Generate liblvm2app and libdevmapper exported symbols from header files.
      generate liblvm2cmd exported symbols too
      Improve various log messages.
      pre-release
      Only attempt to guarantee 1 mda ignored if there's at least one mda in the vg.
      post-release
      suppress useless compiler warning
      revert that
      Update partial mode warning message.
      more metadataignore message/code cleanup
      more mda ignore cleanups
      improve vgmetadatacopies unmanaged message
      Fix --[vg]metadatacopies arg processing
      Move dmeventd man page from install_lvm2 to install_device-mapper. (1.02.50)
      Fix lvm shell crash when input is entirely whitespace.  (Xinwei Hu)
      Always pass unsuspended dm devices through persistent filter to other filters.
      remove unneeded header
      Add printf format attributes to yes_no_prompt & dm_{sn,as}printf and fix a calle
      Add parentheses to some libdevmapper.h macro arguments.
      Randomly select which mdas to use or ignore.
      Fix dmlosetup snprintf %llu compiler warning.
      pre-release
      fix jumbled args in 'Adjusting' message
      shorten mesg
      s/flags/mda/
      fix code in 2nd mda unignore loop to match 1st loop
      .
      post-release
      Adjust auto-metadata repair and caching logic to try to cope with empty mdas.
      Remove superfluous fn prototypes.
      Fix redundant declarations and always compile with -Wredundant-decls.
      Use __attribute__ consistently throughout.
      update configure
      Fix dm_create_lockfile error paths - incorrectly unlinked in-use lockfile.
      .
      pre-release
      .
      day+1
      add copyright notices to new files
      Change clvmd to communicate with lvm via a socket in /var/run/lvm.   (mbroz)
      Never use clvmd singlenode unless explicitly requested with -Isinglenode.
      post-release
      Fix configure to supply DEFAULT_RUN_DIR to Makefiles.
      Drop explicit 'Base' version from exported symbols.
      Make liblvm.device-mapper wait for include file generation.
      Use #include <> not "" in lvm2app.h which gets installed on the system.
      Fix exported_symbols generation to use standard compiler arguments.
      revert the 'Base' change - that wasn't the cause of the problem
      Fix lib.device-mapper to wait for include too
      set DEFAULT_RUN_DIR (missed from earlier checkin?)
      Remove superfluous NULL pointer tests before dm_free from dmeventd.
      Various small cleanups and fixes related to monitoring.
      Don't really change monitoring status when in test mode.
      Monitor origin -real device below snapshot instead of overlay device. (brassow)
      Fix dev_manager_transient to access -real device not snapshot-origin. (brassow)
      Allow internal suspend and resume of origin without its snapshots.
      Use 'SINGLENODE' instead of 'dead' in clvmd singlenode messages.
      Attempt to fix buildbot failure in t-lvconvert-mirror.sh due to failing to
      pre-release
      post-release
      autoreconf also updates configure.h.in
      .
      Track recursive filter iteration to avoid refreshing while in use. (2.02.56)
      Fix name in msg in last checkin.
      Replace alloca with dm_malloc in _aligned_io.
      pre-release

Dave Wysochanski (100):
      Add pvid_from_devname() lvmcache function.
      Add lvmcache_vgname_from_pvid().
      Add find_vgname_from_{pvname|pvid} functions.
      Update pvchange to always obtain a vg handle for each pv to process.
      Add lvm2app interfaces to lookup a vgname from a pvid and pvname.
      Test lvm_vgname_from_{pvid|device}.
      Update WHATS_NEW
      Fix warnings with conversion of uuid.
      Remove hack in pvchange to unlock orphan VG.
      Remove another pvchange hack involving orphan VG names.
      Do not fail lvm_init() if init_logging() generates an errno.
      Revert _init_rand() to reset errno - restores original init behavior.
      Add device name to output of error messages in raw_read_mda_header().
      Change 'filler' to 'flags' in on-disk 'raw_locn' structure.
      Add text format specific 'rlocn' ignore flag and access functions.
      Add location independent flag and functions to ignore mdas.
      Move dev_open / dev_close outside _vg_read_raw_area().
      Move dev_open/dev_close outside vgname_from_mda().
      Allow raw_read_mda_header to be called from text_label.c.
      Ensure in-memory state matches on-disk state of mda ignore bit.
      Add mda_locns_match() internal library function for mapping pv/device to VG mda.
      Add mda location specific mda_copy constructor.
      Use vg_mda_count() in vgdisplay.
      Rename fid->metadata_areas to fid->metadata_areas_in_use.
      Add metadata_areas_ignored list and functions to manage ignored mdas.
      Define new functions and vgs/pvs fields related to mda ignore.
      Add --metadataignore to pvchange, allowing for ignoring of metadata areas.
      Update pvchange, pvs and vgs man pages for metadata ignore.
      Implement ignore of mda if bit set by skipping r/w of metadata.
      Add mdas_empty_or_ignored() helper function.
      Use mdas_empty_or_ignored() in place of checks for empty mda list.
      Update _vg_read and _text_create_text_instance to use fid_add_mda[s].
      Refactor vg_commit() to add _vg_commit_mdas().
      Before committing each mda, arrange mdas so ignored mdas get committed first.
      Add tests for phase 1 of metadata balance - manage per-PV ignore bit.
      Define vgmetadatacopies in vgchange man page.
      Add mda_copies to VG structures and initialization.
      Add vg get/set methods for VG metadata copies.
      Make vg->mda_copies persistent in on disk vg metadata.
      Add vg_mda_copies display field to 'vgs' command.
      Update vgchange tool to accept --vgmetadatacopies.
      Implement _vg_adjust_ignored_mdas and call from vg_write() path.
      Set vg_mda_copies when pvchange --metadataignore is given.
      Add --vgmetadatacopies to vgcreate man page, command, and lvm.conf.
      Ensure fid mda lists are populated correctly during vgextend.
      Update check in vg_split_mdas to account for ignored mdas list.
      Update _vgmerge_single() to move fid->metadata_areas_ignored.
      Add --vgmetadatacopies to vgsplit man page and command.
      Ensure --metadatacopies parameter gets interpreted based on command.
      Allow 'all' and 'unmanaged' values for --vgmetadatacopies.
      Update example.conf.in to describe vgmetadatacopies.
      Update tests to handle phase 2 (vg based) metadata balance.
      Fix compile warning in vgchange.c regarding mda_copies initialization.
      Update t-covercmd pvck to take proper device argument.
      Update WHATS_NEW for --metadataignore and --vgmetadatacopies changes.
      Attempt to fix intermittent failure with non-debug configured vgcfgbackup.
      Add more initializations of 'mda->flags' field.
      Add error message if backup_to_file fails because of empty in_use mdas list.
      Move code into pv_change_metadataignore library function.
      Add some log_verbose debug statements related to metadataignore.
      Improve logging for metadata ignore by printing device name.
      Improve logging for setting --vgmetadatacopies.
      Add --metadataignore to pvcreate.
      Update pvcreate tests for --metadataignore.
      Add pvmetadatacopies to lvm.conf and pvcreate man pages.
      Add --metadataignore to vgextend and man pages.
      Update nightly tests for vgextend --metadataignore.
      Update nightly tests for vgextend --metadataignore.
      Only attempt to guarantee 1 mda ignored if there's at least one mda in the vg.
      Refactor vg_remove_check to place pv removal into separate function.
      Check for missing_pv in vg_remove loop.
      Update metadata-balance test for --vgmetadatacopies 0.
      Minor changes to man pages for --metadataignore.
      Test failed commit of mda on new pv - failed vgextend.
      Add warning to vgextend and pvchange if metadataignore given on cmdline.
      Add prompt if using --metadataignore argument with vgmetadatacopies.
      Add --force to pvchange, and allow override of prompt involving metadataignore.
      Shorten prompt for pvchange and vgextend.
      Init mda->list in mda_copy.
      Pass metadataignore to pv_create, pv_setup, _mda_setup, and add_mda.
      Remove unnecessary list of includes in liblvm files.
      Add log_error when strdup fails in {vg|lv}_change_tag().
      Update WHATS_NEW
      Update comments about memory handling in lvm2app.h.
      More comment updates in lvm2app.h.
      Minor man page updates related to metadataignore and vgmetadatacopies.
      Clarify help text for vg_mda_count.
      Remove unneeded "active" variable in vgchange_monitoring().
      Remove irrelevant comments relating to vg_mda_copies.
      Add vg_mda_size and vg_mda_free functions.
      Add 'flags' field to columns.h and define FIELD_MODIFIABLE.
      Remove explicit double quotes from columns.h 'id' entries.
      Add macro definitions to report infrastructure for character array length.
      Add properties.[ch] to lib/report, defined based on columns.h.
      Define GET_NUM_PROPERTY_FN macro to simplify numeric property 'get' functions.
      Add implmentation for simple numeric 'get' property functions.
      Define GET_NUM_PROPERTY_FN macro to simplify numeric property 'get' functions.
      Update WHATS_NEW
      Update configure for snitm changes
      Update vg_mda_free 'get' function to multiply by SECTOR_SIZE.

Fabio M. Di Nitto (3):
      Add dm_create_lockfile to libdm to handle pidfiles for all daemons.
      Fix clvmd init script return code when executed as non-root user.
      Based on auto-detection or user requested cluster managers for clvmd,

Joe Thornber (19):
      Report generators for unit tests and memory checks.  Configure with
      Move tests from old-tests/regex to unit-tests/regex.  unit-tests will
      Wire the regex tests up to the reports
      Add a unit test for the recent changes to dm_bit_get_next()
      [UNIT-TESTS] add test for the recent dm_bitset_equal() function
      [UNIT-TEST] test for recent dm_bit_and() function
      [REGEX] add a fingerprinting facility to allow test code to compare dfas
      [REPORT-GENERATORS] cut down stylsheet.css to what we actually use
      [REGEX] another matcher_t test with a larger set of regexes, only interested in the fingerprint
      [REGEX] reduce the number of charset nodes that are produced
      [REGEX] factor _calc_state() out of _calc_states()
      [REGEX] remove the state_queue structure.
      [REGEX] calculate dfa states on demand
      [REGEX] matcher_t unit test now takes a flag to turn on fingerprinting
      [REGEX] add a unit test for regexes containing chars with value over x80
      [REGEX] Parse regexes that contain chars with value > 0x80
      [REGEX] fix bug in matcher that was causing segfault with chars of 0x80 and over.
      [MM] Make valgrind aware of the pool allocators
      [REGEX] fix a long standing off-by-one error (found by valgrind-pool)

Jonathan Earl Brassow (26):
      daemons/cmirrord/functions.c (part of cmirrord) was referencing
      Add error checking for calls to sprintf - it can fail for more
      Mirrors can be layered - as in the case of an converting 2-way
      The function that runs to compress a stacked mirror after
      Committing Taka's patch...  He found a problem during
      update WHATS_NEW file with entry for simultaneous mirror image and
      Fix for bz608048 from Taka...
      Fix for bug 607347: failing both redundant mirror log legs...
      Finish fix for bug 607347: failing both redundant mirror log legs...
      Failed to test for the case where a log was requested to be removed
      Fix for bugs: 612248 & 612291 Split mirror issues
      Fix for bug 612311: Split of linear provides no error msg
      Fix reversal of LV list before performing a split mirror.
      Fix for bug 614164: No check for existing name when splitting mirror
      It's not enough to check for the kernel module in the case of cluster
      Building without the '--enable-cmirrord' option means that
      Initial import of document describing LVM's policies
      Disallow mirrored logs in cluster mirrors.
      Taka's fix for handling failure of all mirrored log devices and
      A misunderstanding of the return value of 'dm_bit' has been causing a data
      Fix for bug 619221 - log device splitting regression
      Fix for bug 612291: dm devices of split off mirror images are not removed
      Fix for bug 596453: multiple mirror image failures cause lvm repair...
      This patch fixes a potential for I/O to hang and LVM commands
      This patch fixes a problem where the mirror polling process
      This patch fixes an issue where cluster mirror write I/O

Mike Snitzer (14):
      Document 'clear' in dmsetup man page.
      Add --type parameter description to the lvcreate man page.
      Cleanup sentences of the example provided in the vgimportclone man page
      Use more standard naming for PVs and VG in vgimportclone example.
      Avoid changing aligned pe_start as a side-effect of very verbose logging.
      Require logical volume(s) to be explicitly named for lvconvert --merge.
      Require --restorefile when using pvcreate --uuid.
      Change default alignment of pe_start to 1MB.
      fix t-pvcreate-operation-md.sh to require kernel.org Linux >= 2.6.33 for
      Add some v1 to v2 metadata upgrade testing.
      Update heuristic used for default and detected data alignment.
      Switch to using configure --with-default-data-alignment=<NUM> to
      Verify that pvcreate --dataalignment really does override the topology
      Make example.conf description for 'default_data_alignment' more generic.

Mikulas Patocka (1):
      Fix scripts/relpath.awk to work with mawk

Milan Broz (32):
      Replace lvm.conf instead of truncating it.
      Use mv -f for replace config in test.
      Fix topology test after last changes to not leak loop devices.
      Require partial option in lvchange --refresh for partials LVs.
      Fix clvmd initscript restart command to start clvmd if not yet running.
      Fix restart of clvmd using -S switch
      Fix segfault in clvmd -R if no response from daemon received.
      Remove C++ private keyword from headers.
      Fix lvm2cmd example in documentation.
      Clean up cluster lock mode and flags definition.
      Fix exit code when requesting help using documented -o help option.
      Let running clvmd process time to reexec.
      Use flexible data[] in cmirrord request to prevent abort in runtime size checks.
      Fix "allocated" warning typo.
      Fix clvmd init script status
      Fix vgremove to allow removal of VG with missing PVs. (2.02.52)
      Remove superfluous suspended device counter from clvmd.
      Fix another segfault in clvmd -R if no response from daemon received.
      Change the pvcreate swap/md logic
      Remove assumption that --yes must be used only in --force mode
      Fix file descriptor leak in swap signature detection
      Detect LUKS signature in pvcreate
      Fix wrong use of LCK_WRITE
      Fix pvmove --abort to work even for empty pvmove LV
      Fix pvmove --abort <dev> return code
      Update configure after last change.
      Fix timestamp.
      Fix return type qualifier to avoid compiler warning.
      Fix previous const removal.
      Currently tests require SI units enabled and data alignment to 1MiB.
      Do not run singlenode clvmd tests if support for singlenode not compiled in.
      Fix handling of partial VG for lvm1 format metadata

Peter Rajnoha (24):
      Use expected union semun for arguments in selected semaphore operations.
      Fix incorrect memory pool deallocation while using vg_read for files.
      Add support for dm-mod module autoload.
      Use early udev synchronisation and update of dev nodes for clustered mirrors.
      Fix udev rules to handle spurious events properly.
      Use "nowatch" udev rule for known inappropriate devices.
      Add more verbose messages while checking volume_list and hosttags settings.
      Addendum for previous patch - show VG/LV name everywhere so the messages
      Revert unsuccessful table load preparation in combined "create, load and resume" scenario.
      Add check for kernel semaphore support and disable udev_sync if not available.
      Use built-in rules for device aliases: block/ < dm- < disk/ < mapper/ < other.
      Recognise and give preference to md device partitions (blkext major).
      WHATS_NEW_DM
      Reinstate detection of inappropriate uevent with DISK_RO set and suppress it.
      Fix udev rules to support udev database content generated by older rules.
      dm-mod autoloading support is in kernel 2.6.36 actually.
      WHATS_NEW_DM
      Fix dm-mod autoloading logic to not assume control node is set correctly.
      Reinitialize archive and backup handling on toolcontext refresh.
      Add random suffix to archive file names to prevent races when being created.
      Use dynamic allocation for metadata's tag buffer (removes 4096 char. limit).
      Revert to old glibc behaviour for vsnprintf used in emit_to_buffer function.
      "goto_bad" should be used in alloc_printed_tags function, not "goto bad".
      Add escape sequence for ':' and '@' found in device names used as PVs.

Petr Rockai (16):
      Skip t-pvcreate-operation-md if mdadm fails to create the required device.
      Account for mirror transient status when doing lvconvert --repair.
      t-lvconvert-repair-transient hangs on .33 and on RHEL6 kernel -> disable
      Add a test of wait_for_locks behaviour (adapted from an original by Dave).
      Refactor the handles_missing_pv logic in lvchange.
      Minor shell style cleanup.
      Maintain memlock balance in clvmd.
      .
      Restore the "removemissing" behaviour of lvconvert --repair --use-policies.
      .
      Don't fail t-pvcreate-operation-md if mdadm is broken.
      Make vgck warn about missing PVs.
      Do not create a clustered volume group in t-nomda-missing.
      Reduce severity of the "mirror transient status" log message (this was never
      Never scan internal LVM devices.
      Update WHATS_NEW.

Takahiro Yasui (1):
      Fix wrong number of mirror log at allocate policy

Zdenek Kabelac (63):
      Return ECMD_FAILED for break in process_each_lv() and process_each_segment_in_lv()
      API change for args of process_each_lv_in_vg()
      Replicator: libdm support
      Replicator: support deactivate of replicator-dev nodes
      Replicator: check open_count for parents of presuspend_node
      Replicator: base lvm2 support
      Replicator: new files for Replicator target
      Replicator: check replicator segment
      Replicator: extend _lv_each_dependency() with dependencies for Replicator devices
      Replicator: extend volume_group with list of VGs and flag
      Replicator: add sorted cmd_vg list
      Replicator: add find_replicator_vgs
      Hmm - fixing cvs import mistake
      Right directory name for replicator files.
      Remove files from wrong directory
      Add toolcontext.h header file.
      Replicator: add read and release VGs for rsites
      Replicator: use cmd_vg list for _process_one_vg()
      Replicator: use cmd_vg for process_each_lv_in_vg()
      Replicator: lock_lv_vol() finds missing VGs
      Replicator: activate checks for missing vgs
      Replicator: update _create_partial_dtree()
      Replicator: VG with cmd_missing_vgs does not generate output
      Replicator: add replicator to dtree
      Replicator: update activate code for vgchange
      Update Copyright date for resently modifed files
      Fix copy&paste detection of kernel release version.
      Use absolute paths in commands
      Use INSTALL_DIR to create directories
      Fix wrong usage of exec_prefix from previous patch introducing LVM_PATH define
      Update WHATS_NEW  for last commit
      Use "" instead of <> for  configure.h and libdevmapper.h
      Update lvresize/extend/reduce manpages with --nofsck, --resizefs options
      Add man page for dmeventd
      Add man pages for lvmconf and unsupported lvmsadc and lvmsar tools.
      Adding section number for lvm.conf manpages.
      Better WHATS_NEW message - as we still have not fixed 'make exec_prefix' build
      Fix typo: premitted ->  permitted
      Fix typo: "INTERNAL ERROR" -> "INTERNAL_ERROR"
      Add few missing information about what is this script doing.
      Preload libc locale messages.
      Fix typo reported in Debian bugzilla #586043
      Cleanups for configure:
      Minor optimalization of _test_word.
      Do not log backtrace in valid _lv_resume() code path
      Small update of memlock debug messages.
      Set return value 0 for 'dmsetup -c -o help'
      Update for dmsetup
      Revert previous commit as it would return also for incorrect syntax.
      Fix format string from patch apply mistake
      Do not use VPATH in include/Makefile
      Visually better align lines which are executed as a result of true
      Using count=0 is sufficient for creation of zeroed files.
      Add shell function to trim spaces.
      Minor speedup of lock test -
      Fix return  status 0 for "dmsetup info -c -o help".
      Clean generated files .exported_symbols_generated, example.conf for distclean.
      Wait for node creation before displaying debug info in dmsetup.
      Use void parameter for function definition.
      Fix constness warning in archive_file structure from archive.c.
      Fix const warning in dev_manager_info() and _dev_manager_lv_rmnodes().
      Fix 'void*' arithmetic warning in some functions from libdm-iface.c.
      Fix 'void*' arithmetic warnings in dbg_malloc.c.


