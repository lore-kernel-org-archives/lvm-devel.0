From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Mar 2020 18:28:43 +0000 (GMT)
Subject: v2_02_187 annotated tag has been created
Message-ID: <20200324182843.9A3D1385E021@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff28294988a39072c59e0a3d3ab871b889c48959
Commit:        ff28294988a39072c59e0a3d3ab871b889c48959
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2020-03-24 18:24 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2020-03-24 18:24 +0000

annotated tag: v2_02_187 has been created
	    at ff28294988a39072c59e0a3d3ab871b889c48959 (tag)
       tagging 84c239c4e59361bd279fd7fe33fff97399f0a1f7 (commit)
      replaces v2_02_186

Release 2.02.187

Bug fix release.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJeelCvAAoJELkRJDHlCQOfQsoQAPI35RChB29ctF/V3S4Ahbu2
X5+KMGtw+/eb4Pc2e+OfWg9AGvnbQLm7BVpG61q10qzWVuHyGNMarqjuj5Y0xQTP
zjRpa6VwI/OPRFA/M5AEADiiRBzDySaio1tb/1HVUI9ZftiWGzdpX52hG/MxGIQr
imTHPoGs/7kX+Qh/DozHosYyxCEH0Mv131herpfRkVS4u0MBxnDNImZoqbAmvE9n
tRhjO8jSaeQG9GixqCtykTPrsO+8HszKV9zmk3m4vfmLlSTduQX8oNY27iOKc0wN
f3PKmQoKlzKdH/6d1D3Qg6ZptlfRWFq6GclKxmAGdw/7A2PNFwVeMvOo4jePMLBH
k5Xj29q8PSrKAQTVh0ljXaIrgF50w5IT+km3tH3J0v0hAc8Vqtsp7GRzXvPaPmAc
XtuAVnoSEpxJfIKpJsjeHHeAlGq1KmasONZdsWoo74XFScIEts/D6Fc5qSUIqFNE
97XCp2EZHa6cU85LsRa7ofb5bw4/+fsDGxN72Iii6Rbcvm3ihnMQ2/Ne4DS8uZr6
VFSDN2snpX5vLpXhJdLP8VHf50k3Pua4yUMYROuF8JZSkISxVaqT4265Go/nmJG0
33YDCGx4PmnRWbX3VAigxUku31gxR10thzlh/ldlcEHX14YYYqnWtNBL9oWAC0Ds
zFLYrdhUYCvJcuCcCHbL
=riIu
-----END PGP SIGNATURE-----

Bryn M. Reeves (1):
      dmsetup: do not treat no groups as an error in dmstats list --group

David Teigland (16):
      pvscan: fix activation of incomplete VGs
      tests: add test for pvscan activation of incomplete vg
      vgcreate/vgextend: restrict PVs with mixed block sizes
      tests: allow-mixed-block-sizes
      WHATS_NEW: vgcreate/vgextend logical block size
      tests: allow-mixed-block-sizes skip with older losetup
      lvmetad: fix sync cache to lvmetad
      devs: check for no dev when dropping aliases
      Revert "vgcreate/vgextend: restrict PVs with mixed block sizes"
      tests: remove allow-mixed-block-sizes
      Revert "Revert "vgcreate/vgextend: restrict PVs with mixed block sizes""
      Revert "tests: remove allow-mixed-block-sizes"
      config: allow_mixed_block_sizes set default to 1
      config: allow_mixed_block_sizes set version 2.02.187
      Fix rounding writes up to sector size
      pvs: fix locking_type 4

Heinz Mauelshagen (9):
      lvchange: add --resync help/manual text relative to 'R' attribute
      Revert "dmeventd: avoid bail out preventing repair in raid plugin"
      dmeventd: avoid bail out preventing repair in raid plugin but keep message
      test: add checks for not 100% sync ratio after initiation of check/repair
      test: add RAID lvextend resynchronization test
      test: increase size of raid10 LV allowing tests to succeed on fast storage
      WHATS_NEW: new lvextend-raid.sh test
      man: adjust 'disks' to 'devices' as used throughout
      lvcreate: ensure striped raid region size is at least stripe size

Heming Zhao (1):
      fix dev_unset_last_byte after write error

Joe Thornber (9):
      [radix-tree] Bring radix-tree up to date with the master branch
      [bcache] Bring bcache into sync with master branch
      [bcache] add bcache_abort()
      [label] Use bcache_abort_fd() to ensure blocks are no longer in the cache.
      [bcache] add unit test
      [bcache] pass up the error from io_submit rather than using generic -EIO
      [bcache] reverse earlier patch.
      [bcache] bcache_invalidate_fd, only remove prefixes on success.
      [radix-tree] Add missing test case

Marian Csontos (14):
      post-release
      cov: Fix memory leak
      spec: Move blkdeactivate to device-mapper
      lvmetad: Fix function prototype when not configured
      build: make generate
      spec: Fix lvm2-activation-generator man page handling
      cov: Clarify the control flow
      dm: Fix compilation of dmsetup
      build: autoconf
      WHATS_NEW: update
      test: Fix handling leftovers from previous tests
      base: Get Makefile from master
      bcache: Fix memory leak in error path
      pre-release

Mikulas Patocka (1):
      dm: introduce DM_GET_TARGET_VERSION

Zdenek Kabelac (51):
      lvconvert: improve validation thin and cache pool conversion
      tests: pool conversion
      devices: crypto skip
      thin: activate layer pool aas read-only LV
      pvmove: check if participating LV is already exlcusively active
      lvmetad: fix timeout on shutdown
      debug: drop some unneeded backtraces
      pvmove: detect exclusively active LVs
      debug: avoid to slashes in debug message
      tests: really check disabling of lvmetad
      snapshot: correctly check device id of merged thin
      snapshot: fix checking of merged thin volume
      snapshot: use single merging sequence
      tests: explicit testing of thin snapshot
      WHATS_NEW
      tests: needs exclusive activation for conversion
      mirror: fix leg splitting
      mirror: directly activate updated mirror
      mirror: remove unused code
      manip: optimize lvs_using_lv
      raid: drop internal error
      tests: reduce space requirements
      WHATS_NEW: update
      tests: avoid checking command result in cluster
      tests: conversion only of exclusive lv
      tests: needs some raid
      tests: skip test if scsi_debug is not available
      tests: larger are needs to be disabled
      tests: be happy with less then 90 percent
      gcc: avoid declartion shadowing
      cov: missing checks of syscalls
      cov: ensure  read_ahead is available
      lvmcache: free resource on error path
      daemon: better error path handling for shutdown
      daemons: check for non-zero thread_id
      tests: skip unneeded status check
      tests: add extra settle
      lvextend: fix resizing volumes of different segtype
      tests: add test of resize of different segtypes
      WHATS_NEW: update
      tests: fix else path
      raid: disallow reshape of stacked LVs
      vdo: avoid running initialization of cache pool vars
      WHATS_NEW: update
      tests: writeerror_dev
      tests: add corruption write on PV test
      raid: more limitted prohibition of stacked raid usage
      aux: writeerror_dev  checks for delay target
      tests: skip test when dm-delay is not available
      tests: partial revert of test change of b6e6ea2d65785f03f3cee7938be635bcb8ad4944
      raid: better place for blocking reshapes

wangjufeng (1):
      lvmetad: fix heap memory leak



