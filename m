From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 24 May 2018 11:35:50 -0400
Subject: v2_02_178-rc1 annotated tag has been created
Message-ID: <201805241535.w4OFZodQ026907@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=deb1c80ba74b083ead9a158998c3e817b0e9fa72
Commit:        deb1c80ba74b083ead9a158998c3e817b0e9fa72
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-05-24 13:15 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-05-24 13:15 +0000

annotated tag: v2_02_178-rc1 has been created
	    at deb1c80ba74b083ead9a158998c3e817b0e9fa72 (tag)
       tagging adae8ee1c2926d59c85dc9fc253375f07f262819 (commit)
      replaces v2_02_177

Release 2.02.178 Release Candidate 1

Major changes:

Remove support for historical lvm1 and GFS pool formats.
Major changes in label scanning.
Use libaio.

See doc/release-notes/2.02.178 for details.

Alasdair G Kergon (50):
      post-release
      device: Move dev_read memory allocation into device layer.
      label: Add mempool.
      label: Move setting result of label_read into separate fn.
      label: Move _set_label_read_result call into _find_labeller.
      label: Wrap _find_labeller params into a struct.
      config: Split config buffer processing into new fn.
      toolcontext: Add paired label_init to refresh_toolcontext.
      format_text: Split the text import fns into two pieces.
      format_text: Allocate update_mda baton from mempool.
      format_text: Split up _update_mda.
      format_text: Split out raw_read_mda_header processing
      format_text: Split vgname_from_mda into three pieces.
      metadata: Change the new data processing fns to void.
      metadata: Use a consistent format for callback fn parameters
      device: Introduce dev_read_callback
      label: Add callback fns (partially)
      label: Add label_read callback.
      format_text: Use vgsummary callbacks
      libdm: Introduce dm_malloc_aligned
      label: Rename a variable
      format_text: Use malloc aligned for export buffer
      allocation: Avoid exceeding array bounds in allocation tag code
      device: Keep the last data buffer read off each device.
      device: Free cached device bufs when metadata invalid or dev closed.
      device: Remove some data copying between buffers.
      device: Suppress repeated reads of the same data.
      device: Eliminate unnecessary buffer from dev_read.
      device: Mark read-only device buffers const.
      config: Move use_mmap to local variable.
      label: Clean up storing of device and label sector.
      man: regenerate
      libdm: Fix a size_t in _dm_malloc_aligned_aux message.
      command: Skip some memory zeroing.
      device: Reorder device.h before change.
      device: Store offset to data instead of pointer.
      device: Add reason to devbuf.
      device: Rearrange _aligned_io().
      format_text: Change update_mda_baton to use label not labeller
      format_text: Refactor mda counting in label processing.
      device: Merge _dev_read and dev_read_callback.
      device: Move buffer allocation nearer to the I/O.
      device: Add ioflags parameter to transfer additional state.
      callbacks: Miscellaneous fixes for recent changes
      device: Add flag to indicate that a code path can support AIO
      device: Basic config and setup to support async I/O.
      lvmcache: Use asynchronous I/O when scanning devices.
      device: Queue any aio beyond defined limits.
      device: Fix basic async I/O error handling
      format_text: Use versionsort to sort archive files

Alex Benn??e (1):
      bcache: don't use PAGE_SIZE compile const

