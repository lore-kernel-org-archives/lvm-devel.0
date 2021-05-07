From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  7 May 2021 15:40:49 +0000 (GMT)
Subject: v2_02_188 annotated tag has been created
Message-ID: <20210507154049.A0FF83857C71@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=03fff05bc037e5623989e23567e5f488d5c1ee25
Commit:        03fff05bc037e5623989e23567e5f488d5c1ee25
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2021-05-07 15:36 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2021-05-07 15:36 +0000

annotated tag: v2_02_188 has been created
	    at 03fff05bc037e5623989e23567e5f488d5c1ee25 (tag)
       tagging cde814abc04c6724a1561fc9935ac6b986054404 (commit)
      replaces v2_02_187

Release 2.02.188

Bug fix release.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJglV6wAAoJELkRJDHlCQOfKiUP/1y031XOMEwTUHEIaX1M6A1K
sRBQDdpkLI1UXXWnibkzUAqPksDe4D4KKDgDGSubkgR1hUNAcIMWqQACQ29SC4/Z
/B6dZ6GcJHqbk8UjrauY+a3mogR94zrmoHJ0rKxKidKLC1rEBJmAHMl4DWlsSHL4
HGmhE+kM0ve0TW9TwZGE1rolLli25lsvz/TaaFgSSptmrE7aIhStl6uiCN2V0oby
B089J8Nj0ErjvoulBcXur8UOc7ABPPhH5Lg+t10rSWOOm1tGp7jd0JkLhW95W8Qa
HZjd2YNlALAQJ4yT+NWn7ccXc1SYEQmY2F1feM7EeTnXjCOwmQqAHSmEBWAzo9sE
oH+F8BpDLtEDEFuEALGDW/lXiM28gLMS+Km4Y+H3slZzs2dLIm7ZwV3EJO3jI/xK
xcoUnaHBxOFO7yI6I4QNc03hbopvtTXOnp5SDo0glwiJSsQaCibKU9Z3no/M918w
WXhNAqueYX6vc9KGpuKDBEmaOQjliL0vjl2bfuGEHRB4I5rOJ54NwdVT767D4+FJ
h9y3FoJd/mhN59sjgbzE9Pr5xxbhsSdfev6hz+WMOb02q+rL4AeDBazYRJtoTUUt
oRyzCxI7P4y8emDgWAZRMU5snrFu/36KicXZsCBFvMyi/vFQFABVZ4/QUKoBTCHK
K+6soom8hvB4bbLpiTEr
=/tm2
-----END PGP SIGNATURE-----

Bastian Germann (1):
      lvm: add readline alternative editline

David Teigland (6):
      scanning: optimize by checking text offset and checksum
      vgrename: fix error value when name exists
      devices: detect md ddf and imsm superblocks
      devices: simplify md superblock checking code
      label: cleanup set_byte error exit
      vgextend: check missing device during block size check

Heinz Mauelshagen (7):
      lv{resize,extend,reduce}: reject size change on 2-legged raid5*
      lv{resize,extend,reduce}: also check for 2-legged raid4
      lvconvert: fix conversion to 'mirrored' mirror log with larger regionsize
      lvconvert: preset raid1 in case of striped conversions
      lvconvert: display warning if raid1 LV image count does not change
      Revert "lvconvert: display warning if raid1 LV image count does not change"
      lvdisplay: enhance LV status output for raid(0)

Marian Csontos (5):
      post-release
      build: make generate
      README: update
      tests: fix unbound variable
      pre-release

Peter Rajnoha (2):
      blkdeactivate: add support for VDO in blkdeactivate script
      blkdeactivate: add missing VDO_AVAILABLE check in deactivate_vdo

Wu Guanghao (2):
      lvconvert_poll: ensure LV has snapshot type
      pvmove: check return value of top_level_lv_name()

