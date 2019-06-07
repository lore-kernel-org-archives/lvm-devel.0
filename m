From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 7 Jun 2019 11:31:21 -0400
Subject: v2_03_03 annotated tag has been created
Message-ID: <201906071531.x57FVLMu029680@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b97b215be1e22c0b621ee7092359ce827e0a0d82
Commit:        b97b215be1e22c0b621ee7092359ce827e0a0d82
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2019-06-07 15:25 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2019-06-07 15:25 +0000

annotated tag: v2_03_03 has been created
	    at b97b215be1e22c0b621ee7092359ce827e0a0d82 (tag)
       tagging cb6277aa8a1f6d0dedf2082995b1673da1eb46f9 (commit)
      replaces v2_03_01

Release 2.03.03

Bugfix and Feature Release

Notable changes:

- Add pvck --dump option to extract metadata from disk.
- New scan_lvs option, defaultingo to 0 so LVs are not scanned for PVs.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJc+oHSAAoJELkRJDHlCQOfYCgP+wcaZnBOECd/3mcsiMK9fu5u
zl/+akrGmJhWvvreLOXD5gP8ayLJpTx+8lx8FdHbp1Vt/0nFRrBixMv8TAlsw1Kk
5UcEx3HPv6p5lgKBOIFojgG40KrV48IazRUhF0B002lHuqxqi4ArzvXGaGn0hngR
zEg/948fgsfRDnvUlc2aUmKl2OKK1m5kCciwvihjDX7eL4xWa6ZfGf9ibeZ8JMqk
w10MJdDqs727TgDDCQtrnLpdLjrKf+QMx2O4Tl//73ygw45EQ4sCtwd4q9VF+RPB
+AxAuRiPGlEQc2BntLEru5Qr6cAR5ne8JphIlb2Hs7yuQgzttPBRwkaR+A00HahI
w6STjKFSlnWeY3QNfo/hMc+MSWoEt6tgBNqvckf3Hhny4Wu3L2tznlRRSnpThxKj
+Haq7DznR3i1Zm2gzfQ9IMNkdu673i0HWFj1fkt53pJBCcjkRmZw6ld4jmgQaR5g
nIfeAsDE9L2T6vn8x3TFCouw3bCX1PcgpNGyUT6b9zy/BkDjPdSLy0yeX3vhHiD4
Gt5htIKgo1Rk3n7vlOL8IN19vSbHUiNf1RAFPZjexznlbf3h9GM54PYpxmvXf1gF
gwG0L3C9iAec9r5kooQ2IzizFBTVw+OadthYKoTdWotYAWEaa/cJ7opgfJlikscb
W/c0EZGXVo63pqJOR7Px
=gYZd
-----END PGP SIGNATURE-----

Alasdair G Kergon (1):
      dmsetup: Fix multi-line concise table parsing

Bryn M. Reeves (2):
      libdm-stats: move no regions warning after dm_stats_list()
      dmsetup: fix stats report command output

