From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 23 Oct 2019 04:03:44 -0400
Subject: v2_03_06 annotated tag has been created
Message-ID: <201910230803.x9N83icg012357@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b481062dfdf117db5cbaf000230aa79ab556b45
Commit:        3b481062dfdf117db5cbaf000230aa79ab556b45
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2019-10-23 07:52 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2019-10-23 07:52 +0000

annotated tag: v2_03_06 has been created
	    at 3b481062dfdf117db5cbaf000230aa79ab556b45 (tag)
       tagging b9391b1b9f0b73303fa21f8f92574d17ce4c2b02 (commit)
      replaces v2_03_05

Release 2.03.06

NOTABLE CHANGES:

Prevent creating VGs with PVs with different logical block sizes.
Setting 'devices/allow_mixed_block_sizes' to 1 keeps the old behavior but may
lead to data corruption.

Improvements to cache volumes handling.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJdsAf0AAoJELkRJDHlCQOf5HMP/jvPhs1Wd08ozCQrfOPkStn+
DPXuSC6ZjcHC/EWPZkGMNR0BL5gtnDHAZGUYnRXkE73+3bnH03bB8GokK4rIdARO
UQhN4s9qF3WyFoG5lgzcY39ypktwnrVX+WUM3eFKzlxWOCw8pSFjZtrroe7AXvbE
IvIBGvGb/F4uwIWs5f4aA2TsaT/V9dWbOK2tJei3/dPgoMKyQi7oCEDs7ynxlnEg
o4Ee7ogwfz2620fFLBm9DbdqAJxdHl/Ha0JUdRuDHrD3yRrltFqdwemTkTIW1fJb
l+RxbmI9ApEK1KUmwfu53/zSuTAZ1btoi9WlnTF/KdBjST0WlZlNyTed7nb/KM/2
S+IjLviAOvecx7Kal0kf9V5Avz69bx9AYtuUd701Ax7qOFEichDhRLXodxwyi/hq
8muGAQBRxhgfRRFXYSxCDLLI3oXSYIIX/VgKDD6M0mHrXWen6gWl4BE/a/bkbqXa
S4/n5lAVaArYS8oMvwLIq2MDWfr7pPSxkMLefYgwfjYMxQTE7FlajQVsLFcgez5I
3xN+SXKxetP6NoH3MA1LHOH+4y3RiE9GclYsFyqTZOIADdaUvITnHOAVCVNhnO6U
S2LoAo2E7X+mi/zeYAt0D2kE7qnEBp1bGuNpIqEREfoAaITaFmKHvZHLG8H4/q+k
7LuPOqdpcxDBsVEA1pbG
=3AeE
-----END PGP SIGNATURE-----

Bryn M. Reeves (1):
      dmsetup: do not treat no groups as an error in dmstats list --group

