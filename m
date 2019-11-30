From: Marian Csontos <mcsontos@sourceware.org>
Date: Sat, 30 Nov 2019 08:58:57 -0500
Subject: v2_03_07 annotated tag has been created
Message-ID: <45473.119113008585300437@us-mta-60.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd00599af4b57112904de27ee43dfa50cac72c18
Commit:        bd00599af4b57112904de27ee43dfa50cac72c18
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2019-11-30 13:54 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2019-11-30 13:54 +0000

annotated tag: v2_03_07 has been created
	    at bd00599af4b57112904de27ee43dfa50cac72c18 (tag)
       tagging 3d7f755674c651a012f7dc6c10e67bdd330a33ae (commit)
      replaces v2_03_06

Release 2.03.07

- Subcommand in vgck for repairing headers and metadata.
- Fix resize of thin-pool with data and metadata of different segtype.
- Fix activation order when removing merged snapshot.
- Experimental VDO support for lvmdbusd.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJd4nUbAAoJELkRJDHlCQOfUCsQAOPSm1zwahQMMmzyviFUGDBo
x6D/yZOC4P/jV+mTvyaKykrZIwWDuM1m0O2E8C+/6EIbJYUMktEffGL6zzaIM43A
vV8kyRrp+MnuqySKc/sqes37NM0RqUgg3fjzYV36s8AST5xvvcWfGehKTz4dO8sq
ZuOIuGl55O2NdeLAKKMoDVwzBky7gp1ouNX6vcAPgdASFHzBC5SbKlZpmQwweOgy
f9KDkrWTPv6j76nCqkwC7nx6yE0/3UAilnFp0PvFgAMXYcFsSuV9rtsw0yUS5iQP
i6hUdPQnjGYrpWVY0l9D6QTGd/iHyE3CC/cCESkGVvLchJcsGUcF2SVOo2TyOj50
lSknU8fpz/fnDxBGdGdMe6IQL16RfKrYSISSzy1qKCWFfODlD8GJClYlwyxUg1D8
xc6taMPKo6bOR32RfrrS+GgMwd9tTxYrvoza9V4Baoh7ZqC+ptD+jynMYwGlCrBw
1E0YNFS6rfplCCtMsH9Ngl9i/bjIUcmQ+TSN9HoCKZYM19zJhjVJaKdqYbm2RF6c
bTN51W+/Zk0eLV/HPgqJNMdhX3jNTZDZyVWXvFatzGNO8V/kWe4eF+aQcneJNFWV
T5orqbusNXCY1UVgVueFC+G2hRcqA+LRVwOTJZXZgv8PHmMEJzdttrd0h/C0z0FM
GzIb/AlWVENSvkWg7g1s
=EDW7
-----END PGP SIGNATURE-----

David Teigland (27):
      man lvmthin: change wording about mounting xfs
      tests: lvmlockd-lv-types handle new cpool renaming
      lvmlockd: fix cachevol locking
      Revert "debug: enhance debug messages"
      Revert "hints: rewrite function"
      lvs: disable scanning optimization
      tests: update to md dev name
      writecache: modprobe dm-writecache
      pvcreate,pvremove: fix reacquiring global lock after prompt
      bcache: add invalidate_bytes function
      scanning: optimize by checking text offset and checksum
      Revert "lvs: disable scanning optimization"
      tests hints: update check for io count
      scanning: use bool type for _scan_text_mismatch
      Revert "cov: check for retvalue"
      Revert "cov: avoid passing NULL to strstr function"
      Revert "cov: fix mem leaking buffer"
      Revert "pvck: check result of dev_get_size"
      Revert "cov: use zalloc"
      metadata: add vg_from_config_tree
      scan: add simple scan to find a pvid
      pvck: move some arg processing
      pvck: allow disk locations to be specified
      pvck: dump show most recent metadata
      pvck: dump functions cleanup args and return vals
      pvck: repair headers and metadata
      pvck: use zalloc in more places

Heinz Mauelshagen (2):
      man: adjust 'disks' to 'devices' as used throughout
      lvcreate: ensure striped raid region size is at least stripe size

Heming Zhao (1):
      fix dev_unset_last_byte after write error

