From: Marian Csontos <mcsontos@sourceware.org>
Date: Sun,  9 Aug 2020 15:21:28 +0000 (GMT)
Subject: v2_03_10 annotated tag has been created
Message-ID: <20200809152128.215353857C4A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=468e7b688eaf36fea7fef7368637038eb932e833
Commit:        468e7b688eaf36fea7fef7368637038eb932e833
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2020-08-09 15:18 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2020-08-09 15:18 +0000

annotated tag: v2_03_10 has been created
	    at 468e7b688eaf36fea7fef7368637038eb932e833 (tag)
       tagging 4d9f0606beb0acb329794909560433c08b50875d (commit)
      replaces v2_03_09

Release 2.03.10

- Add integrity with raid capability.
- Add writecache and integrity support to lvmdbusd.
- Zero pool metadata on allocation (disable with allocation/zero_metadata=0).
- Failure in zeroing or wiping will fail command (bypass with -Zn, -Wn).
- Bug fixes.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJfMBPHAAoJELkRJDHlCQOf7bcP/igJb47fdwn31R4XNnshLAPr
fA34LKQGvhCSqSB2PM6a2aDwCMqw5WOi5cxVPIdvBpJDd93VGWJcNUxtzsOSkG2Q
x+8HNUTchJpcg9OKxfAi0ViqCe+lCioq9CXCx5V/1cWav8tl2NzcU2+8j2KQ/Z5P
68E6Kg2zZ6P925pQPER2aArx+fkk866JxgjHTMy9GoNeBttR/iLeOs+q2hi3ernj
GbwCAWUT5jaJTlxhUyBJcUz9ir3+ptJpozo5e2d9c6WcLkWL7zzKNWhT1kbMyaT6
+C9RaTOgWRSFaSKZ3/jNEmxkZWJx/WZuS+QP0Gsoax91vRCChHUCc/LMA6wxHYie
yVEXZdk4v0w76UzgISWMb0XWo2koU7sQaNE4BMwwTdx7qKFfqEGPo6RvuSSZFz+A
mWwBMZG5zHZB6j3ZoSeS4L54qjSoTaznCLSEZJE2hZ/geQ6GB86ADBV/Hb7SsJnf
MaItv2BHc5aGd6jn6DKicc+RcmRLjnwkeqOxCaUWKv7wcGMFNUrvqauU2ebIMH3X
dvGJtQ0afJT7Ak6d7Eyb5jEkYbJ8XjMMMoi2sKr8Ss45e+KYVnJ1qagsSfm7SaWg
BjtvKz50fQocLraU5lTo4HVsJrn1gNSiGSMDOGddWkiNvbU11HN1zPvTDUez5PCj
CtDiyyM3jYqZezlXEipk
=KXaN
-----END PGP SIGNATURE-----

David Teigland (50):
      move pv_list code into lib
      Allow dm-integrity to be used for raid images
      WHATS_NEW: integrity with raid
      vgrename: fix error value when name exists
      lvmcache_get_mda: remove unused function
      pass cmd struct through more functions
      lvmcache: rework handling of VGs with duplicate vgnames
      use refresh_filters only where needed
      remove vg_read_error
      lvmlockd: replace lock adopt info source
      lvmlockd: use 4K sector size when any dev is 4K
      devs: add some checks for a dev with no path name
      hints: free hint structs on exit
      lvmcache: free vginfo lock_type
      lvconvert: error when using existing cachevol
      pvck: dump headers_only to skip metadata text
      tests: integrity wait for sync
      integrity: skip calling add when removing images
      Revert "pvck: dump headers_only to skip metadata text"
      improve info about vgck updatemetadata
      writecache: remove from an active lv
      writecache: show error in lv_health_status and lv_attr
      writecache: cachesettings in lvchange and lvs
      writecache: attach while active using fs block size
      writecache: add settings cleaner and max_age
      tests: writecache-blocksize
      fix bad result from _cache_min_metadata_size
      writecache: allow snapshot of LV with writecache
      writecache: activate to check block size
      tests: writecache tests
      fix libblkid BLOCK_SIZE check
      integrity: fix block size check when inactive
      tests: expand integrity-blocksize
      tests: fix typo in writecache-blocksize
      improve get_fs_block_size string to number
      tests: integrity and block size
      integrity: avoid increasing logical block size of active LV
      integrity: wait for raid sync to complete
      lvconvert: single step cachevol creation and attachment
      lvcreate: new cache or writecache lv with single command
      tests: cachevol-cachedevice
      man: lvmcache info about cachedevice usage
      integrity: add initial size to metadata size
      writecache: skip fs block size check in test mode
      devices: detect md ddf and imsm superblocks
      devices: simplify md superblock checking code
      lvmdbusd: recognize lv attr letter g for integrity
      integrity: allow type option to be set when changing mirrors
      cachevol: generate a unique name when creating
      cachevol: add LV type restrictions to command defs

Heinz Mauelshagen (5):
      lv{resize,extend,reduce}: reject size change on 2-legged raid5*
      lv{resize,extend,reduce}: also check for 2-legged raid4
      lvconvert: fix conversion to 'mirrored' mirror log with larger regionsize
      lvconvert: preset raid1 in case of striped conversions
      lvconvert: display warning if raid1 LV image count does not change

Marian Csontos (10):
      post-release
      spec: Enable integrity
      build: make generate
      tests: Use python single liner to generate data
      test: Use printf to generate data
      test: Warn and exit on problematic integrity device behavior
      tests: Adapt RAID test to changes
      build: make generate
      WHATS_NEW
      pre-release

Maxim Plotnikov (1):
      Fix scripts/lvmlocks.service.in using nonexistent --lock-opt autowait

Peter Rajnoha (2):
      blkdeactivate: add support for VDO in blkdeactivate script
      blkdeactivate: add missing VDO_AVAILABLE check in deactivate_vdo

Tony Asleson (1):
      WHATS_NEW: Add writecache lvmdbusd

Vojtech Trefny (2):
      lvmdbusd: Add support for LVM writecache
      lvmdbusd: Bump LVM DBus API version

Zdenek Kabelac (24):
      lvconvert: no validation for thin-pools not used by lvm2
      test: repair of thin-pool used by foreign apps
      WHATS_NEWS: update
      cov: check for deactivation failure
      cov: check strdup for NULL
      cov: lvconvert: missing check for function failure
      pvck: set dump on one call
      list:  use container_of
      tests: add wait on udev processing
      tests: also udev wait on clean-up path
      bcache: support longer writes
      wipe_lv: make error a fatal event
      pool: zero metadata
      cov: use 64bit arithmetic
      cov: remove unused header
      cov: avoid double call of free_hints() on error path
      man: update cache page
      make: make generate
      tests: failure of zeroing fails command
      tests: check pool metadata are zeroed
      wipe_lv: always zero at least 4K
      lvconvert: more support for yes conversion
      raid: no wiping when zeroing raid metadata device
      debug: missing stacktrace

Zhao Heming (1):
      Change dev->bcache_fd default value from 0 to -1