David Teigland (112):
      config: remove filter typo
      vgchange: don't fail monitor command if vg is exported
      metadata: include description with command in metadata areas
      scanning: open devs rw when rescanning for write
      exported vg handling
      tests: add exported.sh
      cache: warn and prompt for writeback with cachevol
      scan: remove unused arg to setup_bcache
      md component detection for differing PV and device sizes
      pvscan: fix PV online when device has a different size
      enable full md component detection at the right time
      tests: extend lvm-on-md
      tests: pvscan-autoactivate test unmatching dev and PV size
      pvck: fix looping dump metadata_all
      metadata: extend writes to zero space
      tests: metadata-zero-space
      tests: lvm-on-md use variable run dir
      Fix rounding writes up to sector size
      tests: large-physical-sector-size
      WHATS_NEW: fix large physical block size
      vgcreate/vgextend: restrict PVs with mixed block sizes
      tests: allow-mixed-block-sizes
      WHATS_NEW: vgcreate/vgextend logical block size
      config: set deprecated version for segment_libraries
      config: cache_policy should be cfg_runtime
      Revert "config: cache_policy should be cfg_runtime"
      devices: clean up block size functions
      devices: put ifdef around BLKPBSZGET
      increase soft open file limit
      tests: open-file-limit
      md component detection addition in vg_read
      lvmcache: renaming functions and variables
      lvmcache: replace found_duplicates variable
      lvmcache: use devl list helper
      improve duplicate pv handling for md components
      pvscan cache: use lvmcache_label_scan
      tests: duplicate-pvs-md
      bcache: increase max allowed bcache size
      pvscan: disable sleeping and retrying for udev
      man lvmthin: remove nonexistent topic
      fix duplicate pv size check
      hints: fix copy of filter
      hints: check for malloc failure
      fix segfault for invalid characters in vg name
      vgextend: check missing device during block size check
      pvscan: avoid full scan for activation
      bcache: change log level for prefetch message
      tests: metadata-bad-text.sh with lvmlockd
      pvscan: allow use of noudevsync option
      tests: cache-single tests require version 1 10
      tests: allow-mixed-block-sizes skip with older losetup
      tests: open-file-limit skip without prlimit
      tests: skip without xxd
      tests: metadata-zero-space add info for debugging
      tests: use standard md devices
      tests: more debug in metadata-zero-space
      tests: skip some without wipefs
      tests: unnecessary braces causes test failures
      tests: metadata-zero-space more debugging
      tests: don't change real test output
      tests: drop unnecessary pid from LVMTEST prefix
      Revert "lvmlockd: use commonly used define NOTIFYDBUS_SUPPORT"
      Revert "tests: drop unnecessary pid from LVMTEST prefix"
      lvconvert: cachevol LV can have multiple segments
      cachevol: add dm uuid suffixes to hidden lvs
      lvchange: allow activating cachevol
      lvconvert: detaching cachevol with missing PVs
      tests: add cache-single-split
      writecache: use dm suffixes and lv attributes
      writecache: display layout and role fields
      tests: update cache-single-split
      drop cvol dm uuid suffix for cachevol LVs
      tests: update cache-single-split
      lvconvert: allow --cache shortcut for --type cache with cachevol
      tests: add writecache-split
      lvconvert: separate splitcache and uncache functions
      lvconvert: enable --uncache with dm-cache cachevol
      tests: update cache-single-split
      lvremove: remove attached cachevol with removed LV
      writecache: move code into new file
      writecache: allow removing LV with attached writecache
      lvconvert: enable --uncache with dm-writecache cachevol
      tests: writecache-split check have_writecache
      tests: skip md tests if system not clean
      tests: mdadm stop in test cleanup
      metadata: add args to metadata import functions
      metadata: import device name hint from metadata
      pvscan: use quick activation only with matching PV device names
      scan: add PV summary info to lvmcache
      scan: use PV size for choosing duplicate PV
      scan: use PV device name hint for choosing duplicate PV
      tests: update duplicate md tests
      pvck: handle PVs with zero metadata copies
      tests: update to md dev name
      tests: add wipefs wrapper
      lvmlockd: set failure flag for test mode
      tests: improve lib wipefs_a
      vgremove: remove internal lvmlock LV
      man: lvmcache note dm-cache block size issue
      pvmove: remove some cmirror related code
      vgck: fix updatemetadata writing different descriptions
      vgck: let updatemetadata repair mismatched metadata
      cache: change cachevol flags for backward compat
      allow activating known LVs when other LVs have unknown segtypes
      cache: change default cachevol metadata sizes
      writecache: add cvol suffix to attached cachevol
      tests: metadata-zero-space long vgnames
      pvck: dump metadata search
      man: lvmcache naming updates
      cachevol: use cachepool code for metadata size
      vgchange: remove bogus option restriction
      improve command definition matching using type

Heinz Mauelshagen (8):
      lvconvert: allow --stripes/--stripesize in 'mirror' conversions
      dmeventd: avoid bail out preventing repair in raid plugin
      lvchange: add --resync help/manual text relative to 'R' attribute
      Revert "dmeventd: avoid bail out preventing repair in raid plugin"
      dmeventd: avoid bail out preventing repair in raid plugin but keep message
      test: add checks for not 100% sync ratio after initiation of check/repair
      test: add RAID lvextend resynchronization test
      test: increase size of raid10 LV allowing tests to succeed on fast storage

