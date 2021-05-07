From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  7 May 2021 21:15:24 +0000 (GMT)
Subject: v2_03_12 annotated tag has been created
Message-ID: <20210507211524.3078F3890426@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6809e10a27865fbd6d67980a348946a2867182d
Commit:        e6809e10a27865fbd6d67980a348946a2867182d
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2021-05-07 21:09 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2021-05-07 21:09 +0000

annotated tag: v2_03_12 has been created
	    at e6809e10a27865fbd6d67980a348946a2867182d (tag)
       tagging 01b05cf51dd547354b4ad70e7f8f4ff7ff0bb152 (commit)
      replaces v2_03_11

Release 2.03.12

Two notable changes are devices file and metadata based autoactivation.

Fix exported symbols generation with GCC10's new LTO optimizer.  Can be
overridden by configure --with/without-symvers.

Greatly improved reliability of test suite, now reporting much less false
positives.

And many fixes, improvements, and clean ups.

New devices file feature is off by default for now.
When on devices file is used to filter devices which are scanned for PVs.
Devices file can be overridden by --devicesfile on command line.
Two new commands to manipulate devices file - lvmdevices(8) and
vgimportdevices(8), and new configuration options in devices section:
use_devicesfile, devicesfile and search_for_devnames.

Metadata based autoactivation property for LVs and VGs set in lvcreate/vgcreate
using --setautoactivation option and modified by lvchange/vgchange.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJgla1RAAoJELkRJDHlCQOf+2sP/RLK2AsYk1Lody4f97XJboX+
qyJU66mYRLExc1XAt5aNG6HHiKzVDvfuaukC3Li9BkXc8wAFQgmoZk7/EwvWfBY+
C4eCDqUT9FreXGdH0aF38S5TrTzpbQSh7QiiYOYXSqr0TaMpuLck/zTlGXeWyN9T
ka70luzszJPs8RXLhG9ZS+cRWoIjqGjRhUb0hdkLpehujav4aTCVY2LNnVRXrjKM
OnA/8lhWttvkHdvkUvFJWH4Gpc5CxheDRwfRpTCoHzcD4QdWqNBmWwcJkpNLSzsa
EHVZPu0KpQpcyPZ18vGeou28jg7y91/P4x/vmfQfKrniXukm5aab2zzl7q838khq
jbLswxZckLhKtgpvovvnx3G9ILN8URMIX5YzHKwwm8eq9tChviLyImfbA2AA7qY7
uOlM6oI+QiXIhSDPBiAvdQk/qN3uGxJb6i9o5sZp1+G968tuz/wBZaUJ0PGY2qmX
SF/dik3Mf+ZSJGikmNjHCg4rfehS88tH/xsr64f7H7XRvso3UNLjiEzlytAUoVhl
B6IRZv69pMDjdXgzEUDu+12EARjX6HyFaCyVBzAKunOjp/etexbFjYdCO/rS5fk0
oX1P02AY0PXW4z+Djc6Unfc5Rrek9eMpktcDZwGzmkqNBqYFLNr4b6WSafXpVhOK
D+Uov/3zDQIa47LVJG9H
=SP0I
-----END PGP SIGNATURE-----