David Teigland (123):
      lvmlockd: clear coverity complaint
      man lvmlockd: update wording
      lvmlockd: add lockopt values for skipping selected locks
      lvmlockd: print warning when skipping locking
      man lvmlockd: remove lv resizing comment
      [device/bcache] fix missing max_io fn in bcache async engine
      [device/bcache] fix min() function
      [device/bcache] bcache_read_bytes should put blocks
      [makefile] add -laio to makefiles
      scan: use bcache for label scan and vg read
      scan: use new label_scan for lvmcache_label_scan
      scan: do scanning at the start of a command
      label_scan: fix independent metadata areas
      independent metadata areas: fix bogus code
      lvmetad: use new label_scan for update from lvmlockd
      lvmetad: use new label_scan for update from pvscan
      vgcreate: improve the use of label_scan
      label_scan: remove extra label scan and read for orphan PVs
      lvmcache: simplify metadata cache
      format-text.c log message fixes
      pvremove: device check doesn't require label_read
      process_each_label: use lvmcache
      scan: use separate fd for bcache
      scan: add a dev to bcache before each read to handle write path
      scan: handle no devices
      remove unused variable in _pvremove_check_single
      remove debugging print
      scan: handle request to scan missing dev
      scan: skip extra scan in vg_read
      vgremove: fix force remove on devs with damaged metadata
      scan: setup bcache for commands using lvmetad
      scan: leave the caller's dev list unchanged
      scan: always setup bcache for commands using lvmetad
      lvmdiskscan: use the new label_scan
      disable LVM1 tests
      test: vgsplit-usage if LVM1 tests
      scan: use 128K bcache block size
      pvck: use bcache
      scan: put dev back on caller's list
      scan: drop bcache and close fd for LV with stacked PV
      vgchange: invalidate bcache for stacked LVs when deactivating
      misc bcache fixes from ejt
      bcache: do all writes through bcache
      bcache: use wrappers for bcache read write in lvm
      scan: create bcache with minimum number of blocks
      bcache: add some error messages for debugging
      scan: invalidate bcache for dev after errors
      scan: add function to drop bcache blocks
      bcache: fix error handling
      lvmcache: add shorter way to delete dev info
      scan: remove lvmcache info for failed devs
      scan: check for errors in text layer
      clvm: fix bcache scan handling
      lvmetad: fix process_each_label
      lvmetad: need to set up bcache in another place
      lvmetad: more fixes related to bcache
      tests: vgck now exits with error for bad vg
      scan: drop bcache between lvm shell commands
      bcache: let caller see an error
      scan: improve io error checking and reporting
      remove unnecessary REQUIRES_FULL_LABEL_SCAN
      dev_cache: clean up scan
      lvmcache: simplify
      bcache: intercept test mode before write
      lvmpolld: update to use new scanning correctly
      scan: skip device rescan in vg_read
      liblvm2app: missed the addition of lvmcache_label_scan
      clvm: rescan when VG or PV not found
      lvmcache: rename suspended_vg to saved_vg
      clvmd: reuse a vg struct for sequential LV operations
      clvmd: skip dev rescan after full scan
      skip some clvmd-specific code in common cases
      scan: don't use cmd mem pool in scan
      pvmove: in fork mode destroy bcache in child
      scan: refresh filters before scan
      clvmd: drop old saved_vg when returning new saved_vg
      test: remove pv-duplicate
      toollib: fix wrong dev reference in process_each_label
      clvmd: keep old saved_vg if it matches new
      tests: fix THIN built-in check
      clvmd: don't repair vg from vg_read in clvmd
      Remove lvm1 and pool disk formats
      lvmcache: fix typo in lvmcache_get_saved_vg
      bcache_write_bytes needs to be followed by flush
      tests: update lvmetad-disabled to not use lvm1
      tests: remove gfs pool test
      tests: remove use of lvm1 metadatatype
      devices: ignore lvm1 and pool devices
      tests: add gfs-pool test
      filters: increase MAX_FILTERS for new filter
      clvmd: defer freeing saved vgs
      clvmd: separate saved_vg from vginfo
      clvmd: don't save cft and buf for saved_vg
      clvmd: saved_vg code and comment formatting
      doc: lvm disk reading
      io: replace dev_set with bcache equivalents
      doc: add filter info to scanning
      filter: use bcache for filter reads
      pvscan: remove unused var warning
      io: write log header with bcache
      pvck: allow checking at user specified offsets
      bcache: disable fallback to old io
      dev_cache: drop open_list
      dev_cache: fix close in dev_get_block_size
      devs: recognize md devices in subsystem check
      scan: remove unused args from label_read
      dev_cache: fix close in utility functions
      dev_cache: remove the lvmcache check when closing fd
      scan: ignore duplicates that are md component devs
      scan: add some missing frees
      lvmcache: fix loop freeing infos
      WHATS_NEW: updates
      scan: use up to 1024 max bcache blocks
      doc: add some performance info
      scan: fix missing close in lib
      liblvm2app: fix valgrind memory warning
      liblvm2app: add a couple tests
      fix id_write_format on non-uuid string
      fullreport: fix with lvmetad and only orphan PVs are visible
      lvmlockd: suppress error messages related to lvmetad
      man vgexport: expand description
      scan: move warnings about duplicate devices
      filters: clarify some parts of md filter

Heinz Mauelshagen (9):
      raid: support raid5_n convenience type on conversion to raid10
      dev_manager: always activate RAID SubLVs readwrite
      lvcreate: remove RaidLV on creation failure
      test: add lvcreate-raid-volume_list
      lvconvert: don't return success on degraded -m raid1 conversion
      raid: use new internal APIs
      tests: don't rely on cache target in component-raid.sh
      tests: bump raid target version in reshape tests
      tests: fix kernal_at_least argument in aux.sh