David Teigland (150):
      lvmlockd: use new sanlock sector/align interface
      lvmlockd: fix size/resizing of internal lvmlock LV for sanlock
      lvmlockd: deactivate lvmlock LV in vgchange
      lvmlockd: fix handling of sanlock release error
      lvmlockd: use standard major minor functions
      cache: add cache_mode_num_to_str
      cache: factor settings text import export
      cache: factor getting cache mode
      cache: clean up segment line creation
      cache: rename variable in _cache_display
      cache: rename variable in _cache_add_target_line
      cache: improve warning message about cached thin data
      cache: improve error message about flush
      cache: reorganize cache_set_policy
      cache: factor report functions
      cache: factor lvchange_cache
      Allow dm-cache cache device to be standard LV
      Add dm-writecache support
      devices: reuse bcache fd when getting block size
      tests: fix dd option in cache-single-options
      tests: enable writeback in cache-single-options
      tests: enable cachepolicy cleaner in cache-single-options
      tests: add lvchange cachemode passthrough in cache-single-options
      tests: specify m1 for raid1 in cache-single-types
      man: lvmcache update
      man: remove cluster references
      man: remove clvmd man page
      man lvmdump: remove clvm reference
      man: remove lvmetad
      man pvscan: replace lvmetad text
      pvscan: background option is not used
      man: pvscan updates
      remove unused backgroundfork option
      man: remove scattered lvmetad references
      man: remove some clvmd references
      lvm2-monitoring service shouldn't refer to lvmetad
      scripts: remove lvmetad from makefile
      io: use sync io if aio fails
      bcache: sync io fixes
      WHATS_NEW: sync io
      writecache: set block_size using --cachesettings
      pvscan systemd service for event based activation
      blk_availability service drop lvmetad
      Place the first PE at 1 MiB for all defaults
      lvmlockctl: wait by default when stopping
      lvmlockd: vgchange locktype with yes option
      config settings: fix version 3.0.0
      devs: use udev info to improve md component detection
      pvscan: use correct dev filters
      remove unused lvmetad filter
      remove unused full filter
      man lvmlockd: lvextend with gfs2
      tests: lvm-on-md udev issues
      lvmlockd: fix missing LV lock for lvconvert repair
      unit test: use_lvmetad replaced by event_activation
      Revert "lvconvert: use standard wiping code"
      writecache: prompt before using an LV to hold cache
      writecache: use wipe_lv to warn about specific signatures
      add device hints to reduce scanning
      WHATS_NEW: device hints
      hints: fix hint flock when using lvm shell
      lvmlockd: make lockstart wait for existing start
      move init_use_aio
      lvmlockd: fix make lockstart wait
      hints: invalidate when pvscan --cache sees a new PV
      vgscan: drop 'take a while' message
      tests: use pvscan after enable_dev in process-each-duplicate-vgnames
      apply obtain_device_list_from_udev to all libudev usage
      hints: fix recreating hints from pvscan
      config: change scan_lvs default to 0
      tests: set scan_lvs=1 in tests that stack PVs on LVs
      WHATS_NEW: scan_lvs default change
      pvscan: fix autoactivation from concurrent pvscans
      pvscan: autoactivate a VG once
      WHATS_NEW: concurrent pvscan autoactivation
      logging: add command[pid] and timestamp to file and verbose output
      pvscan: fix hint recreation
      logging: new config settings to specify debug fields
      config: make hints setting commented
      Use "cachevol" to refer to cache on a single LV
      pvscan service: use StartLimitIntervalSec
      logging: remove unused code
      remove unused io functions
      config: add new setting io_memory_size
      io: warn when metadata size approaches io memory size
      io: increase the default io memory from 4 to 8 MiB
      WHATS_NEW: io_memory_size
      pvscan: ignore online for unused PV
      pvscan: ignore online for shared and foreign PVs
      tests: check that pvscan --cache ignores certain PVs
      config: improve scan_lvs description
      pvscan: fix ignoring foreign PVs
      warn about changes to an active lv with shared lock
      lvextend: allow on LV active with a shared lock
      lvextend: refresh shared LV remotely using dlm/corosync
      lvextend: refresh shared LV using select option
      lvextend: refresh shared LV with vgname as arg
      lvresize: fix when compiled without lvmlockd
      lvextend: refresh shared LV without using select
      lvmlockd: do not allow mirror LV to be activated shared
      man: updates to lvmlockd
      pvscan: reorganize code
      pvscan: for init only autoactivate vg for named dev
      pvscan: remove initialization case
      pvscan: don't print warning about lvmlockd not running
      tests: update pvscan-autoactivate for init change
      pvscan: print more reasons for ignoring devices
      pvscan: ignore device with incorrect size
      WHATS_NEW: add several recent changes
      hints: fix case of error getting device size
      hints: fix non-empty hints list when not using hints
      tests: disable unworking pvscan case
      pvscan: handle case of scanning PV without metadata last
      wipe_lv: initially open LV in writable mode
      locking: unify global lock for flock and lockd
      remove retry for missed PVs in process_each_pv
      hints: skip hint flock if nolocking option is set
      pvscan: remove fixme comment that is fixed
      pvcreate: call label scan prior to pvcreate_each_device
      vgcreate: remove the lvmcache locking workaround
      lvmcache: remove unused flag
      remove unused string writecache
      use memcpy for constant ondisk strings
      lvmlockd: fix snprintf warnings
      scan: remove comments about lvmetad
      add md component check in vg_read based on size
      pvscan: don't record PV online after error reading metadata
      tests: expand lvm-on-md
      pvs: remove unnecessary label scan
      pvscan: fix segfault in recent commit
      devs: rename dev_is_md dev_is_md_component
      move the setting of use_full_md_check flag
      hints: exclude md components
      scan: expand and update label scan comments
      tests: hints check if strace exists
      tests: pvscan-autoactivate.sh switch system_id_source
      tests: fsadm-crypt.sh update mkfs parameter
      tests: pvscan-cache try to fix teardown problems
      tests: fix error detection in lvconvert-raid-takeover.sh
      tests: change mkfs usage in lvconvert raid tests
      pvck: new dump option to extract metadata
      WHATS_NEW: pvck --dump
      separate code for setting devices from metadata parsing
      tests: pvscan-cache more attempts to fix
      tests: add debug to pvscan-cache deactivation
      pvck: dump headers and metadata
      pvck: dump metadata_all
      tests: pvck-dump
      pvck: use new dump routines for old output
      tests: pvscan-autoactivate check for machine-id

