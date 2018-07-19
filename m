From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 19 Jul 2018 12:44:30 -0400
Subject: v2_02_180 annotated tag has been created
Message-ID: <201807191644.w6JGiUGa006440@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a4cf189af26eb298f92de8bf30b5aa3ac364796c
Commit:        a4cf189af26eb298f92de8bf30b5aa3ac364796c
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-07-19 16:36 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-07-19 16:36 +0000

annotated tag: v2_02_180 has been created
	    at a4cf189af26eb298f92de8bf30b5aa3ac364796c (tag)
       tagging bb384f84880a183ee58a18935851eece25cdada4 (commit)
      replaces v2_02_179

Release 2.02.180

Bug fix release, fixing mainly broken lvmdbusd and udev interaction.

Other notable changes:
- Never send any discard ioctl with test mode.
- Fix unmonitoring of merging snapshots.
- Fix lvmetad hanging on shutdown.

See WHATS_NEW for more.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJbUL8VAAoJELkRJDHlCQOfpJwP/0mHxkLf5G2/iVgClyJFgDQI
SNi0K0IbGBs2IXP0FxlxZGUcqiUS76NqyVqd+BxxWLsQgKIshSvwDMYFlzeDvj4o
T3eBd58AeM1sXdd8wHIeeqJ0y2ZCKTU+S+DILmLZq5A3FopPJCdVwuNb/Xf0KTxU
wwbEZwis8hhO/hnjmj+ZHJuOiBVjcFarfA/8XmgR8VgdOxty4EL5Un6bbAuyads0
qLPCsBj/ryFCfLT5UgkNARVQNu+TufgLmV7EldcdE4nOrTatxXpWZ8R9z/a6iCJQ
Icou3Qiv2V75dsIARBwx6EeshTyUz1QJphsx0vn4PKS7/f2A//aZJgrf7mI8zKbd
jwrgI2xsh/7o+fH0C+U4MSBiBoIm7GavzN5YEgBGrYYPv6DlZxAQ2RY+wcJ/3zZ5
6s5Yfs0wf3HEwvePdml3bYtneDTOFr/1u3P9pIW4D1XFP8BdXK7GYgxIQKx82LDa
unOhSvh94A6JMhSl/yPhxhK8yJYdOOZo8JSEZJVnSCNvudqtLUjVO+wbjV2LQozt
RDJ3V6RpuxIWe8oBMedhwbhqtC+7jCZZip2hnAiAkfBFOaq4Zfl4Q7XpkCg69ZpD
EnGuwHc27dbVdoCI3vOdB8fPZlkHY8FZBH5cNbaq3m/f+QZQVCmC2v90W1+NGu+0
hkZ3JVle9GlKKda5UM+e
=cnIz
-----END PGP SIGNATURE-----

David Teigland (12):
      bcache: remove extraneous error message
      clvmd: fix leak of saved_vg struct
      scan: work around udev problems by avoiding open RDWR
      WHATS_NEW: recent changes
      lvmlockd: fix another missing lock_type null check
      coverity warnings about null info in lvmcache.c
      filter: use pointers to real addresses
      bcache.c add missing {
      scan: reopen RDWR during rescan
      devs: use bcache fd for read ahead ioctl
      man: fix lvreduce example
      Revert "man: fix lvreduce example"

Heinz Mauelshagen (4):
      segtype: add linear
      lvconvert: support linear <-> striped convenience conversions
      test: add convcenience conversion tests linear <-> striped
      WHATS_NEW

Marian Csontos (7):
      post-release
      libdm: fix buffer overflow
      bcache: fix memory leaks
      filter: make pointers distinguishable
      bcache: Fix null pointer dereferencing
      WHATS_NEW
      pre-release

Zdenek Kabelac (16):
      vgchange: fix error code in error path
      pvscan: code reshape
      systemd: add conficting sockets
      pvresize: update message
      pvresize: add missing return
      pvmove: improve lvs
      cache:  cleaner policy also uses fmt2
      fsadm: missing -l description
      snapshot: improve checking of merging snapshot
      vcfgrestore: add prompt with active volumes
      tests: update with --yes
      memlock: extend exception list
      allocator: fix thin-pool allocation
      dev_io: no discard in testmode
      WHATS_NEW: update
      allocation: add check for passing log allocation