Joe Thornber (6):
      [bcache] add bcache_abort()
      [label] Use bcache_abort_fd() to ensure blocks are no longer in the cache.
      [bcache] add unit test
      [bcache] pass up the error from io_submit rather than using generic -EIO
      [bcache] reverse earlier patch.
      [bcache] bcache_invalidate_fd, only remove prefixes on success.

Marian Csontos (7):
      post-release
      test: Fix metadata-zero-space with long VG names
      test: Fix handling leftovers from previous tests
      Partial revert "tests: update to md dev name"
      tests: Find md name using lsblk
      build: make generate
      pre-release

Tony Asleson (34):
      lvmdbusd: Remove duplicate error handling code
      lvmdbusd: Remove use of tmp variables
      lvmdbusd: Add d and D to type map for VolumeType
      lvmdbustest.py: Add blurb about scan_lvs = 1
      lvmdbusd: Add check for reserved name '_vdata'
      man: Include '_vdata' as reserved name
      man lvmvdo: Correct spellings
      lvmdbustest.py: Remove duplicate setup code
      lvmdbusdtest.py: Use common function for tag add
      lvmdbustest.py: Add function for lv path check
      lvmdbustest.py: Add func. _all_pv_object_paths
      lvmdbustest.py: Add func. _create_thin_lv
      lvmdbustest.py: Use existing _create_lv
      lvmdbustest.py: Add func. _pv_scan
      lvmdbustest.py: Remove 2 TODOs
      lvmdbusd: Add cfg.vdo_support
      lvmdbusd: Add VgVdo class & assoc. interface
      lvmdbustest.py: Add cache LV rename test
      lvmdbusd: Prevent running --nojson with VDO support
      lvmdbustest.py: WS corrections
      lvmdbustest.py: Add nested helper function major_minor
      lvmdbustest.py: Create common func. _create_cache_lv
      lvmdbusd: VDO Pool LV representation
      testlib.py: Correct dbus signature verification
      lvmdbustest.py: Add basic vdo test
      testlib.py: WS corrections
      testlib.py: Add interface instance vars.
      lvmdbusd: Bug fix for activate/deactivate
      lvmdbusd: Fix model inconsistency when LV loses interface
      lvmdbusd: Debug msg. improvements.
      lvmdbustest.py: Add tests for LV interface
      lvmdbustest.py: Improve concurrent test handling
      lvmdbustest.py: Use local data instead of fetching
      Experimental VDO lvmdbusd support

Zdenek Kabelac (55):
      snapshot: correctly check device id of merged thin
      snapshot: fix checking of merged thin volume
      snapshot: use single merging sequence
      tests: explicit testing of thin snapshot
      WHATS_NEW
      mirror: fix leg splitting
      mirror: directly activate updated mirror
      mirror: remove unused code
      manip: optimize lvs_using_lv
      raid: drop internal error
      tests: reduce space requirements
      activation: drop removed declaration
      WHATS_NEW: update
      tests: avoid checking command result in cluster
      tests: conversion only of exclusive lv
      tests: slowdown delay of raid
      tests: skip test if scsi_debug is not available
      tests: be happy with less then 90 percent
      gcc: avoid declaration shadowing
      cov: missing checks of syscalls
      cov: ensure read_ahead is available
      daemon: better error path handling for shutdown
      daemons: check for non-zero thread_id
      tests: skip unneeded status check
      tests: add extra settle
      lvextend: fix resizing volumes of different segtype
      tests: add test of resize of different segtypes
      WHATS_NEW: update
      cov: fix memory leak
      devtype: simplify code
      cov: check for NULL
      cov: fix memleak for duplicate device
      cov: check for retvalue
      cov: avoid passing NULL to strstr function
      cov: fix mem leaking buffer
      pvck: check result of dev_get_size
      hints: rewrite function
      hints: allocate hint only when needed
      hints: validate sscanf results
      hints: validate allocation result
      hints: fix mem leaking buffers
      hints: check for _touch_hints
      cov: inline _build_desc_write
      dmeventd: vdo plugin link lvm library
      cov: more checks for failing syscalls
      cov: remove unused headers
      cov: add explicit ret value ignoring
      cov: use zalloc
      hints: no need to check for NULL before free
      hints: drop unneeded memset
      debug: enhance debug messages
      tests: enusure lib is initilized
      revert "dmeventd: vdo plugin link lvm library"
      tests: reduce amount of written date
      tests: add more tracing info