Marian Csontos (16):
      post-release
      config: Fix default option which makes no sense
      test: Fix unbound variable
      test: Remove now useless clvmd test
      tests: Fix unbound variable
      configure: Fix the default in help string
      configure: Fix setting of CLDFLAGS default
      spec: Move blkdeactivate to device-mapper
      build: make generate
      spec: enable writecache
      spec: Fix lvm2-activation-generator man page handling
      test: Minimize data written by metadata-zero-space
      dm: fix compilation of dmsetup
      build: make generate
      cov: Fix memory leak
      pre-release

Mikulas Patocka (1):
      dm: introduce DM_GET_TARGET_VERSION

Peter Rajnoha (2):
      udev: do not overwrite ID_MODEL in 69-dm-lvm-metad.rules
      udev: remove unsupported OPTIONS+="event_timeout" rule

Vojtech Trefny (1):
      Fix converting dbus.UInt types to string

Zdenek Kabelac (85):
      make: support comments in exported symbols
      exported_symbols: comment old symbols
      libdm: implement search for device names for older kernels
      cov: ensure cname exists before derefering it
      cov: check for socket_path being set
      make: generate
      tests: replaces grep -q usage
      tests: fix ra checking
      tests: add settle wait before issue remove
      tests: accept also value 512
      tests: for cluster testing we always need exclusive mirrors
      tests: simplify some var settings
      pvmove: correcting read_ahead setting
      pvmove: add missing synchronization
      activation: add synchronization point
      dmsetup: debug print
      activation: extend handling of pending_delete
      snapshot: always activate
      cache: improve vgremove loop
      lv_manip: add synchronizations
      dmsetup: missed trailing newline
      configure: check for prlimit
      configure: continue build if prlimit is missing
      activation: use cmd pending mem for pending_delete
      lvconvert: improve validation thin and cache pool conversion
      tests: pool conversion
      devices: crypto skip
      thin: activate layer pool aas read-only LV
      vdo: enhance activation with layer -vpool
      tests: check vdo
      vdo: deactivate forgotten vdo pool
      vdo: properly check percentage for resize
      vdo: restore monitoring of vdo pool
      cmirrord: deamon links libdm
      cache: report for succesful status
      resize: continue change for getting vdo status before resize
      display: try to show status for inactive vdopool
      vdo: raise VDO default bio threads to 4
      vdo: keep minimum_io_size in sectors
      vdo: correct internal API for set_vdo_write_policy
      vdo: introduce get_vdo_write_policy_name
      vdo: field update
      vdo: remember configure VDO write policy in metadata
      vdo: add lvs fields to query vdo volume properties
      WHATS_NEW: update
      lvconvert: fix return value when zeroing fails
      tests: disable caching of VDO
      lvconvert: use struct initializer
      cache: reload only when switched to cleaner policy
      cache: recognize cachevol with lv_cache_remove
      cache: correct condition
      cache: enhance removal function to work with cvol
      cachevol: wipe 'normal' device
      cachevol: rename converted LV to _cvol
      cachevol: drop LV_CACHE_VOL on detach automatically
      cachevol: use writethrough for partial removal
      cachevol: put _cvol as protected suffix.
      cachevol: improve manipulation with dm tree
      cachevol: use lv_cache_remove
      cachevol: drop no longer needed functions
      tests: drop manipulation with 'internal' LV
      tests: cvol
      cachevol: use CVOL UUID for cdata and cmeta layered devices
      cache: add more comments for min meta size
      cache: drop validation check
      cachevol: move flag setting after taking archive
      cachevol: move cvol rename
      debug: missing trace
      cache: single code for removal of cached volume
      cachevol: support removal of cachevol
      tests: skip when raid is not present
      tests: cachevol needs FORMAT2
      lv_manip: add lv_uniq_rename_update
      lvm-string: add drop_lvname_suffix
      lvconvert: use new functions
      cache: drop _cpool suffix from unused cache-pool
      cache: use _cpool for used cache-pools
      tests: used cache_pool adds _cpool
      gcc: older compiler is happier with this initilizer
      gcc: all paths will set ret
      gcc: avoid warning: declaration of xxx shadows a global declaration
      gcc: older version can't see udev is always set
      tests: more suffixes
      tests: enable with 6.2.1
      cache: _cpool is protected suffix now