David Teigland (49):
      lvmlockd: sscanf buffer size warnings
      integrity: fix segfault on error path when replacing images
      devs: remove invalid path name aliases
      label_scan: fix missing free of filtered_devs
      pvck: fix warning and exit code for non-4k mda1 offset
      writecache: use cleaner message instead of table reload
      filter-mpath: work with nvme devices
      writecache: let block_size setting override device block sizes
      cachevol: allow forced detaching of damaged or invalid cachevol
      hints: clean up comment and init settings
      dm: add debugging to include table differences
      md component detection changes
      lvmcache: remove unused variable from last commit
      fix for md component detection changes
      dev_get_primary_dev: fix invalid path check
      scan: wipe filters when dropping scanned data
      include lvm version in debug output
      fix check for md raid imsm signature on 4k devices
      command defs: add missing commas
      device usage based on devices file
      tests: allow tests to use real devices
      tests: for devices file
      WHATS_NEW: devices file
      tests: real_devs remove mistakenly added test
      Revert "tests: enable tests for lvmlockd"
      lvmconfig: fix deprecation message
      config: remove redundant comment for deprecated settings
      filters: better message for excluding LV
      lvmlockctl: use lvm.conf lvmlockctl_kill_command
      lvmlockctl: replace popen and system
      tests: check_devicesfile
      man: lvmlockd use of lvmlockctl_kill_command
      hints: don't use hints when --sysinit is used
      Add metadata-based autoactivation property for VG and LV
      tests: skip autoactivation-metadata with lvmlockd
      man/help: change LV type listing
      remove unused flag DEV_UDEV_INFO_MISSING
      config: improve description for event_activation
      man-generator: add option to check for repeated command definitions
      commands: use AUTOTYPE in definitions
      man/help: move implied annotation
      Revert "cov: check label_read_pvid return value"
      label_read_pvid: separate error and no-pvid
      pvremove: use consistent error message
      devices file: recommend removing filter
      blkid: simplify fs block size check
      tests: new lvextend-caches
      writecache: allow attaching to thin pool data
      tests: add lvextend-caches-on-thindata

Heinz Mauelshagen (1):
      lvdisplay: enhance LV status output for raid(0)

Marian Csontos (11):
      post-release
      make: generate
      tests: Skip test killing kernel
      man: Fix wording in lvmthin(7)
      make: generate
      makefiles: Revert most of 456b659
      makefiles: make rpm respect --disable-silent-rules
      tests: Skip test killing kernel
      lvm: Fix editline compilation
      make: generate
      pre-release

Samanta Navarro (1):
      all: fix typos

Wu Guanghao (1):
      unit-test: modify for systems with PGSIZE of 64K