Joe Thornber (106):
      [io paths] Unpick agk's aio stuff
      [device/bcache] Initial code drop.
      [lib/device/bcache] Tweaks after Kabi's review
      [build] Quieten the build down
      [unit tests] remove old unit tests that weren't built or run.
      [git] Update .gitignore
      [device/bcache] stub a unit test
      [device/bcache] some more work on bcache
      [device/bcache] Add a couple of invalidate methods
      [device/bcache] Add bcache_max_prefetches()
      [device/bcache] fix bug in _alloc_block
      [device/bcache] another unit test
      [device/bcache] rename a unit test
      [build] include test/unit/Makefile rather than recursive build
      [device/bcache] More tests and some bug fixes
      [device/bcache] add bcache_prefetch_bytes() and bcache_read_bytes()
      [device/bcache] More fiddling with tests
      [device/bcache] more work on bcache
      [git] Update .gitignore
      Merge remote-tracking branch 'sourceware/master' into upstream
      [unit-test] Push the new unit test framwork.
      [bcache] get all unit tests passing again
      [bcache] Add some unit tests for invalidate block.
      [bcache] Some work on bcache_invalidate()
      bcache: write some sanity checks for the asyn io engine
      build: Stop creating the symlinks in include/ on the fly.
      Revert "build: Stop creating the symlinks in include/ on the fly."
      build: Stop creating the symlinks in include/ on the fly.
      unit-tests: Move to test/unit
      build: Calculate dependencies at same time as compiling.
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2 into merge
      build: rename configure.in -> configure.ac
      [build] uncomment 'serial 3' in an m4 file.
      [lvmetad.h] Use static inline functions to stub out functions.
      [metadata-liblvm.c] comment out some dead code and add a FIXME
      [scripts] remove scripts/vg_convert
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      build: remove --with-{snapshots,mirrors,raid,thin,cache} options from ./configure
      build: Remove unused Makefiles from configure.ac
      build: fix typo in dmeventd/plugins/Makefile.in
      vdo: Code drop for status parsing.
      configure: Remove --enable-testing
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      unit-test/io_engine_t: use posix_memalign() rather than aligned_alloc()
      unit-test/io_engine_t: Improve the read test.
      unit-test/bcache_t: fixup a test.
      unit-test/io_engine_t: add a little test for bcache_{read,write}_bytes
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      bcache: rewrite bcache_{write,zero}_bytes
      build: update ./configure and configure.h.in
      unit-test/bcache_t: Use a stripped down fixture for some tests
      bcache: squash some warnings on rhel6
      unit-test/bcache_t: test was using too large a block size
      Revert "build: Stop creating the symlinks in include/ on the fly."
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      Merge branch 'master' into 2018-04-30-vdo-support
      vdo: get status parser compiling
      unit-test/matcher_t: add another (failing!) test for Kabi
      unit-test/matcher_t: Fixup Kabi's test
      build: add -D_FILE_OFFSET_BITS=64
      device/bcache: reorder includes
      bcache: reorder includes in .c file too
      bcache: add a comment
      bcache: add bcache_block_sectors() query fn
      bcache: Move the utils to a separate file.
      bcache: switch off_t -> uint64_t
      bcache: rewrite bcache_write_zeros()
      bcache: rename bcache_write_zeroes() -> bcache_zero_bytes()
      bcache-utils: rewrite
      configure.ac: Remove some more remnants of optional RAID
      functional tests: Update have_raid function
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      configure.ac: bad configure generated due to stray ;;
      unit-test: a bunch of tests for bcache-utils
      Merge branch '2018-05-03-improve-bcache-utils'
      Revert "build: Calculate dependencies at same time as compiling."
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      Merge branch 'master' into 2018-04-30-vdo-support
      unit-test/bcache-utils: Tweak zero tests
      bcache-utils: bcache_set_bytes()
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      Merge branch 'master' into 2018-04-30-vdo-support
      vdo status: Unit tests + fix bugs
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      bcache: knock out err param.
      bcache: Add sync io engine
      functional-tests/vdo: fix mem leak in test
      label/lv_manip: squash some warnings
      bcache/sync io engine: handle short ios
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      radix-tree: First drop of radix tree.
      doc: add a little document describing new directory structure.
      radix-tree: remove some unneccessary includes
      radix-tree: fix a function decl
      bcache: nr_ios_pending wasn't being incremented
      Merge branch 'master' of git://sourceware.org/git/lvm2
      unit-tests: remove a couple of debug printfs
      scripts: add a little scripts to show git history for the last 2 weeks.
      scripts/code-stats.rb: count files better, handle bad utf8
      Merge branch 'master' of git://sourceware.org/git/lvm2
      bcache: Don't call sysconf for every io
      WHATS_NEW: typo
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      release note: 2.02.178
      release note: typo
      release note: typos

