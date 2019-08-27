From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 27 Aug 2019 11:37:54 -0400
Subject: v2_02_186 annotated tag has been created
Message-ID: <201908271537.x7RFbshj027886@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a17661b9cdfc6b6d9762e7d42515f1b1c751e0ae
Commit:        a17661b9cdfc6b6d9762e7d42515f1b1c751e0ae
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2019-08-27 15:22 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2019-08-27 15:22 +0000

annotated tag: v2_02_186 has been created
	    at a17661b9cdfc6b6d9762e7d42515f1b1c751e0ae (tag)
       tagging 4e5761487efcb33a47f8913f5302e36307604832 (commit)
      replaces v2_02_185

Release 2.02.186

Bug fix release.

Notable changes:

Fix not working RAID repair.

Allow --stripes/--stripesize in 'mirror' conversions.

Disable incorrect linear to mirror of active LV in cluster VG.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJdZUzQAAoJELkRJDHlCQOfQa8P/1TM1oNoCkwkkWuSDVeSg8KT
axHyGJnxDqVivwasPRx3xvaP0NsRsc2mpZxB9NChfZdwkrF3+CF5fVsqSVLnGHxL
HCeHfOV5PjtsQAf+uUG6AS/fZllW1iRfeaMxXEqaa/DbRrspaJQtMj8JEVn7b0l9
Fi2R3nKeaNio8AHfxupZz9McZaBgF6QihqEOVgLl/gaOZ24RcyAvU1onIzyz3OnJ
8QMfiA3UHc1UwpP79nCcSbx8ndDMJxoxK/HuyVMNatNP18RZ0KQy6gMR92ViWjiQ
InEte1qj+3rzWskbk2zTPrBLUYAnx2UTyGbbWdwY+ub7Z4Dj5ZBq9kIIW/gHcCJF
ApUhR2IB6iCA8EsooLvVBzGW+SKMC5E+xt94uUzKEP+WClxqRamPZ7Z5vKHDuJNz
5Q9VZOHag/z4vzKyyOh874Gd4STec6rOi6DIBVgXhxMjDqZUm7hRrr/4io56pToH
nNLrOr9JQF9rwgxWQHXjkcWZpEPHHzhAc4NSyXIscegzS1F+KODUHlkCJpRWHRTD
mZODtB648uUK9XKyYGbnMXSRBJnAf2rq8XDpyzvOvETBx73r5dpTlBb5UlOb9GGm
OzlonVwXiFcB3Ru/WnRqUBHqShe7aqfGt8Hay4rwLwlfH7FhyqeuDDFf8H6ZEo8k
tOHO9oY1QcJWSSQjGnFx
=uehd
-----END PGP SIGNATURE-----

David Teigland (15):
      lvmlockd: do not allow mirror LV to be activated shared
      man: updates to lvmlockd
      lvmcache: remove unused_duplicate_devs list from cmd
      lvconvert: disable linear to mirror of active LV in cluster VG
      Revert "lvconvert: disable linear to mirror of active LV in cluster VG"
      pvremove/vgextend: fix using device aliases with lvmetad
      tests: fsadm-crypt.sh update mkfs parameter
      vgrename: use global lock
      Fix rounding writes up to sector size
      tests: large-physical-sector-size
      WHATS_NEW: fix large physical block size
      vgchange: don't fail monitor command if vg is exported
      man lvmthin: remove nonexistent topic
      devices: put ifdef around BLKPBSZGET
      pvscan: avoid redundant activation

Heinz Mauelshagen (4):
      lvconvert: allow --stripes/--stripesize in 'mirror' conversions
      pvmove_poll: instrument
      dmeventd: avoid bail out preventing repair in raid plugin
      Revert "pvmove_poll: instrument"

Marian Csontos (5):
      post-release
      build: Fix make rpm with releases
      cov: Fix a leak
      build: make generate
      pre-release

Peter Rajnoha (1):
      udev: do not overwrite ID_MODEL in 69-dm-lvm-metad.rules

Zdenek Kabelac (49):
      tests: update cache test
      cache: support no_discard_passdown
      tests: automatically set scan_lvs when using extend_filter
      tests: check no_discard_passdown
      mirror: fix monitoring change
      tests: replaces grep -q usage
      tests: fix ra checking
      tests: check mirror with clvmd and dmeventd
      aux: fix selecting lvmconf values
      tests: simplify some var settings
      tests: update resize value
      tests: check for installed time command
      tests: for cluster testing we always need exclusive mirrors
      tests: drop unwanted backup
      tests: properly enforce v1
      tests: accept also value 512
      tests: for cluster always use exlusive mirrors
      cov: unlock lvm2 mutex on error path
      cov: release iterator on error path
      cov: check result of dev_read_bytes
      cov: check result of dev_get_block_size
      cov: check lv_info
      cov: check for socket_path being set
      cov: add stack tracing for error paths
      cov: clearer condition check
      cov: validate pagesize is not negative
      cov: ensure cname exists before derefering it
      cov: remove unused headers
      libdm: implement search for device names for older kernels
      gcc: cleanup warning of shawhing a global dclr
      gcc: clean uninitialized var warning
      cov: release iterator on error path
      cov: avoid recursive self-inclusion
      tests: raise minsize of xfs
      tests: use luks1 for test
      tests: split args
      tests: add settle wait before issue remove
      make: support comments in exported symbols
      exported_symbols: comment old symbols
      pvmove: correcting read_ahead setting
      pvmove: add missing synchronization
      activation: add synchronization point
      dmsetup: debug print
      activation: extend handling of pending_delete
      snapshot: always activate
      cache: improve vgremove loop
      lv_manip: add synchronizations
      dmsetup: missed trailing newline
      activation: use cmd pending mem for pending_delete


