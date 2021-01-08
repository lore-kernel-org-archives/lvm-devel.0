From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  8 Jan 2021 09:11:38 +0000 (GMT)
Subject: v2_03_11 annotated tag has been created
Message-ID: <20210108091138.325E9386F419@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1e3f426680503e21cdb3d565c4788aead662de48
Commit:        1e3f426680503e21cdb3d565c4788aead662de48
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2021-01-08 09:09 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2021-01-08 09:09 +0000

annotated tag: v2_03_11 has been created
	    at 1e3f426680503e21cdb3d565c4788aead662de48 (tag)
       tagging 3e8bd8d1bd70691f09a170785836aeb4f83154e6 (commit)
      replaces v2_03_10

Release 2.03.11

- Improvements to VDO, writecache and integrity volumes.
- And lot of bugfixes.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJf+CE6AAoJELkRJDHlCQOf4w8QALmaertFEgsz6F3YopsVX9s7
O1QlYyrLAdGOwHLUnfPhXGcdZbVAujDo25bMDxnocPvb4pfW+qttM2DfLzQ52ppR
JoC2IvF1M1kfxszSn5OIL+2jOjTLigfr7G/1ytmk8+LUT/cPEdv8azI9RfFRG99D
oOZ5zzJpZhToxm8h4eMp7bVg3C6WCj9YfUXcfDUG0yKJPKFZUqPN3iQWfuWiUHQr
mZf6YDSMlwGFCKMbHDFVw8HXke0Weqb4xZlPjbrcAvi9MizdbH+V6RtBrOmmtvfm
yJoKkL9ig3av1BxfjJc4Iu9q23vt1oHbtRG8p/qL6zBl3oYvYDltT6zU2ILjNpz8
B6wOBYPgETRgZQW8+4BvbQt0OKZ3Mioz0idt3uuqRQNO6kIQfPctdjKUTliEKEN/
1/urausVX+l3ov02q9AaREYAUg+iEfLeDQca2srbP0sdga/ZW/Qrs9a6Km134ERj
xylUtlxDYo0nfAGYsm6M7v9D5RiTnvAvPndGGLRNqHtL8hMY4+eE1VTov+4Iblyf
s0Ku2+oywsjZE5h0T3k9wdfQBija7vGvhqSDGul1DG1cZH9ukE881bgIcxebvgi+
SIhRolQBbytocfWUjfoxhGPO5qexnHsqpxxAeR4TiFeFInKzkZwCztA9DYOjSpNv
bJtUAaXLCZbem4NBeMm5
=UYke
-----END PGP SIGNATURE-----

Bastian Germann (1):
      lvm: add readline alternative editline

David Teigland (62):
      Revert "lvdisplay: dispaly correct status when underlying devs missing"
      integrity: always default to journal mode
      integrity: report raidintegritymode randintegrityblocksize
      integrity: report mismatches
      tests: add new integrity reporting fields
      integrity: fix segfault for lv with no seg
      integrity: improve lv type checks
      hints: remove warning when clearing hint file
      pvck: repair should clear hints
      writecache: allow pvmove on origin
      tests: fix pvck repair in hints.sh
      integrity: fix segfault reporting integrity for other lvs
      Revert "label: use formaters FMTu64 and FMTsize_t"
      label: cleanup set_byte error exit
      hints: enhance debug messages
      configure: enable integrity by default
      bcache: use indirection table for fd
      metadata: open rw fd before closing ro fd
      devices: fix reopen for unopened device
      scanning: keep open an lvm device with scanning problem
      lvpoll: don't use hints
      tests: add case for metadata checksum differences
      lvmlockd vdo: disallow use of shared lock on LV
      lvmlockd vdo: add support
      pvcreate/pvremove: reimplement device checks
      writecache: use two step detach
      tests: enable writecache test that uses cleaner
      devices: support printing the filter that rejects a device
      improve message for invalid device arg
      improve message for invalid device arg in process_each_pv
      lvconvert: move log message to fix segfault
      tests: writecache-misc disable with lvmlockd
      filters: allow filter wipe for one device
      filters: nodata option
      scanning: improve filtering control
      lvmcache: add lvmcache_get_dev_mda
      lvmcache: rename label_read label_scan_dev
      add label_read_pvid
      add label_scan_devs_cached
      pvscan: rework to improve PVs without metadata
      get dev size when setting pv device
      pvcreate: clean up opening and filtering of args
      lvchange: allow syncaction check with integrity
      writecache: disallow partial or degraded activation
      pvck: handle first mda at non-4096 offset
      pvck: fix dev filtering
      tests: revert lvm shell use in pvck-dump
      Revert "tests: revert lvm shell use in pvck-dump"
      pvck: fix previous commit
      writecache: supported in dm-writecache version 3
      tests: update integrity tests
      integrity: display total mismatches at raid LV level
      tests: integrity mismatch checks for all raid levels
      lvchange: fix error for foreign vg activation
      man: vgsplit source and destination VGs
      lvm.conf: remove reference to locking_type
      udev rule: remove lvmetad comments
      man lvmcache: add writecache cleaner info
      cache: activation cache_check on cachevol
      writecache: fix uncache for two step detach
      partial flag for writecache and integrity
      lvconvert: chunksize option was missing with cachedevice