Heinz Mauelshagen (5):
      lvcreate/lvconvert: prohibit creation of/conversion to mirrored mirror logs
      WHATS_NEW
      raid: fix (de)activation of RaidLVs with visible SubLVs
      man: document 's' RAID attribute bit
      lvcreate/lvconvert: optionally reenable mirrored mirror log for testing purposes only

Marian Csontos (13):
      post-release
      build: Upse PYTHON_CONFIG env.variable when set
      udev: 69-dm-lvm-metad.rules is still needed
      dmeventd: Fix libdevmapper-event linking
      tests: Remove unsupported mirrored mirrorlog
      build: Remove reference to undefined @BUILD_LVMETAD@
      build: Remove badly placed `@`
      Revert "tests: Remove unsupported mirrored mirrorlog"
      lvmlockd: Fix arguments when built without sanlock
      cov: Close a FD on error
      test: Restore testing of D-Bus API
      test: Increase latency in pvmove-resume-multiseg
      pre-release

Ming-Hung Tsai (1):
      lvmanip:  uninitialized members in struct pv_list (#10)

Peter Rajnoha (4):
      scan: md metadata version 0.90 is at the end of disk
      scripts: lvm2-activation-generator fix lvmconfig call
      systemd: add missing Before=shutdown.target to LVM2 services to fix shutdown ordering
      systemd: put back DefaultDependencies=no for lvmpolld socket unit

Tony Asleson (13):
      lvmdbusd: Dump blackbox newest first
      lvmdbusd: Handle missing lv_attr table lookups
      lvmdbusd: Update table lookup for health lv_attr
      lvmdbusd: Update table lookup for state lv_attr
      lvmdbusd: Exit daemon when unable to retrieve state
      lvmdbusd: Handle exported VG(s)
      tests/dbus: Re-enable nesting and pvcreate via symlink
      lvmdbusd: Ensure all paths return value
      lvmdbusd: LookUpByLvmId: Add doc for cb, cbe
      lvmdbusd: Spelling correction
      lvmdbusd: Correct object manager lookups
      lvmdbusd: Handle duplicate VG names
      lvmdbusd:  Use UUID instead of name for VG rename

Zdenek Kabelac (206):
      label: add stack trace for failing dev_set_last_byte
      cov: remove uneeded code
      cov: split check for type assignment
      cov: explicit ignore if failures
      cov: overflow before widen
      cov: add missing check for dm_strncpy
      cov: trace failing pthread_kill
      cov: mark warning as expected one
      cov: hide intentionaly ptr arithmetic report
      cov: remove unused assigns
      cov: avoid unsing unchecked label_scan_open
      cleanup: move cast to det_t into MKDEV macro
      debug: tracing fclose failure
      debug: missing backtrace
      pvscan: add error checking for write of online files
      tests: add wait for udev
      tests: fix shell quoting
      activation: trimming string is expected
      devicemapper: retry remove even for subLVs
      configure: update
      tests: keep results configurable
      tests: updates
      tests: futher test tunning
      devicemapper: retry mirror leg deactivation
      tests: add wait loop
      libdm: do not add params for resume and remove
      libdm: add DM_DEVICE_ARM_POLL
      libdm: print params only for ioctls using them
      libdm: add memory barrier
      tests: secure data erase
      tests: extend
      tests: raise minsize of xfs
      tests: drop unwanted backup
      tests: makefile fixes
      tests: still more libs needs
      tests: correcting header file enclosure
      tests: prefer internal header
      tests: skip when gcore from gdb package is missing
      tests: skip portion of test for lvmpolld
      tests: create whole path with mkdir
      tests: skip part of test
      tests: update parm for new kernel
      tests: speed-up testing full of lvm2 metadata
      tests: generate slightly less volumes
      sanlock: update headers
      tests: missing copyright
      tests: update required raid target
      base: use calloc
      makefiles: improve lcov generator
      makefiles: updates for less verbosity
      makefiles: avoid dependency calcs for base dir
      makefiles: improving cleaning rules
      makefiles: add missing srcdir
      make: generate config update
      make: generate man update
      tests: add mising udev_wait
      tests: use select with dmsetup
      tests: requires at least 2 iterations
      tests: updates
      tests: reduce memory footprint
      tests: drop use_lvmetad from unit test
      configure: update
      makefiles: ignore missing files
      makefiles: clean unit-test
      tests: extend sleep
      rpm: install lvm2-pvscan again
      device_mapper: fix incorrect dm_strncpy usage
      device_mapper: optimize dm_pool_strndup
      libdm: optimize dm_pool_strndup
      device_mapper: move internal header to front
      makefiles: avoid clustering out
      makefiles: ensure test dir can run unit-test
      gcc: avoid shadowing index
      gcc: avoid shadowing activate_lv
      gcc: avoid shadowing use_aio
      gcc: ensure sector is initilized
      libdm: use libdm header
      headers: use configure.h as 1st. header
      headers: use full path header instead of -I directive
      makefiles: correct libdm dependency
      makefiles: drop unneeded include path
      makefiles: local headers first
      makefiles: some leftovers from lvmetad
      cleanup: some local headers first
      debug: drop extra tracing
      lvconvert: ensure proper init of pv_list
      dmfilemapd: avoid linking with DL_LIBS
      dmeventd: fix linking with libdevmapper
      dmeventd: do not link internal libraries to plugins
      lvm: drop usage of dl library
      cmirror: link with libdm
      makefiles: sort
      makefiles: drop unneeded LIBS add
      makefiles: quite install
      makefiles: missing cleaning
      makefiles: no longer used define
      makefiles: allow to set LIBS in Makefiles
      makefiles: dm-tools improve Makefile
      makefiles: correcting login of makefile
      makefile: fixes build for older system
      makefiles: also fix build of unit test
      dmeventd: resolve compilation of vdo status parsing
      lib: move towards v2 version of VDO format
      configure: avoid repeative inclusion of configure.h
      lvmpolld: improve makefile deps
      lvmlockd: fix error return code for _init_vg_sanlock
      lvmlockd: use commonly used define NOTIFYDBUS_SUPPORT
      lvmlockd: drop superfluous defines
      scripts: avoid voiding write result
      scripts: simplify including for generator
      stats: fix error path when region is NULL
      cleanup: missing copyright header
      lvconvert: use standard wiping code
      lvconvert: writecache fix return code
      dmeventd: unlock lvm2 lock on error path
      bcache: fix memory leak on error path
      debug: drop some extra backtraces
      debug: tracing close errors
      mangenerator: check strdup was successfull
      cov: ensure lock_type is not NULL
      cov: looks like cut&paste error
      cov: drop unneeded header file
      cov: extent_size cannot be 0
      Revert "lvmlockd: Fix arguments when built without sanlock"
      stats: initilize regions to NULL
      cov: fix memleak on error path
      cleanup: use zalloc
      debug: drop some unneeded backtraces
      tests: testing mirrorred mirror log
      tests: fix unit test
      tests: indent
      generators: avoid contacting syslog with generators
      config: drop extra spaces
      vdo: regenerate config
      mirror: regenerate config
      raid: man regenerated
      vdo: fix archived metadata comment
      vdo: update vdo profile
      man: missed --zero option for thin-pool creation
      man: initial man page for VDO support
      man: document dD attrs for VDO lvs
      dm: ensure migration_threshold is big enough
      dm: migration_threshold for old linked tools
      lv_manip: better work with PERCENT_VG modifier
      vdo: introduce function for estimation of virtual size
      vdo: estimate virtual size after resize
      vdo: discard reduced area
      vdo: size reduction requires VDO to be active
      vdo: allow resize of VDO and VDO pool volumes
      cleanup: better naming
      vdo: man documenting resize
      tests: update cache test
      tests: aux fix testing for kvdo
      tests: initial test for vdo resize
      vdo: add simple wrapper for getting pool percentage
      vdo: enable dmeventd resize
      tests: vdo dmeventd resize
      vdo: minor API cleanup
      lv_manip: better work with PERCENT_VG modifier with lvresize
      vdo: some formating updates
      rpm: package lvmvdo man page
      cache: select chunk size as power of 2
      thin: select chunk size as power of 2
      tests: rounding for pools changed to power of 2
      lvconvert: pass force and yes options for vdo conversion
      vdo: complete matching with thin syntax
      vdo: document types vdo and vdo-pool
      vdo: add some basic example
      man: vdo regenerated
      man: lvmvdo component activation description
      cleanup: indent
      gitignore: update
      dev_manager: add dev_manager_remove_dm_major_minor
      filter: enhance mpath detection
      debug: use log_warn
      thin: max thin
      cache: support vgsplit
      tests: check vgsplit works with cache
      lv_manip: insert remove layer skips pools
      vdo: enable caching for vdopool LV and vdo LV
      activation: synchronize before removing devices
      man: basic vdo stacking support
      man: dmeventd vdo plugin
      tests: vdo dmevent autoresize
      tests: vdo caching tests
      filter: fix mpath test
      thin: introduce estimate_thin_pool_metadata_size
      thin: resize metadata with data
      thin: fix maintenance of _pmspare
      tests: check auto-growth of thin-pool meta
      configure: check for pselect
      libdaemon: use pselect to avoid condition checking race
      cleanup: missed string specifier
      clean: avoid cleaning iterator on error path
      locking: validate locking mode
      build: fix compilation without lvmlockd
      cleanup: use unsigned type
      tests: update resize value
      tests: use luks1 for test
      tests: drop call of wipefs
      tests: split args
      metadata: allow reading metadata with invalid creation_time
      tests: check accepting out-of-range creation_time
      cache: support no_discard_passdown
      tests: automatically set scan_lvs when using extend_filter
      tests: check no_discard_passdown


