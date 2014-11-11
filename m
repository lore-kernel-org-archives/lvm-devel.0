From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 11 Nov 2014 14:19:54 +0000 (UTC)
Subject: v2_02_112 annotated tag has been created
Message-ID: <20141111141954.C81346108D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c5a607ff60b2b2ef3872903af13ae9b83e3b207
Commit:        6c5a607ff60b2b2ef3872903af13ae9b83e3b207
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2014-11-11 14:14 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2014-11-11 14:14 +0000

annotated tag: v2_02_112 has been created
	    at 6c5a607ff60b2b2ef3872903af13ae9b83e3b207 (tag)
       tagging 9a5910bdf9a8d79051181f110a43a7c1ef2288d6 (commit)
      replaces v2_02_111

Release 2.02.112.

187 files changed, 11247 insertions(+), 6391 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlRiGbkACgkQIoGRwVZ+LBdSMACfQr584pGhii8/lVKOvfA/4ijZ
vWUAoIC5T+vhUUIA0TWy71FA7i7AhugW
=Ezax
-----END PGP SIGNATURE-----

Alasdair G Kergon (20):
      post-release
      cleanup: Use lv_is_ macros.
      cleanup: fix last commit
      mirrors: Fix checks for mirror/raid/pvmove LVs.
      devices: Detect rotational devices.
      cleanup: Remove metadata.h from tools dir.
      lvconvert: Restrict use of cache LVs.
      lvconvert: Disallow mixing of cache and thin pools.
      lvconvert: Further restrictions on cache/pools.
      cache: Enable cache segment type by default.
      toollib: Remove unused functions from header file.
      toollib: Shuffle PV functions.
      lvmcache: Skip VG_GLOBAL cache lock state update.
      vgremove: Use process_each_lv_in_vg.
      device: Fix BLKSSZGET definition check.
      vgcreate: Permit non-power-of-2 extent sizes.
      dmeventd: Remove redundant checks.
      dmeventd: Include shutdown threads in responses.
      dmeventd: Add basic thread debugging messages.
      pre-release

David Teigland (22):
      man: lvmcache should use clearer cache pool options
      man: lvmthin should use clearer thin pool options
      Revert "Revert "man: lvmthin should use clearer thin pool options""
      man: lvmthin remove unnecessary fixme
      Revert "Revert "man: lvmcache should use clearer cache pool options""
      man: lvmthin mention alternate syntax
      tools: Add ALL_VGS_IS_DEFAULT flag.
      tools: Add ENABLE_ALL_DEVS flag.
      cache: include cache mode in vg metadata and display
      man: lvmcache better cache mode info and other command variations
      toollib: Rewrite process_each_vg.
      toollib: Rewrite process_each_lv.
      man: lvmthin show the lvcreate -n option for pools
      man: lvmcache changes related to removal and splitting
      man: lvmcache mention automatic pool conversion
      toollib: Rewrite process_each_pv.
      vgreduce: Use process_each_pv.
      metadata: Use flags to control warnings.
      test: Add process-each toollib tests.
      toollib: remove dead code
      toollib: remove unsed variable in process_each_segment_in_pv
      vg_read: Remove unused READ_WITHOUT_LOCK.

Heinz Mauelshagen (1):
      cleanup: Use segtype.h definitions of segment type names wherever possible

Jonathan Brassow (2):
      clean-up:  better macro usage
      cache-pool:  Fix specification of cachemode when converting to cache-pool

Liuhua Wang (1):
      cmirror: fix endian issues on s390