Zdenek Kabelac (180):
      libdm: fix dm_list pointer arithmentic for new gcc 10 optimization
      dmeventd: enhance time waiting loop
      container_of:  use offsetof from stddef
      lvconvert: no validation for thin-pools not used by lvm2
      test: repair of thin-pool used by foreign apps
      WHATS_NEWS: update
      cov: check strdup for NULL
      tests: add wait on udev processing
      bcache: support longer writes
      raid: no wiping when zeroing raid metadata device
      container_of: drop needless const converion
      lvmcache: use uint32_t for seqno caching
      lv_manip: get_default_region_size return uint32_t
      gcc: keep unsigned arithmetic
      gcc: avoid stack alloc arithmetic
      gcc: use apropriate type for reading and printing values
      gcc: do not use return with void function
      gcc: drop bogus ;
      tools: move struct element before variable lenght list
      config: drop reading file with mmap
      tests: check we detect lvm.conf read failure
      WHATS_NEW: update
      dmsetup: initilize winsize struct
      gcc: zero-sized array to fexlible array C99
      gcc: keep using unsigned type
      cov: explicitely ignore function result
      cleanup: matching declaration order
      cleanup: user force_t enums instead of ints
      cleanup: add spaces between literals
      cleanup: better expressing passing key arg to _hash
      lvconvert: flip return value of _raid_split_image_conversion
      lv_manip: add synchronization points
      man: correctly use configured directories
      lvextend: improve percentage estimation
      cleanup: comment typo
      thin: compensate metadata size by extra percent
      alloc: improve estimation of sufficient_pes_free
      tests: add aux delayzero_dev  support
      tests: use delayzero_dev
      tests: disable dbustest with valgrind testing
      tests: aux collects stack trace when stuck is assumed
      tests: have_cache function checks for cache-pool
      tests: check for boundary allocation sizes
      lvconvert: check if LV has cow type
      cov: drop model for origin_from_cow
      cov: drop checking for EWOULDBLOCK
      cache: simplier signal handling
      tests: check in_sync prints also dm status
      tests: improve cache abort test
      tests: switch for checking version of installed tools
      lvcreate: add extra synchronization at error path
      tests: smaller delay and lowered version
      tests: aux better handle invalid table
      tests: utils better handle ouf of disk space
      tests: inittest supports SKIP_WITH_LOW_SPACE
      tests: use zero backend
      tests: use DIRECT io for zeroing whenver we can
      activation: use revert_lv on tree suspend failure
      thin: no delete message for device_id 0
      thin: enhance lvcreate error paths
      thin: improve error message
      thin: pass through whole code
      makefiles: document supported var in make help
      activation: move locking of critical section
      cleanup: avoid unneeded check
      thin: remove unneeded code test
      thin: use lv_status_thin and lv_status_thin_pool
      active: fix compilation without devmapper
      configure: update help
      configure: update with latest AM_PATH_PYTHON
      configure: use our ordered list of python names
      bcache: fix waiting problem for completed IO
      bcache: fix busy loop with too many errors
      bcache: support interrupts when waiting on IO
      bcache: use flexible arrays
      debug: remove stacktrace on regular path
      debug: show actually reason for taking this code path
      debug: no backtrace
      tests: move function to aux for reuse
      tests: use aux wrapper and add more notes
      tests: a bit bigger mirrors
      tests: also add thick snap of thin volume
      tests: check some common errors
      tests: add small delay
      tests: rename shown debug trace
      tests: aux hides zero and error device
      tests: aux setup
      tests: missed char in list
      rpm: bare words are no longer supported
      dm: remove created devices on error path
      WHATS_NEWS: update
      wipe: convert zero_value to uint8_t
      libdm: split code for sending message
      libdm: enhance error message
      libdm: validate thin-pool before sending messages
      label: use open_rw
      label: code deduplication
      label: deduplicate dev_set_bytes
      gcc: calc size in compile time
      wipe_lv: make error a fatal event
      pool: zero metadata
      wipe_lv: always zero at least 4K
      lvconvert: more support for yes conversion
      tests: failure of zeroing fails command
      tests: check pool metadata are zeroed
      configure: editline updates
      configure: fix python paths
      wipe: dev_set_bytes resolves zeroing
      wipe_lv: interruptible wiping
      configure: check for BLKZEROOUT support
      wipe_lv: use BLKZEROOUT when possible
      debug: update messages
      tests: extend area covered by error target
      lv_manip: add space into message
      man: more precise UNIT
      man: regenerate
      debug: shorten error message
      lvmcmdlib:  lvm2_init_threaded
      memlock: allocate at most halve of rlimit stack
      tests: check dmevent with bigger reserved_stack
      WHATS_NEW: update
      tests: changes from master
      filters: persistent filter hides rename failure
      fsadm: use NULL
      fsadm: handle fsck return 1 for corrected fs
      fsadm: enhance error handling
      tests: fsadm test continue after fs repair
      WHATS_NEW: update
      cov: dmeventd plugin fix memleak
      make: remove file from master
      fsadm: better check for getsize64 support
      tests: minor update
      fsadm: fix bash artihmetic
      gcc: cleanup warns from older gcc
      fsadm: fix unbound variable usage
      tests: few more fsadm checks
      alloc: enhance estimation of sufficient_pes_free
      tests: check thin-pool corner case allocs
      tests: check full zeroing of thin-pool metadata
      man: update lvmthin
      libdm: add dm_tree_node_add_thin_pool_target_v1
      thin: improve 16g support for thin pool metadata
      pool: limit pmspare to 16GiB
      cache: reuse code for metadata min_max
      pvmove: automatically resolve whole stacked LV
      allocation: report allocation error instead of crash
      WHATS_NEW: updates
      tests: check 16G thin pool metadata size
      tests: update thin and cache checked messages
      aux: update thin_restore_needs_more_volumes
      thinpool: use lv_config_profil for crop_metadata
      thin: check for overprovisioning only once
      lv_resize: use 'bad' code path for error case
      lv_manip: reuse function also during reduction
      lv_resize: support resizing of cached volumes
      tests: support for resized cached LVs
      targets: use target_present_version
      lvconvert: thin errorwhenfull and recalculation
      tests: lvconvert thin profile conversion
      lvdisplay: fix show of merged thin snapshot
      tests: lvdisplay does not crash for merged thin
      lv_manip: avoid removing LV when converting
      lvchange: remove unneeded call
      tests: readonly snapshot thick origin can't be merged
      libdm: simplify line emitter checking
      tests: check for raid target support
      tests: avoid killing test machines with kernel bug
      lvconvert: read-only origin cannot be merged
      lvchange: snapshot thick origin permission rw/r
      snapshot: create origin of virtual snap read only
      makefiles: ignore missing files
      make: generate
      WHATS_NEW: updates
      fsadm: avoid access to unbound variable
      tests: remove local setting of LVM_BINARY
      WHATS_NEW: update
      tests: update setting LVM_BINARY for testing
      lvconvert: improve support for metadata profiles
      tests: make test complaint to local dev dir
      cmdline: add missing comma in definition

Zhao Heming (3):
      gcc: change zero-sized array to fexlible array
      dev-cache: dev->bcache_fd default from 0 to -1
      gitignore: ignore all cscope generated files


