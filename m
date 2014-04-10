From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 10 Apr 2014 16:14:05 +0000 (UTC)
Subject: v2_02_106 annotated tag has been created
Message-ID: <20140410161405.1B72560FA3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a289910b3cd43b0b5617b9af45c3fb144e5bdd8
Commit:        1a289910b3cd43b0b5617b9af45c3fb144e5bdd8
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2014-04-10 15:37 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2014-04-10 15:37 +0000

annotated tag: v2_02_106 has been created
	    at 1a289910b3cd43b0b5617b9af45c3fb144e5bdd8 (tag)
       tagging 2043f8c729b468ab28bdfcbad8d8040dd0391d2f (commit)
      replaces v2_02_105

Release 2.02.106.

302 files changed, 12442 insertions(+), 4512 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlNGutsACgkQIoGRwVZ+LBdCeQCgyZ38ZLrWUoxdApxDtNKlDwQY
6RQAoMqkLb1ZWOP+ssAq0pAn7SRLTP7/
=9koG
-----END PGP SIGNATURE-----

Alasdair G Kergon (19):
      post-release
      autoconf: Update config.guess/sub to 2014-01-01.
      tools: Add internal tags command.
      compilation: Rename tags variables to tagsl.
      allocation: misc fixes for percent/raid rounding
      allocation: improve approx alloc with resize
      man: Add lvmthin(7).
      vgsplit: Mark cache moving code NOTREACHED.
      lib: Share lvm_even_rand for random numbers.
      clvmd: Update new remove_info INTERNAL_ERRORS.
      dev-cache: Improve open device check messages.
      reports: FIXME for unnecessary cache wipes.
      lvmetad: Update retry logic vars and comments.
      thin: Support thin_check --clear-needs-check-flag.
      format_text: Report failed close.
      configure: regenerate
      configure: Warn if old thin_check tool found.
      autoreconf
      pre-release

David Teigland (3):
      man: add lvmthin man page
      man: lvmthin pool space exhaustion
      man: lvmthin clean up lvm.conf references