Zdenek Kabelac (410):
      alloc: enhance estimation of sufficient_pes_free
      tests: check thin-pool corner case allocs
      tests: check full zeroing of thin-pool metadata
      config: avoid printing spaces before end of line
      pools: fix removal of spare volume
      vdo: support online rename
      tests: check support for online vdo rename
      pvscan: make ret value defined
      filters: avoid duplicated //
      pvscan: ensure read buffer ends with 0
      WHATS_NEW: update
      man: update lvmthin
      thin: improve 16g support for thin pool metadata
      pool: limit pmspare to 16GiB
      cache: reuse code for metadata min_max
      pvmove: automatically resolve whole stacked LV
      allocation: report allocation error instead of crash
      WHATS_NEW: updates
      wipe: reformat message for failure case
      pvscan: enhance _count_pvid_files_from_lookup_file
      lvconvert: ensure device_name is defined
      tests: check 16G thin pool metadata size
      tests: update thin and cache checked messages
      tests: check for cache support presence
      aux: update thin_restore_needs_more_volumes
      libdm: add dm_tree_node_add_thin_pool_target_v1
      gcc: hide uninitialized warning with older gcc
      tests: check for raid target support
      tests: avoid killing test machines with kernel bug
      tests: increase required target version
      lvcreate: use lv_passes_readonly_filter
      test: check read_only_volume_list tagging works
      pvscan: support disabled event_activation
      thinpool: use lv_config_profil for crop_metadata
      thin: check for overprovisioning only once
      lv_resize: use 'bad' code path for error case
      lv_manip: reuse function also during reduction
      lv_resize: support resizing of cached volumes
      tests: support for resized cached LVs
      tests: check event_activation can be disabled
      targets: use target_present_version
      dev-cache: check for nvme name while adding alias
      dev-cache: better code reuse for _add_alias
      dev-type: dev_is_pmem reuses topology read code
      dev-type: use fopen for sysfs file
      dev-type: convert to use log_warn
      WHATS_NEW: updates
      typo: fixes
      dev-type: sysfs attrs without sectors
      dev-cache: remove duplicated allocation
      snapshot: create origin of virtual snap read only
      lvchange: snapshot thick origin permission rw/r
      lvconvert: read-only origin cannot be merged
      label: avoid rescaning unusable DM devices
      device_mapper: simplify line emitter checking
      libdm: simplify line emitter checking
      gcc: ensure pointer is always defined
      gcc: drop unused assingment
      WHATS_NEW: update
      lvconvert: thin errorwhenfull and recalculation
      tests: lvconvert thin profile conversion
      lvdisplay: fix show of merged thin snapshot
      tests: lvdisplay does not crash for merged thin
      lv_manip: avoid removing LV when converting
      lvchange: remove unneeded call
      lvconvert: vdo may convert already formated vdo
      lvconvert: VDO kernel support before converting
      vdo: just one probe is enough
      tests: check resize of cached vdopool
      man: vdo drop resize restriction comment
      tests: lvconvert vdo profile support
      lvmlocdk: correct creation of dm path vg sanlock LV
      tests: readonly snapshot thick origin can't be merged
      make: generate
      WHATS_NEW: updates
      fsadm: avoid access to unbound variable
      tests: remove local setting of LVM_BINARY
      lvextend: enable resize of writecached LV
      cache: fix warning test
      lvconvert: change errors to internal ones
      cleanup: simply code
      cleanup: simplify initilization
      cleanup: improving message
      cleanup: comment typo
      WHATS_NEW: updates
      tests: update setting LVM_BINARY for testing
      tests: make test complaint to local dev dir
      makefiles: support help target
      makefiles: avoid sorting by locales
      makefiles: fix man-generate rule
      makefiles: add alias for device-mapper
      makefiles: drop invalid dependency on all
      makefiles: simplify and cleanup
      makefiles: sed
      makefiles: cmirrord install through install_cluster
      makefiles: fix pofile generation
      makefiles: integrate  DESTDIR
      makefiles: better logging
      makefiles: retry faster deps again
      commands.h: keep entries alphabetically sorted
      cmdline: lvcreate adds vdopool as vg name provider
      cmdline: drop MAX and check NULL
      cmdline: use binary search
      dev-cache: replace inefficient looking for dev
      dev-cache: optimize dir scanning
      lvremove: backup at the end of loop
      archive: support interruption
      toolib: move sigint_caught
      label: check only with active device for rescan
      device_mapper: zero only secure buffers
      device_mapper: reduce min_size for flatten
      integrity: mark as user of secure_data
      cleanup: free already checks for NULL
      cleanup: simplify condition
      debug: use enclusing "" for debug
      make: generate
      WHATS_NEW: updates
      makefiles: fix location of basedir
      lv_remove: reduce commits for removed LVs
      vg_write: optimize caching of precommitted VG
      vg_read: reuse already parsed config tree
      deactivation: reduce ioctl count
      lvremove: reduce ioctl count
      hash: use individual hint sizes
      hash: use unsigned size
      hash: speed up hash tables
      hash: replace hash with better function
      hints: keep strings aligned in structure
      libdm-config: replace check for 0
      cleanup: avoid allocating memory for hash key
      cleanup: on stack structure instead of allocation
      cleanup: simpler checks first
      cleanup: move code
      cleanup: compare only LV uuid part
      WHATS_NEW: updates
      lvremove: correct return code
      bcache: fix incorrect pointer check
      vg_write: shift check for exported metadata
      device_mapper: keep bigger size for most ioctls
      thin: correct ptr test for thin snapshot merging
      lvm-file: remove duplication of dm_is_empty_dir
      backup: set in vg_commit
      cleanup: easier print of historical lv
      cleanup: no backtraces needed after log_error
      debug: change sys_error to sys_debug
      debug: more use of display_lvname
      debug: more tracing
      gcc: match size of holder name to direcnt d_name
      activation: use existing LV as best effort
      cov: fix iter memleak in vgimportclose
      cov: memleak on error path
      cov: remove unnecessary headers
      cov: unused value
      cov: mask uninitialized value
      cov: variable initialization
      cov: ensure buffer is initialized
      cov: ensure settings is set
      cov: defined flv
      cov: happier with defined extent_size
      lv_check_not_in_use: correct check
      lvconvert: fix error path on writecache removal
      toollib: prioritize processing thin-pool first
      lvremove: support faster removal of thin-pools
      toollib: use EINIT_FAILED for missing devs
      cleanup: eliminate unused assign
      cleanup: use already set vg_complete
      cov: initialize value
      gcc: adding const
      debug: display_lvname
      tests: settle after wiping
      toollib: preserve return code 5
      thinpool: correct condition
      signals: add interruptible usleep
      activation: use interruptible_usleep
      cache: use interruptible_usleep
      lv_info: missing check for info.exists
      lvremove: drop flushing dm cache before remove
      cleanup: simplify
      cleanup: move common condition
      config: keep issue_discards in config struct
      config: correct option name
      vg_validate: fix validation of merging thin origin
      lvremove: use common routine for prompting
      lvremove: use to_remove for snapshot removal
      pooldaemon: increase min polling interval
      lvpoll: improve merge polling
      debug: drop stack from regular code flow
      debug: keep microseconds aligned
      debug: update message
      cov: void unused result
      shellcheck: avoid assign warnings
      tests: update handling of thin-pool removal
      tests: wait till fs is synchronized
      tests: add test for merging
      WHATS_NEW: updates
      cleanup: typo
      device_is_usable: minor improve
      cleanup: use dm_strncpy
      debug: start with upper case
      tests: added check for kernel version
      tests: update mirror test
      tests: require newer version of raid target
      tests: no further fixes likely to be expected
      tests: workaround for some raid targets
      tests: increase version of targets for progress
      tests: wait for Aa status
      tests: avoid leaking unkilled commands
      cleanup: simplier check first
      thin: add extra protection
      thin: ignore parallel merge while polling
      dev_manager: status check with info check included
      dev_manager: add lv_raid_status
      dev_manager: skip also zero targets
      lvresize: support resize of stacked virtual LV
      lvremove: extra code for handling thinpool data
      segtypes: macros for error and zero segtypes
      lvresize: allow mixing striped with errors or zero
      pool: allow data on zero and error segtypes
      thinpool: support lvconvert without zeroing
      tests: aux always shift emulated devices by 1MiB
      tests: check mixing striped with error and zero
      tests: add check for lvconvert without zeroing
      tests: check for raid sync in progress
      WHATS_NEW: updates
      raid: interruptible usleep when waiting for sync
      raid: resync cannot lose primary leg
      raid: move non dm functions from DEVMAPPER ifdef
      gcc: ensure buffer ends with 0
      cleanup: reduce code dupliction
      git: update .gitignore
      make: generate
      make: restore buildir != srcdir support
      make: simplify dependency loading
      make: cflow target works again
      tests: require newer raid version
      tests: copy more data
      tests: drop status workaround
      tests: aux reject /dev as testing dir
      tests: fix condition for exclusion of /dev
      raid: restore mirror handling in _raid_in_sync
      tests: add FIXME to raid test
      tests: prohibit 4K brd device with integrity
      tests: slow down device more
      tests: use mirror throttling
      gcc: declaration of tmpfile shadows a global
      tests: remove incorrect check
      tests: more system defaults for installed tests
      tests: skip only portion of test
      tests: even more aggressive throttling
      tests: remove local changes
      tests: new aux mdadm_create
      tests: use mdadm support
      tests: more usage of new aux mdadm_create
      tests: convert to use mdadm_create
      tests: avoid sleep on kill path
      tests: remove unused wait_md_create
      configure: use rawhide version
      make: add few more predef symbols for cflow
      tests: set known locking dir
      tests: enhance mdadm_create
      tests: aux updates
      tests: test needs to have playable locking dir
      WHATS_NEW: update
      tests: try to move more date
      tests: set default basic flavour
      tests: use mirror throttling
      tests: ignore failure of zeroing
      tests: use prefix for VG name
      tests: increase required version
      tests: wipefs with udev_wait
      tests: aux clean DM on top of MD
      tests: this test has race in it depending on kernel
      tests: query info instead of table
      tests: remove more file in teardonw
      tests: skip stray testing on real dev dir
      tests: ignore incosistent raid status
      fsadm: fix condition when using --getsize64
      fsadm: handle error from blkid
      tests: check fsadm with missing filesystem
      tests: handle case of missing /dev/disk
      tests: improve  check raid_leg_status
      WHATS_NEW: updates
      tests: aux fix check_lvmpolld_init_rq_count
      tests: add workaround for older mdadm
      tests: add should for racy test
      tests: add basic validation of running services
      tests: move setting of dmeventd pid
      tests: try to observe some unusual problem
      tests: dbus update
      tests: add commented example
      tests: skip more tests for lvmpolld pass
      tests: better reporting of problematic services
      tests: add aux mdadm_assemble
      tests: use aux mdadm_assemble wrapper
      tests: use blkid without caching
      tests: update for newer thin-pool
      tests: update dbus test_nesting
      tests: use shell comment
      tests: more skipped tests for lvmpolld
      tests: increase mirror throttling
      tests: correct thin-pool version
      tests: for 4.18 use already 1.20 logic
      tests: use known path for test in find
      tests: restore removed prefix
      tests: fight with losetup creation error
      tests: reoder killing order
      tests: ensure raid is synchronized
      tests: fix unfinished check for 4.18 kernel
      tests: test_pv_symlinks works only with /dev dir
      tests: bash quotes
      tests: add aux remove_dm_devs
      tests: sleep tunning
      configure: support builds without versioning
      device_mapper: remove unused lines
      libdm: use libdm header util.h
      man: writecache missed for --type
      man: describe profile support lvmcache.7
      man: show config options with comments
      libdm: symbol versioning with -flto
      libdm: move dm_task_get_info_with_deferred_remove
      makefiles: slight change in .export.sym
      makefiles: add check for versioned symbols
      symver: restore and uncomment some symbols
      symver: sorting
      libdm: eliminate some abi-dumper errors
      lvreduce: support --yes
      signals: support also SIGTERM for breaking command
      daemon-server: handle reaping threads better
      mirror_percent: support interruptible check
      polldaemon: improve support for interruptions
      makefiles: plugins can be build after shared library
      makefiles: cscope only predefined dirs
      makefiles: remove unneeded var changes
      lib: remove unused macros
      tests: pvmove updates
      WHATS_NEW: updates
      libdm: fix compiling with older gcc
      makefiles: static linking enhancements
      configure: better support for use of --without
      configure: make aio optional
      libdm: replace deprecated security_context_t
      makefiles: deps also for cxx
      makefiles: reuse CSCOPE_DIRS for ctags
      makefiles: no need for double Q
      man: use commas in SEE ALSO
      man-generator: improve hyphenation for longer option list
      man-generator: remove ',' between some options
      man-generator: option description indented
      man-generator: spaces
      man: hyphenation improvements
      make: generate
      WHATS_NEW: updates
      makefiles: add devmapper  for devmapper-event
      tests: enable for 5.12+ kernels
      make: generate
      tests: race on md raid still being hit on 5.12-rc6
      Revert "tests: add check for lvconvert without zeroing"
      Revert "thinpool: support lvconvert without zeroing"
      WHATS_NEW: update
      makefiles: fix replacing path for LVM_PATH
      man: typography
      makefiles: improved hyphenation replacement
      makefiles: generate only needed text
      man: use editline reference
      man: with internal build install cache, thin, vdo
      man-generator: decorate optional option prefixes
      man-generator: use \(em
      man-generator: markup updates
      tools: correct units description
      commands: update definitions for thin creation
      args: documentation enhancements
      man: typography fixes
      man: typography for raid and report
      man: replace empty lines
      make: generate
      lvmcache: fix memory leak
      pvscan: fix memleak
      device_id: fix memleak and free idname
      devicesfile: use pool memory
      dev-cache: change message level to debug
      cov: ensure there is space for 0 at eol
      cov: set error_vg only when pointer is non null
      cov: avoid leak when repeating options
      cov: add checks to prevent NULL dereference
      cov: check _insert_dev return value
      cov: check label_read_pvid return value
      cov: avoid passed invalid dummy structure
      cov: check setup_devices return code
      cov: daemonize avoid leak of FD on error path
      cov: add explicit check for external not being null
      cov: ensure segtype is not null
      cov: ensure fid is not null
      cov: fix typo and reduce stack usage
      cov: check return value
      cov: explicitely ignore return value
      cov: use correct enum type
      cov: convert to code that analyzer may better understand
      clang: always initialized values
      clang: avoid possible use-after-free
      clang: ensure vg is defined
      clang: remove unused assignment
      shellcheck: updates
      args.h: bold command refference
      man: document fsadm -l option
      man: add missing _iorig suffix
      man: add some resizing examples
      makefiles: add target for man-generator
      cleanup: indent
      tests: use should for expected state
      make: generate