Peter Rajnoha (30):
      so: make sure shared libs are built with RELRO option
      filters: fix incorrect filter indexing in composite filter array
      conf: add allocation/physical_extent_size config option for default PE size of VGs.
      libdm: use dm-mod autoloading during dm_is_dm_major call if needed
      revert: commit 3880ca5ecad1761bd13a190c58f8f85fdd7cd0e1
      libdm: fix dm_is_dm_major to not issue error about missing /proc lines for dm module.
      libdm: finish the comment
      refactor: make it possible to select what to check exactly when calling device_is_usable fn
      filters: add "usable device" filter
      filters: use usable device filter and separate lvmetad filter chain so it's not reevaluated for any lvmetad response
      filters: refresh filters when lvmetad use is toggled
      cleanup: remove symlink to profile in test dir for CLEAN target
      filters: add cmd->full_filter - composite of cmd->filter and cmd->lvmetad_filter
      cleanup: remove compiler warning about possible uninitialized variable use
      metadata: add internal error if PV has no existing device attached during find_pv_in_vg
      filter-usable: filter out blocked and suspended devices firmly when scanning for lvmetad
      systemd: remove workaround for lvm2-monitor.service's ExecStop line
      liblvm2cmd: recognize quotes properly when splitting cmd line string into argv array fields
      report: lv_permissions: display read-only/read-only-override instead of blank when LV is not writeable
      report: fix selection on {vg,lv}_permissions fields to properly match selection criteria
      report: selection: fix selection criteria to not match reserved values when using >, <, >=, <
      test: for issue fixed in previous commit 2f7f6932dcd450ba75fe590aba8c09838d2618dc
      report: cleanup: simplify LVSINFO detection
      cleanup: keep 'fall through' switch case for LVSINFO for compiler to understand this properly
      refactor: rename struct lv_with_info used in reporting code to lv_with_info_and_seg_status
      report: add new LVSSTATUS and SEGSSTATUS report type
      dev_manager: enhance dev_manager_info to acquire LV segment status if requested, add lv_info_with_seg_status fn
      report: add cache device status fields
      WHATS_NEW: '_' -> ','
      dev_manager: only support status for cache segment at the moment

Petr Rockai (15):
      dev-cache: Filter wipe does not guarantee a full /dev scan.
      lvmetad: Re-organise filters to properly avoid scans of component devices.
      test: Add a test for MD component detection in pvscan --cache.
      lvmetad: Differentiate between filtered and truly missing devices.
      WHATS_NEW for filter-related changes
      conf: Update comments on lvmetad+filters in example.conf.in.
      lvconvert: Forward --splitmirror to a cache origin when applicable.
      test: Show an activation bug in lvcreate of a cache over raid.
      lvconvert: Allow --repair and --splitmirrors on reserved-name LVs.
      test: Creating a cache on top of active RAID works now.
      metadata: Fix find_pv_in_vg for missing PVs/filtered devices.
      test: Fix lvconvert-raid-allocation's use of lvconvert --repair.
      lvchange: Allow appropriate actions on cache (in addition to thin) pools.
      NIX: Give the VMs 2G of RAM (for tmpfs) until the new runner is merged.
      NIX: Fix 32b builds (2G of RAM is 1M too much for 32b QEMU).