Jonathan Brassow (42):
      Misc: Move some thin pool functions to a new file
      Misc: Change name of lvcreate_params field - s/create_thin_pool/create_pool/
      Typo: s/Unale/Unable/
      Misc: New function for reading lvm config file fields
      cache:  New 'cachepool' segment type
      cache:  New 'cache' segment type
      cache:  Add DM interface for retrieving a cache's status
      cache/misc: Revert commit 94377dfd
      cache: New functions for gathering info on cache devices
      cache:  Allocation code changes necessary to support cache_pool
      cache/pool: Make the fns in pool_manip.c work with cache pools
      misc: Fix copy+paste error
      pool: Make another thin pool fn generic for cache usage also
      cache: Add functions that create/remove cache LVs
      misc: rename variables [min|max]_chunk to [min|max]_chunk_size
      misc: disambiguate 'update_pool_params'
      cache pool: Add 'update_cache_pool_params'
      cache: Code changes to allow creation of cache pools
      cache: Code to allow the create/remove of cache LVs
      cache[pool]:  Populate existing report fields with cache data
      cache: lv_cache_create returns LV ptr, so return NULL not 0 on error
      cachepool: Ability to convert existing LVs to cachepool type
      cache: Ability to convert an existing LV into a cached LV
      cache[pool]: Man page updates for lvs, lvcreate, lvconvert
      cache: Do not configure cache[pool] support by default
      cache:  Update man page to reflect need for dm-cache 1.3.0
      man: Add example/explanation section for cache LVs to lvm.8
      allocation: Allow approximate allocation when specifying size in percent
      Update WHATS_NEW for approximate allocation check-in
      cache: Fix cache LV not being instantiated in kernel
      RAID: Allow implicit stripe (and parity) when creating RAID LVs
      cache-pool:  Change segtype name from cache_pool to cache-pool
      test: move RAID10 tests from lvcreate-raid.sh to lvcreate-raid10.sh
      cache: Disallow resizing of cache related LVs
      test: Add cache[pool] support to lv_tree_devices_ test suite function.
      pvmove: Disallow pvmove of cache LVs
      cache: Disallow vgsplit when there are cache LVs in the VG
      man: Enhancements to various man pages for cache[-pool] segtypes
      test: warn rather than fail when %FREE isn't working right
      cmirrord:  Clean-up stray warning message
      cmirrord: Clean-up stray warning message (attempt #2)
      RAID: Improve an error message

Marian Csontos (5):
      Fix premature return from get_pool_params
      test: Remove incorrect evaluation
      man: Fix man page containing BUILDROOT
      lvmetad: Fix previous commit
      lvconvert: fix help message cache_pool -> cache-pool

Ondrej Kozina (1):
      Add systemd native service for clvmd and cluster activation

Peter Rajnoha (83):
      udev: drop cryptsetup specific rules from 10-dm.rules
      WHATS_NEW: be more specific about cryptsetup version that sets the udev flags
      coverity: check return value of dev_close in dev_get_block_size()
      wiping: issue error if libblkid detects signature and fails to return offset/length
      dmeventd: fix dmeventd -R to work properly with systemd
      dmeventd: add DM_EVENT_GET_PARAMETERS request to dmeventd protocol
      dmeventd: use _exit(0) instead of raise(9) on dmeventd DIE message
      dmeventd: check pidfile for exit instead of polling via protocol
      WHATS_NEW: latest commits
      cleanup: missing parentheses in a condition
      wiping: wipe DM_snapshot_cow signature without prompt in newly created LVs
      systemd: cleanup for lvmetad systemd unit
      autoreconf: latest changes
      systemd: add systemd unit for cmirrord
      systemd: rename lvm2-cluster-activation and lvm2-clvmd services to follow existing naming
      cleanup: clarify man pages about lvchange/vgchange -aay, use -aay in lvm2-cluster-activation script
      systemd:  Use --ignoreskippedcluster in generated activation systemd units
      systemd: do not use default dependencies for clvmd/cmirrord units
      scripts: use --ignoreskippedcluster in lvm2-monitor initscript/systemd unit
      pvcreate: do not print stack when pv not found while doing pvcreate_check
      udev: create /dev/disk/by-id/lvm-pv-uuid-<PV_UUID> symlink for a PV
      cleanup: missing header file
      coverity: check dm_strncpy return value in dmeventd/_get_parameters
      WHATS_NEW: for commit b391ae88e5ed3720a8b5a87312e0cd907a94fcc2
      config: use DMEVENTD_PATH for default dmeventd executable config
      dumpconfig: comment out config lines without default values defined
      dumpconfig: add a comment to each config with variable name, use '<name>' to denote that for config paths
      udev: run pvscan --cache via systemd-run in udev if the PV label is detected lost
      config: fixup default values for selected config settings
      config: use mempool for config paths used in find_config_tree_* functions
      config: add CFG_DEFAULT_RUN_TIME for config options with runtime defaults
      config: runtime default for devices/cache, devices/cache_dir
      config: runtime default for backup/backup_dir, backup/archive_dir
      config: runtime default for config/profile_dir
      config: runtime default for activation/mirror_image_fault_policy
      config: separate cfg_def_default_value_hint out of cfg_def_get_default_value
      config: runtime default for allocation/thin_pool_chunk_size
      config: add default for allocation/cache_pool_chunk_size
      cleanup: remove superfluous forward declaration
      WHATS_NEW: config handling changes
      tests: fix name-mangling test and remove udev transaction in dmsetup wrapper
      cleanup: remove superfluous slash in default cache dir path
      config: use small local static buffer instead of mempool for temporary config path
      config: keep config paths with variable names properly marked on output
      autoreconf: sync configure with current configure.in
      config: mark global/thin_disabled_features as having no default value
      config: accept empty values for global/thin_disabled_features
      man: add man page for lvm2-activation-generator
      man: install lvm2-activation-generator man page only on make install_systemd_generators
      autoactivation: issue a VG refresh before autoactivation only if 'change' lvmetad flag is set
      autoactivation: use VG read lock
      cleanup: use 'define' for systemd runtime unit file directory
      tests: fix name-mangling test
      conf: add existing report settings to lvm.conf
      config: make report settings profilable
      config: make global/units and global/si_unit_consistency profilable
      doc: cleanup/extend some man pages/conf comments
      config: make global/suffix profilable and add it to lvm.conf
      WHATS_NEW: previous commit
      config: make global/lvdisplay_shows_full_device_path profilable
      dumpconfig: fix memleak when using --mergedconfig
      cleanup: add cmd_context reference to struct cft_check_handle
      WHATS_NEW: commit 5eef269
      cleanup: move _get_def_array_values fn
      config: add support for comparing used config values with default ones
      dumpconfig: add dumpconfig --type diff to show differences from defaults
      config: also check empty arrays for difference against default values
      config: define default value for global/thin_disabled_features as NULL instead
      libdaemon: fix misleading  "WARNING: Ignoring unsupported value for expected." when communicating with daemon
      WHATS_NEW: commit f12ee43
      lvmdump: add lvm dumpconfig --type diff/missing
      man: add man page for lvm dumpconfig
      man: better formatting for lvm dumpconfig man page
      config: fix compile error in config-settings.h if using --disable-dmeventd
      man: add a note about --profile when using dumpconfig --mergedconfig
      tests: update profiles.sh for recent changes
      tests: add profiles-thin and prepare_profiles helper fn
      tools: don't require --major to be specified when using -My option on kernels > 2.4
      lvmetad: fix lost bootloader area information
      tests: add some coverage for bootloader areas
      pvcreate: fix ignored --dataalignment/dataalignment offset for pvcreate --restorefile
      tests: add separate test file for bootloader area support and enhance tests
      tests: add test for pvcreate --dataalignment --dataalignmentoffset --restorefile compatibility

Petr Rockai (77):
      libdevmapper-event: Print a deprecation warning for non-default plugins.
      format-text: Avoid a label_scan while in a critical_section().
      test: Only try raid10 on dm-raid versions that support it.
      lvmetad: Make "reason" in a token_mismatch reply more informative.
      lvmetad: Make token_mismatch handling more robust in the clients.
      nix: Import the modular specfile we use for nix-driven builds.
      NIX: Fix build-dependencies for FC 18.
      NIX: Grab specfile from lvm2Nix (at least for now).
      NIX: Copy collected test results into the output.
      NIX: Fix a couple typos in build product handling.
      NIX: Make it possible to only run a subset of tests (via T).
      NIX: Adapt to use of 9P in VM builds.
      NIX: Add an fc18 build that includes fedora updates.
      NIX: Add default.profile to the spec file.
      NIX: The mergeUsr attribute was renamed to unifiedSystemDir.
      NIX: Fix chrooted builds, passing down package lists explicitly.
      NIX: Run tests with /dev and (on recent Fedora) with udevd running.
      nix: Run udevd in foreground.
      nix: Set kernel console log level to debug.
      nix: Look a bit harder for udevd.
      NIX: Use the new "check_full" target for comprehensive testing.
      NIX: Fedora 19 is now stable. Add builds that include updates.
      NIX: Add %with thin_repair to the specfile.
      NIX: Add %with thin_dump to the specfile.
      NIX: Restore CIFS modules, as 9p is broken on many kernels.
      NIX: Do not insmod 9p/virtfs on centos64 as it BUGs out right away.
      NIX: Fix a centos64 failure due to old dmesg.
      NIX: Give the VMs more RAM (768M instead of 512M).
      NIX: Try harder to set dmesg levels.
      NIX: Skip autoconf, as we include ./configure in git.
      NIX: Update URL for lcov RPM.
      spec: Add thin-performance.profile to the filelist.
      spec: Add lvm2-pvscan at .service to filelist.
      NIX: Revert to calling make check inside the RPM build.
      spec: Make it possible for %check_commands to prevent %clean-ing.
      NIX: Run system-wide tests separately, with RPMs installed.
      spec: Explicitly disable thin when we don't want it.
      spec: Do not treat --with-?=none as having the thing.
      spec: We do want thin support on RHEL 6.
      NIX: Use vault.centos.org to get older revisions.
      NIX: Retire the CentOS 6.3 builds.
      NIX: Add CentOS 6.5 builds.
      NIX: Add a local nix-build.sh script.
      NIX: On RHEL<=6 and FC<=16, udevd is /sbin/udevd.
      spec: Package the new clvmd/cmirrord systemd units.
      NIX: Move nix-related bits under nix/.
      spec: Add a copyright header and an explanatory notice.
      NIX: Add a short README (to be expanded).
      NIX: Update the release.nix path in build.sh.
      NIX: Change the URL for the lcov RPM to a more canonic location.
      lvmetad: Hide corrupt MDAs from the cache.
      lvmetad: Keep the cache consistent when a PV moves around.
      test: Fix notify_lvmetad for symlinked devices.
      test: Add lvmetad_talk and lvmetad_dump to aux.
      spec: udev rules don't live under %{_prefix} on fc16/rhel6
      format-text: Fix _raw_read_mda_header (missing close, open r/o).
      format-text: Fix a warning.
      test: Fix the failing branch in aux lvmetad_talk.
      test: Downgrade lvmetad-lvm1 failure to a warning.
      test: Fix stat calls in lvmetad-pvscan-filter.
      NIX: Cope with existence of multiple primary.xml files.
      lvmetad: Fix an invalid memory read that could cause a deadlock.
      test: Properly synchronize direct dmsetup calls.
      test: Test that we cope with stray device nodes.
      test: Make teardown (more) resistant to funny DM device names.
      test: Use correct path to /dev in lvchange-raid.sh.
      lvmetad: Also return vgname in reply to pv_found requests.
      lvmetad: Indicate whether pv_found caused the VG to change.
      lvmetad: Fix pvmeta_old_{pvid,dev} logic when they are the same.
      polldaemon: Re-initialise lvmcache properly on fork (fixes RHBZ 1073670).
      lvmetad: Wait@least 80s for the initial scan.
      lvmetad: Fix an endless wait loop introduced in c13f5dbb.
      pvs: Wipe persistent filters when given a device argument.
      lvm-wrappers: Remove spurious #include <libudev.h>.
      libdm: Add missing UDEV_CFLAGS.
      spec: Add lvmthin.7.gz to packages.inc.
      NIX: Avoid test-installing lvm2-sysvinit (fails on recent Fedoras).

Thomas Fehr (1):
      pvdisplay: fix man to refer to sectors, not KB

Zdenek Kabelac (305):
      thin: online metadata resize requires 1.10
      tests: more testing for online thin metadata resize
      missed pool_manip.c
      thin: rename function
      thin: validate resize of thin LV with ext. origin
      thin: fix feature compare function
      tests: thin external origin resize
      cleanup: indent
      thin: use LV_TEMPORARY for metadata initialization
      thin: fix missing ~ in previous commit
      lvmetad: respect LVM_LVMETAD_PIDFILE settings in lvm
      locking: avoid dropping locks
      devices: support zvol
      thin: disable extension of reduced thin with etx.origin
      tests: check for mkfs
      thin: more validation of thin name
      cleanup: fix cut&paste and move initialization
      thin:drop stack trace when pool is above threshold
      thin: validate external origin size
      tests: validate acceptable external origin size
      tests: update test
      raid: add temporary activation for raid metadata clear
      raid: use unsigned 64b constant for shift
      raid: drop invalid modication of active parameter
      lvm2app: access params after its checked
      man: use some existing indentifier
      cleanup: update clearing message
      cleanup: condition reodering
      cleanup: use string constant with '_'
      cleanup: remove unneeded header files
      cleanup: fix some lvm.conf typos
      tests: remove debug.log in enable_dev
      tests: add check lv_not_exists
      tests: utilize check and get
      activation: drop test r/w vg state for activing LV
      libdm: use 64bit type for raid index
      cache: convert libdm to use plain function call
      cache: using unsigned argc
      cleanup: indent spaces
      cleanup: use struct initializer
      thin: fix merge of old snaphost
      cleanup: indent
      tests: add short delay
      tests: on older system use mirror type
      tests: more clustered testing
      tests: drop more debug.log
      tests: use exclusive activation for mirror case
      tests: check locking is not lost during thin_check
      cleanup: move verbose message to lv_activation_skip
      cleanup: use is_change_activating
      cleanup: indent
      activation: lv_activation_skip remove always same arg.
      tests: add small test for clustered conversion of mirror
      libdm: internal is_selinux_enabled wrapper
      libdm: drop unneded assignment
      libdm: call preload callback only when success
      libdm: proper traversion of revert list
      libdm: hardening transaction_id validation
      libdm: enhance thin transaction_id validation
      metadata: move vg parsing to vg_write
      thin: cleanup target_present call
      raid: use feature attributes for raid10
      mirror: detect attrs just once
      cleanup: reorder commonly available devs in system to the front
      cleanup: spelling
      cleanup: extend struct init usage
      cleanup: indent, drop unneeded braces
      tests: drop mirror from filter
      tests: add some quotes
      tests: enhance thin test
      tests: check for python before other tests
      tests: add extra wait
      mirror: look for mirror seg only in mirror LV
      mirror: move declaration to define
      tests: cache needs 1.3
      allocation: add default path
      cleanup: keep pv_count unsigned
      snapshot: zero cow header for read-only snapshot
      tests: improve read-only test for snapshot
      tests: support for older snapshot target version
      snapshots: fix incorrect calculation of cow size
      snapshot: correct previous snapshot commit
      tests: updates
      cleanup: relocate segment flags
      tests: drop remove
      tests: quote dev
      tests: remove extra vgremove
      lvmetad: fix memleak when pv changes it device
      lvmetad: move memalloc/free out of lock
      lvmetad: more reuse precommit buffer
      tests: detect reiserfs support
      tests: use longer sleep
      tests: report selinux mode
      tests: disable test which leaks node
      tests: split raid test
      tests: restore usage of reading kmsg
      tests: detect nc or socat
      lvmetad: fix minor gcc warning
      tests: split raid test
      tests: speedup kmsg processing
      tests: restore .txt suffix
      tests: reinstantiate support for klogctl
      tests: check readability of /dev/kmsg
      tests: print kernel version
      tests: hide error message
      tests: testing usable of /dev/kmsg
      configure: drop duplicated SUBST
      readline: switch to new-style readline typedef
      makefiles: use BLKID/UDEV_CFLAGS properly
      makefiles: link blkid library only to lvm
      tests: detect old-snap metadata consitency
      tests: check created snapshot has good max size
      tests: updates for new test
      clvmd: use dm_zalloc for socket allocation
      clvmd: fix memleak on exit
      dmeventd: remember number of log disablings
      dmeventd: wakeup timeout thread earlier
      cleanup: clvmd reindent lock_vg code
      cleanup: clvmd rewrite send_message
      cleanup: clvmd simplify loops
      cleanup: clvmd indent changes
      cleanup: clvmd assign NULL to pointers
      cleanup: clvmd use else if
      cleanup: clvmd use struct initializers
      cleanup: dmeventd code simplified
      cleanup: dmeventd convert multiline to single line
      tests: reuse existing check dev_md5sum
      tests: improve wait for open
      tests: skip another kernel
      tests: skip valgrind testing when assigned to 0
      tests: workaround bash bug
      tests: drop unused make_ioerror
      tests: aux adds kill_sleep_kill_
      tests: dmeventd valgrind testing
      clvmd: fix the len setting in last commit
      thin: fix pool_has_message return for NULL params
      thin: do not check of empty pool with messages
      lvm: change build_dm_uuid API
      thin: always activate and deactive pool when creating
      thin: add pool uuid suffix for pool volume
      tests: add inactive pool creation test
      tests: check we are no reading pool device
      tests: another kernel with unusable kmem_check
      cleanup: drop unused define
      dev_manager: check prohibited devices earlier
      tests: quick update of location of pid file
      tests: use DMEVENTD_PIDFILE
      lvconvert: disallow usage of origin for snapshot
      snapshot: wrap min_chunk test into a lib function
      lvconvert: validate min chunk size for snapshot
      lvconvert: delay archiving of metadata
      cleanup: relocate check for mirror
      tests: add more help text and paths quotes
      tests: skip more Fedora kernels for raid456
      tests: more coverage
      tests: test spare volume removal
      tests: skip mangling test
      tests: put test envvar into braces
      tests: enhance snapshot test
      tests: lvconvert snapshot testing
      tests: zero and error type tests
      tests: update error message check
      tests: make test usable in cluster
      tests: put vars in quotes
      tests: quotes for LVM_TEST vars
      tests: replace skip_if_mirror_recovery_broken
      lvmcache: add mode debug prints
      tests: more fedora kernels unusable for testing raid456
      tests: use check lv_tree_on
      archiver: drop unneeded backup check
      file_locking: use PATH_MAX for dir name
      clvmd: avoid resending local sync commands
      metadata: print VG with invalid chars in quotes
      pvdisplay: use log_print_unless_silent for info messages
      pv_vg_name: do not expose internal orphans to lvm2 users
      cleanup: simplify pv name print
      pvscan: fix report of long pv names
      pvscan: cleanup updates
      cleanup: indent
      lvmcache: handle reinit without error
      lvmcache: fix debug trace
      activate: report release with critical section
      memlock: drop locked mem in critical section
      clvmd: fix clean memory on exit
      clvmd: always set cleanup_needed
      clvmd: add special lvm thread exit
      clvmd: move destroy_lvm into lvm thread
      clvmd: move call of cluster_closedown
      clvmd: use dm_malloc
      clvmd: update add_reply_to_list
      clvmd: drop unused local_sock parameter
      clvmd: drop dead code
      singlenode: reset pointer when hash is destroyed
      cleanup: memlock line indent
      cleanup: clvmd move destroy_lvhash into main
      cleanup: clvmd skip reset of null pointer
      cleanup: clvmd drop goto
      cleanup: clvmd update log_error
      cleanup: clvmd dump_messages
      cleanup: clvmd indent change
      cleanup: clvmd reindent read_from_local_sock
      cleanup: clvmd zombie removal loop
      cleanup: clvmd uses struct initializers
      cleanup: clvmd add more info debug message
      tests: add quotes around device paths
      tests: simplify
      tests: wait for clvmd.pid file
      WHATS_NEW update
      dev-swap: detect swap signature on devices smaller then 2MB
      dev-swap: use SECTOR_SHIFT
      dev-cache: fix mem corruption on refresh context
      clvmd: hardening leak on exit
      clvmd: validate open device state
      cleanup: use NULL for pointer reset
      cleanup: indent
      cleanup: initilization of vars
      cleanup: use trigraph
      cleanup: use dm_free without extra test
      cleanup: drop init of already zalloced mem
      debug: add proper backtrace debug
      tests: relocate vgimport test
      tests: more pvresize tests
      tests: argless pvremove
      tests: use exclusive activation
      tests: update
      tests: wipe signature
      pvresize: fail exit code for negative size
      lvmetad: add missing dev_close in error path
      tests: remove also 3.14 fc21 kernels
      tests: disable test for broken kernel raid targe
      tests: check forced backup
      tests: cover code from more commands
      tests: pass list devs to allocate from
      tests: missed exclusive activation
      man: add repair info for thin pools
      man: colorization fixes
      cleanup: lvmetad use dm_hash_iterator
      cleanup: simplify pv name size estimation
      cleanup: easier casting
      pvchange: fix exit code regression
      lvrename: fix exit code
      lv_rename: validate renamed sublv
      lv_manip: drop cmd pointer from for_each_sub_lv
      debug: avoid warning when compiled with valgrind
      cleanup: indent change
      tests: cover more commands
      tests: more pvchange options examined
      fix spurios char
      spec: add dumpconfig man
      tests: support invalid and fail results
      tests: move some tests to better places
      tests: updates
      pvchange: populate lvmcache for --all
      tests: expect failing pvs when missing PV
      tests: check pvchange changes uuid
      tests: more coverage for pvchange
      tests: update pvs test
      vgimport/vgexport: return invalid cmd
      pvdisplay: fix option error
      pvscan: return error when free parameter is given
      man: sort options
      cleanup: vgexport drops pv pointer
      cleanup: pvdisplay indent
      tests: more vgexport tests
      tests: workaround clvmd .cache consistency
      tests: add more pvdisplay tests
      lvdiplay: prohibit use of -c and -m
      lvrename: fix name length validation
      lv_rename: resume fail is certainly error
      vg_validate: check size of lv_name + vg_name
      cleanup: lvdisplay indent
      cleanup: skip eval of minor when major is true
      tests: more listing tests
      tests: add more rename test
      cache: never activate cache pool
      cache: cache segment is non-discardable
      cache: use remove_layer_from_lv
      cache: fix order of metadata change
      cleanup: cache reuse code for pool test
      cleanup: cache use const char policy
      cleanup: cache updates messages
      cleanup: just rename for interal function
      debug: add internal error for passed LV
      tests: update lvcreate-cache
      cache: enforce local exlusive activation
      libdm: track implicit dependecies
      libdm: always dm_lib_init mangling mode
      libdm: fail if buffer for version is to short
      libdm: check for size when opening control node
      libdm: check for _build_dev_path failure
      libdm: simplify segtype search
      exec_cmd: skip fork when argv[0] is null
      raid: use internal variables for array alloc
      log: skip repeated hashing when logging once
      lvm-string: add cdata/cmeta as reserved name
      man: cleanup new params
      lvconvert: do not activate cache pool
      debug: catch invalid request for tree
      cleanup: refactor apply_lvname_restrictions
      cleanup: use DM_ARRAY_SIZE
      cleanup: do include lvm headers in libdm build
      cleanup: update comments
      cleanup: reindent return
      cleanup: libdm drop already zeroed elements
      tests: check prohibited names

Zhiqing Zhang (1):
      lvresize: fix stripe size validation