Jonathan Brassow (1):
      clean-up: example.conf.in typo

Marian Csontos (7):
      doc: Add VDO stacking document
      test: mirrored mirrorlog is not supposed to work in cluster
      mirror: Add deprecation warning for mirrored log
      doc: Fixing VDO document
      tests: check vgsplit thin-data and ext.origin
      test: Skip tests which require too much RAM
      pre-release

Martin Wilck (2):
      udev: explicit pvscan rule in 69-dm-lvm-metad.rules
      udev: keep systemd vars on change event in 69-dm-lvm-metad.rules for systemd reload

Rick Elrod (1):
      cleanup: fix grammar in output - less then -> less than

Tim Foerster (1):
      lvmdbusd: Remove duplicated DataPercent definition

Zdenek Kabelac (223):
      lvm-string: add function to detect component LV suffix
      tests: sleep first
      lvconvert: use excl activation for conversion
      pvmove: fix _remove_sibling_pvs_from_trim_list
      pvmove: better check for exclusive LV
      pvmove: drop misleading pvmove restriction for cluster
      dmeventd: add check for result code
      activation: guard exclusive activation
      cleanup: enhance messages
      cleanup: drop unused code
      tests: properly test with clustered VG
      tests: check preserved exclusivness of snapshot merge
      tests: longer startup timeout for daemons with valgrind
      tests: check pvmove is merging segments
      activation: move check later
      python: some LVs do need exclusive activation
      debug: drop DEBUG_MEM path
      tests: update set of devices
      dev_io: fix writes for unaligned buffers
      pvmove: reinstantiate clustered pvmove
      libdm: accept mirror status with userspace word in the line
      configure: ensure path /usr/sbin is checked for some tools
      toolcontext: do not change stream for pthreaded programs
      partial revert "command: Skip some memory zeroing."
      python: add devmapper library to linking
      toolcontext: light context missed to set-up mem mempool
      libdm-stats: correct checking of dm_snprintf error
      vgimportclone: add some dm_snprintf checks
      clean: drop unneeded -1 for snprintf
      lvmlockd: improve dm path creation for sanlock LV
      cleanup: detect  dmeventd_executable just once
      activation: separate reporting of error and monitoring status
      activation: cleanup error to warning
      cleanup: decode dso path just once
      segtype: better get_monitor_dso_path api
      debug: add stack tracking
      segtype: replace mempool allocation
      segtype: no libmem pool usage for name allocation
      gcc: remove warns about free of const
      cleanup: add missing WARNING
      locking: exclusive can be either remote or local
      pvmove: enhance accepted states of active LVs
      tests: update
      sanlock: set proper return value
      locking: move cache dropping to primary locking code
      debug: capture internal error for too long resource name
      tests: correct usage of pipe
      coverity: missing free on error path
      raid: add free for error path
      io: keep 64b arithmetic
      lv_manip: enhance for_each_sub_lv
      command: use bigger buffer
      lvremove: drop unneded check
      lvresize: check external origin with new size
      tests: check inactive extorig resize
      debug: change message severity
      cleanup: unused header file
      cleanup: explicitely ignore result code
      cleanup: use lv_is_used_cache_pool
      cleanup: indent
      thin: pass environment to scripts
      raid: fix error path for lv_raid_data_offset
      raid: move VG update after archiving happened
      lvcreate: fix activation of cached LV
      lvremove: drop duplicate check for active LV
      cleanup: more usage of dm_strncpy
      debug: update comment
      activation: add base lv component function
      lvremove: validate removed component LV is not active
      lvremove: ensure no subLV is active
      lvconvert: support for convertsion with active component devices
      activation: support activation of component LVs
      activation: support proper /dev names for component LVs
      tests: component activation
      tests: skipping test waiting for fixed kernel
      snapshot: keep COW writable for read-only volumes
      snapshot: skip invalid snapshost
      cache: fix lock usage for cache conversion
      cleanup: use log_warn
      cleanup: all tests needs target_type
      raid: skip frozen raid devices
      cleanup: use path on stack
      scanning: skip more private devices
      mirror: correct locking for mirror log initialization
      dmsetup: use stderr for error output
      dmsetup: cleanup err usage
      dmsetup: stderr to log_error
      dmsetup: join large fprintf
      dmsetup: update messages
      dmsetup: update _display_info
      dmsetup: use dm_snprintf
      dmsetup: report close as debug
      cleanup: matching signess
      dmsetup: indent
      tests: try unfreezeing raids
      libdm: support for DM_DEBUG_WITH_LINE_NUMBERS
      devcache: add reason and always log_error
      dmsetup: loop output table as verbose
      dmstatus: check nr_regions ahead of find call
      libdm-stats: fix error messages
      locking: introduce prioritized_section
      activation: check for prioritized_section
      cleanup: missing dots and indent
      tests: fix running tests on systems without udevd
      tests: use DM_DEBUG_WITH_LINE_NUMBERS
      tests: skip test when not enough space
      activation: separate prioritized counter
      pools: skip checks when tools are missing
      raid: fix version check of target
      lvconvert: accept striped LV as snapshot COW LV
      coverity: add missing error check for str_list_add
      coverity: ensure lock_type is not NULL
      coverity: validate descriptor
      coverity: make use of defined variable
      coverity: move declaration out of the loop
      coverity: drop unneeded header files
      coverity: drop unused local static var
      cleanup: use direct initializer
      cleanup: use zalloc
      tests: test striped COW LV
      tests: check activation of cache without cache_check
      tests: use 4k extents
      cache: disallow to combine format 2 with mq
      cleanup: typo fix
      tests: update no tool test
      libdm: enhance mounted fs detection
      tests: handle setting better
      fsadm: shellcheck prefer explicit escaping
      tests: shellcheck prevention check
      tests: shellcheck use grep -E
      tests: shellcheck liter
      tests: shellcheck split assing
      tests: shellcheck misc
      pvmove: support properly subLV locking
      thin: restore usability of thin for external origin
      lvconvert: drop limitation for converting lv
      activation: add generic rule for visibility change
      mirror: fix 32bit size calculation
      mirror: improve mirror log size estimation
      mirror: fix calcs for maximal region_size
      mirror: fix region_size for clustered VG
      mirror: block_on_error only with monitoring
      mirror: properly reload table for log init
      mirror: validate region_size for mirrors
      mirror: checking for mirror segtype
      mirror: use vg mempool
      cleanup: call uname once
      cleanup: reorder condition
      cleanup: correct casting
      cleanup: add _mb_ to regiosize option
      cleanup: display_lvname update message
      cleanup: enhance debug message
      cleanup: correcting macro wrapping
      cleanup: avoid compiler warn
      coverity: ensure 0 end string
      tests: update mirror test
      tests: improve mirror_images_redundant
      gcc: remove duplicate typedef
      lvchange: update mirror table when changing monitoring
      lvconvert: preserve regionsize from existing mirror
      debug: more explanatory error message
      tests: update testing to not use delay dev
      tests: more zero usage
      aux: enhance teardown to better handle weird names
      mirror: improve table update
      tests: add also snapshot monitoring
      poll: add stdout fflush after poll query
      tests: raise min size for XFS
      tests: happy using of 4K backend devices
      tests: crypt test cannot run on ramdisk
      tests: try running tests over ramdisk
      tests: aux support throttling of dm mirror
      tests: use throttle_dm_mirror
      tests: move device discard
      tests: using throttling
      tests: drop delaying
      tests: again disable this raid test
      tests: aux extra protection for rm -rf
      tests: inittest compare string
      tests: inittest may run without root
      build: properly track source file for lmvlockctl
      tests: add support to run unit test
      tests: drop cache checking
      build: make generate
      bcache: do not use libdm header files
      build: fix build rules for srcdir
      build: rename device-mapper to device_mapper
      tests: detect running bcache test on tmpfs
      tests: add unit-test
      build: install unit-test
      build: lcov reporting for unit tests
      tests: aux detecs supported segments
      tests: restore functionality
      tests: do not try to create 1K extents
      tests: fix check sysfs
      tests: start to use 4k mkfs
      tests: swith to mkstemp
      tests: old systems do not have even throttling
      tests: dont try to use DAX based brd device
      tests: fix size of COW
      conf: update conf
      build: configure detect libaio
      tests: move into generated file
      tests: drop junk
      tests: time limit waiting on lvmetad kill
      tests: aux fixes
      python: specify libdm path for linking
      tests: better check for python libpath
      lvmapp: do not unlock not locked VGs
      build: set clean vars earlier
      python: use python3 paths directly
      tests; make sure python_lvm_unit.py is executable
      tests: pick either python2 or python3 .so
      python: use // for integer division
      tests: use 4K extent size
      tests: disable symlink test
      gitignore
      man: fix cut and paste bug
      man: make generate
      tests: aux improve for mdadm support
      tests: correcting symlink manipulation
      tests: passthrough args with extend_filter_LVMTEST
      tests: checking scanning correctness