Heinz Mauelshagen (1):
      Revert "lvconvert: display warning if raid1 LV image count does not change"

Marek Such????nek (1):
      man: update writing style of the lvmvdo man page

Marian Csontos (9):
      post-release
      Update README
      test: grep -q may fail and it does
      Revert "tests: Adapt RAID test to changes"
      gitignore: ignore gcov files
      make: generate
      build: make generate
      configure: update
      pre-release

Wu Guanghao (3):
      pvmove: check return value of top_level_lv_name()
      lvconvert_poll: ensure LV has snapshot type
      lvconvert: check if LV has snapshot type

Zdenek Kabelac (204):
      config: move some config setting into commented part
      man: vdo improvals
      wipe_lv: close devices on error path
      config: drop reading file with mmap
      tests: check we detect lvm.conf read failure
      container_of: drop needless const converion
      writecache: correct usage of const struct
      lvmcache: use uint32_t for seqno caching
      lv_manip: get_default_region_size return uint32_t
      gcc: keep unsigned arithmetic
      gcc: avoid stack alloc arithmetic
      gcc: calc size in compile time
      tools: move struct element before variable lenght list
      gcc: use apropriate type for reading and printing values
      gcc: do not use return with void function
      gcc: drop bogus ;
      WHATS_NEW: update
      cachevol: correcting 64b math
      tests: filefrag needs to support -e
      dmsetup: initilize winsize struct
      gcc: zero-sized array to fexlible array C99
      gcc: preserve constness of buffer
      gcc: keep using unsigned type
      cov: always sure we end with '0'
      cov: explicitely ignore function result
      cov: always initialized values
      cov: avoid duplicated assign
      cleanup: matching declaration order
      cleanup: user force_t enums instead of ints
      cleanup: add spaces between literals
      cleanup: better expressing passing key arg to _hash
      pvck: use array of bytes
      pvck: add simple check for fwrite
      gcc: hide warn about possible uninitialized use of dev_ret
      gcc: avoid shadowing of dev_name and pvs
      tests: skip test when gcore cannot catch securetest
      tests: set skipping autoactivation
      tests: slightly faster
      tests: skip this test for current 5.8 5.9 kernels
      tests: add aux delayzero_dev  support
      tests: use delayzero_dev
      lvconvert: flip return value of _raid_split_image_conversion
      lv_manip: add synchronization points
      raid: add _rimage and _rmeta as origin_only
      raid: do not enforce flushing of raids when it is not required
      tests: check for cache_version that supports v2
      tests: check for writecache being compiled in
      tests: tune extend test
      Revert "raid: do not enforce flushing of raids when it is not required"
      Revert "raid: add _rimage and _rmeta as origin_only"
      man: correctly use configured directories
      man: correcting vdo issues
      configure: compile with vdo and writecache by default
      lvextend: improve percentage estimation
      lv_manip: relocate check to proper function
      debug: drop debug trace from regular path
      cleanup: comment typo
      tests: disable dbustest with valgrind testing
      tests: adding "" around DM_DEV_DIR
      tests: aux collects stack trace when stuck is assumed
      lv_manip: even better rounding
      thin: compensate metadata size by extra percent
      alloc: improve estimation of sufficient_pes_free
      tests: have_cache function checks for cache-pool
      tests: lower at_least to version 1.19
      tests: reduce disk space usage by pvck-dump
      tests: check for boundary allocation sizes
      revert "lvconvert: check if LV has snapshot type"
      lvconvert: check if LV has cow type
      cov: drop model for origin_from_cow
      cov: check sscanf result
      cov: drop checking for EWOULDBLOCK
      tests: skip test on failing kernel
      tests: change skip to die for upstream crash
      tests: support for 16T is needed
      tests: avoid using string
      locking: restore blocking signal for VG_GLOBAL lck
      configure: just upper case start of sentence
      headers: remove unused headers
      cache: simplier signal handling
      tests: check in_sync prints also dm status
      tests: improve cache abort test
      tests: raise needed target version
      tests: tune usage of smaller metadata
      tests: protect this test for another kernel
      lvcreate: add extra synchronization at error path
      lvcreate: change error message
      hints: enhance debug with log_sys_debug
      label: code deduplication
      label: deduplicate dev_set_bytes
      wipe: zeroing of 8 sectors is granted
      wipe: convert zero_value to uint8_t
      wipe: dev_set_bytes resolves zeroing
      label: use formaters FMTu64 and FMTsize_t
      tests: skip kernel for this test
      tests: switch for checking version of installed tools
      tests: fix bash regex syntax
      tests: smaller delay and lowered version
      tests: lower memory usage
      tests: bigger data still needed for 0.7.0
      tests: resolve missing removal of loopdevice on error path
      tests: also use sed to shorten log output
      tests: aux better handle invalid table
      tests: utils better handle ouf of disk space
      tests: inittest supports SKIP_WITH_LOW_SPACE
      tests: enhance low-disk-space behavior
      tests: update integrity-dmeventd
      tests:  printf to awk
      tests: reduce disk usage
      tests: ensure mnt is defined before trap install
      tests: use faster awk generator
      tests: use zero backend
      tests: use parametrized function
      bache: fix error return value
      tests: check for cvol
      tests: skip with fail of first prepare_scsi
      tests: use 4K with mkfs.xfs
      tests: use DIRECT io for zeroing whenver we can
      tests: add FIXME case
      tests: fix cleanup for unbound variables
      activation: use revert_lv on tree suspend failure
      vdo: drop unnecessary tabulator from metadata output
      vdo: correct message about policy extend support
      vdo: extend vdo segment validation
      vdo: enhance vdo pool extension
      tests: check vdopool policy extension
      tests: update test
      tests: move function to aux for reuse
      tests: use aux wrapper and add more notes
      vdo: disable support for online rename of vdopool LV
      vdo: allow passing renamed vdopool name to kernel
      lvconvert: suppport vdo raid conversion also through vpool
      tests: a bit bigger mirrors
      tests: add check for rename of cached vdopool
      tests: basic test for vdo on raid LV
      vgsplit: support for VDO volumes
      thin: no delete message for device_id 0
      thin: enhance lvcreate error paths
      thin: improve error message
      device_mapper: enhance error message
      thin: pass through whole code
      makefiles: document supported var in make help
      tests: vgsplit of vdo volumes
      tests: check some common errors
      tests: also add thick snap of thin volume
      tests: add small delay
      configure: editline updates
      configure: update help
      activation: move locking of critical section
      cleanup: avoid unneeded check
      writecache: archive before modification of metadata
      thin: use lv_status_thin and lv_status_thin_pool
      thin: validate thin-pool state before sending messages
      thin: remove unneeded code test
      active: fix compilation without devmapper
      debug: update debug message
      debug: remove stacktrace on regular path
      tests: thin-flags
      configure: check for BLKZEROOUT support
      configure: update with latest AM_PATH_PYTHON
      configure: use our ordered list of python names
      bcache: fix waiting problem for completed IO
      bcache: fix busy loop with too many errors
      bcache: support interrupts when waiting on IO
      bcache: use flexible arrays
      wipe_lv: drop label_scan_invalidate on error path
      wipe_lv: interruptible wiping
      wipe_lv: use BLKZEROOUT when possible
      debug: update messages
      debug: drop FD from error message
      debug: show actually reason for taking this code path
      debug: no backtrace
      debug: drop vgid from debug
      tests: rename shown debug trace
      tests: aux hides zero and error device
      tests: enable tests for lvmlockd
      rpm: bare words are no longer supported
      tests: extend area covered by error target
      properties: fix data_usage typo
      libdm: split code for sending message
      libdm: enhance error message
      libdm: validate thin-pool before sending messages
      debug: shorten error message
      dm: remove created devices on error path
      cov: split check for type assignment
      libdm: relocate code for sending messages
      lvmcmdlib:  lvm2_init_threaded
      memlock: allocate at most halve of rlimit stack
      tests: check dmevent with bigger reserved_stack
      fsadm: use NULL
      fsadm: handle fsck return 1 for corrected fs
      fsadm: enhance error handling
      tests: fsadm test continue after fs repair
      lv_manip: add space into message
      man: more precise UNIT
      man: regenerate
      WHATS_NEW: update
      fsadm: better check for getsize64 support
      tests: minor update
      gcc: cleanup warns from older gcc
      man: update vdo
      man: update lvmvdo
      fsadm: fix unbound variable usage
      tests: few more fsadm checks

Zhao Heming (3):
      lvdisplay: dispaly correct status when underlying devs missing
      gcc: change zero-sized array to fexlible array
      gitignore: ignore all cscope generated files