Zdenek Kabelac (288):
      cleanup: add stacktrace for error path
      lv_rename: fix snapshot rename
      lv_manip: remove vg_revert
      lvconvert: use lv_update_and_reload
      lv_update_and_reload: replace code sequence
      lv_rename: actual fix for snapshot
      tests: test for rename of snapshot
      debug: turn message into debug
      tests: test for rename of snapshot
      allocation: use vg memory pool
      raid: add missing backups
      raid: add missing vg_revert
      raid: add missing archive call
      raid: check result of get_segtype_from_string
      raid: add function for name creation
      raid: use _generate_raid_name
      debug: add missing stack trace on error path
      cleanup: plain code reindent
      cleanup: update _alloc_image_component function
      raid: destroy allocation handle on error path
      cleanup: better error messages
      cleanup: missing error message
      cleanup: simplify _extract_image_components
      cleanup: avoid strlen() we know max size
      cleanup: skip unused assign
      thin: check for active lv
      test: test there is no leak of LV on error path
      tests: update lv_no_exists
      va_list: properly pass va_list through functions
      vgchange: disable cluster convert for active LVs
      locking: add locking_supports_remote_queries
      vgchange: support clustered conversion for active lv
      cleanup: detect unsupported options earlier
      debug: catch mmap with -DDEBUG_MEMLOCK
      cleanup: update message
      debug: enhance trap of mmap
      makefiles: fix linking of PIE code
      WHATS_NEW
      debug: mmap traps mmap and mmap64 on i386
      memlock: ensure memory is allocation before locking
      memlock: drop uneeded lock
      wipe_lv: move sync_local_dev_names in front
      cleanup: switch to use CHANGE_AEY
      cleanup: use const for cmd context
      metadata: validate major, minor numbers
      tools: common handling of --persistent option
      lvchange: backup final metadata
      cleanup: lvchange remove some extra code.
      backup: drops locked memory
      man: document obsoleted options
      debug: enhance mmap catch code
      cache: fix regression and invert test
      cleanup: use int32 for major minor
      fix: regression for recent persistent commit
      activate: lv_check_not_in_use no check of closed
      lv_ondisk: option search for lv without vg_ondisk
      lv_update_and_reload: use proper lock holder
      mirror: extend adjusted_mirror_region_size API
      snapshot: add missing vg_revert
      snapshot: use lv_update_and_reload
      thin: no pool can be used for external origins
      thin and cache: improve conversion validation
      vgchange: add sync point
      vgchange: use NULL 'feature' of lv_info call
      validation: move check for spare correctness
      cleanup: move printing after backup
      cleanup: constify activation usage of lv pointer
      lvconvert: reoder old snapshot merge
      activate: update lv_check_not_in_use: API
      cleanup: use find_lv_in_vg_by_lvid
      cleanup: simplier _lv_passes_volumes_filter
      cleanup: replace error with print message
      cleanup: fix typo and use vg mempool
      cleanup: use supplied cmd pointer
      cleanup: drop uneeded backup call
      cleanup: drop duplicate const usage
      cleanup: reindent
      debug: monitor_dev_for_events stack trace
      debug: add missing stack trace
      debug: drop printing debug trace without labeler
      debug: show stacktrace on error path
      debug: add debug message
      tests: drop * from dmsetup
      tests: add helper funcionality for using gdb
      lvchange: missed bits for a8aee7dba2b76
      Revert "man: lvmthin should use clearer thin pool options"
      Revert "man: lvmcache should use clearer cache pool options"
      toollib: refactor skip_dev_dir
      toollib: refactor extract_vgname
      cleanup: rename func
      toollib: introduce validate_lvname_param
      lvconvert: switch to validate_lvname_param
      cleanup: drop unused variable
      valgrind: don't eat mem with valgrind
      lvcreate: refactor code
      thin: lvcreate improve check of thin params
      thin: better thin snapshot error detection
      commands: support shortcut -H for cache objects
      lvcreate: support --cache and --cachepool
      toollib: validate also name
      lvconvert: options splitcache, split, uncache
      cache: add validate_lv_cache_create
      lvconvert: reuse cache validation
      lv_manip: fix out of order backup
      lvcreate: reuse validation of names
      pools: move removal of _pmspare
      cache: lvremoved cached LV removes cache pool
      cache: check activation of volume activated
      lvremove: detect cluster wide active state
      cache: improve creation code
      cache: use same alg for cache size calc
      lvconvert: validate cache conversion to snapshot
      lvconvert: cache and thin conversion validation
      lvconvert more test for thin external origin
      lvconvert: splitsnapshot supports --yes
      man: lvconvert new split options
      vg/lvremove: support --yes
      man: document -ff for removal
      pool: validate_pool_chunk_size
      pool: use validation
      toolib: early validation of chunk size
      lvcreate: validate sizes
      validation: share more code for pool validation
      validation: use validate_pool_chunk_size
      cleanup: lvconvert use standard function exit
      cleanup: error is already logged
      cleanup: typo update
      cleanup: indent
      tests: lvcreate cache interface updates
      tests: lvcreate thin-pool support --name
      tests: lvcreate external origin
      tests: lvconvert cache
      tests: lvconvert thin pool
      tests: lvconvert cache usage of thin pool
      cleanup: dont hide pv_dev declaration from pv
      tests: move cache raid to separate file
      tests: check for cache and raid
      tests: put devs into ""
      tests: typos
      cleanup: rename _name, _lv and _size
      lvcreate: regression fix on lv name limits
      toollib: validate_restricted_lvname_param
      file-locking: skip locking of VG_SYNC_NAMES
      segments: introduce lvseg_name
      cleanup: drop default implementation
      cache: validate for locked
      cache: better error message
      raid: query lock holder
      pool: fix testmode support with pools
      pool: better error message
      libdm: add DM_LIST_HEAD_INIT macro
      tools: refactor reporter code
      tools: read yes_no_arg via int_value
      segtypes: macro segtype_is_unknown
      lvcreate: better logging for temporary device
      lvcreate: move tests that requires activation
      lvconvert: external detects more conflicts
      segments: disable init of free segment
      toollib: new arg list functions
      lv_manip: improve should_wipe reporting
      lv_manip: preserve read-only status in layered volume
      cleanup: commands.h shorted string
      cleanup: commands.h update descriptions
      cleanup: indent
      cleanup: move code
      cleanup: sort args alphabetically
      cleanup: simplier lv name construction
      cleanup: move code for checking vg features
      cleanup: don't backup twice
      cleanup: use arg_is_set
      cleanup: lv_manip drops duplicated internal error
      cleanup: use matching flags for permissions
      options: introduce pooldatasize option
      cleanup: better stack tracing
      cleanup: function embeded
      cleanup: code move
      pool: better error path handling
      lvcreate: handle linear segment
      pools: error path removes metadata
      lvcreate: new validation code
      toollib: persistent major minor
      lvcreate: check for conflicting -Zy -Wy
      segments: mark more of them unzeroable
      cache: separate func for pool/origin validation
      man: lvconvert/create updates
      mirror: extra parsing for mirrorlog arg
      tests: lvcreate usage
      tests: new lvcreate functionality
      tests: syncaction needs kernel fix
      lvm2app: update to new lv_create_single API
      pools: prefetch pool_lv and origin_lv
      cache: apply chunk rounding also for cache creation.
      thin: simplify thin volume creation
      cache: support more args
      lvcreate: delay check for free extents
      tests: pytest update
      tests: lvcreate-update
      tests: update cache creation tests
      pools: workaround hints
      configure: option cleanup
      sparse: configurable type for sparse volumes
      configure: autoreconf
      man: update lvcreate with sparse
      lvcreate: improving recent lvcreate updates
      segtype: drop cmdcontex pointer
      lvmcmdline: extra support for decimal point
      lvmcmdline: support size_mb_arg_with_percent
      pv_manip: check for pe_ranges
      metadata: add extents_from_percent_size
      cleanup: remove unneeded assign
      cleanup: prints and stacks
      cleanup: extents_from_size is 32bit value
      cleanup: shorter code
      tests: raid syncaction test
      tests: use aux func to disable device
      tests: lvcreate snapshot usage update
      tests: explicitely use old snapshots
      tests: wait for raid sync
      tests: update raid sync
      libdm: init char array
      lvcreate: tollerate defaults
      filters: change return code
      pool: validate sizes
      thin: reporting of thin volumes simplified
      thin: allow to convert chunksize of empty pool
      cache: convert thin-pool
      cache: allow deactivation of empty pool
      cache: add wipe_cache_pool
      cleanup: use extents to pass size to /lib
      cleanup: rename virtual_extents
      cleanup: add arg to _setup_task
      cache: lv_cache_status
      cache: support activation of empty cache-pool
      cache: wipe cache-pool before reuse
      cache: report stats for cache volumes usage
      cleanup: use arg_is_set
      cleanup: correcting tracing
      cleanup: init of lcp
      cleanup: standard params ordering
      cleanup: rename function
      cleanup: shorter code
      cleanup: consistent name
      cleanup: use logical_volume* directly
      cleanup: use lv_is_pool
      tests: usage of -m0 -Mn
      tests: thin
      lvconvert: convert missing sizes to extents
      libdm: allow to activate any pool with tid == 0
      thin: add lv_is_new_thin_pool
      thin: no validation skip of new thin pools
      thin: validate unused thin pool
      thin: check for new pool before creating thin volume
      thin: new pool is activated without overlay
      tests: duplicate update of config
      snapshot: no snapshot of any cache type LVs
      lv: lv_active_change add needs_exclusive flag
      activate: check all snap segs are inactive
      cleanup: avoid dm_list size calc in common path
      pools: after fail of vg_write no restore
      pools: prompt only when metadata lv exists
      cache: used cache-pool becomes invisible
      raid: fix activation order
      dmeventd: time scaling for status retry
      segtype: add SEG_ONLY_EXCLUSIVE flag
      lvremove: few more validation before archive
      lv_manip: remove_layer_from_lv restore lv name
      snapshot: virtual save commit
      report: for cache LV report chunksize
      cleanup: API get/set fixes
      cleanup: cache API get/set
      libdm: tunning cache API
      cache: new API for libdm
      man: _corig is reserved
      cache: option
      cache: _corig has UUID suffix
      cache: use LV_PENDING_DELETE
      cleanup: use chunk_size directly
      cleanup: indents comments backtraces
      cleanup: gcc warnings
      debug: log tree type is created
      tests: cache snapshot
      tests: reach cache params
      mirror: layer remove doesn't work properly with mirrors
      dev_manager: workaround to allow top-level _tmeta, _tdata
      libdm: still better API
      cache: no status for pending deleted cache
      cache: never create new table entry for deleted cache
      cache: pending_delete fixes


