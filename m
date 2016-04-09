From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  9 Apr 2016 01:14:18 +0000 (UTC)
Subject: v2_02_150 annotated tag has been created
Message-ID: <20160409011418.D1CB260ED4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eadbe39b7a9017c63cec232c2f62717048f551f1
Commit:        eadbe39b7a9017c63cec232c2f62717048f551f1
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-04-09 01:09 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-04-09 01:09 +0000

annotated tag: v2_02_150 has been created
	    at eadbe39b7a9017c63cec232c2f62717048f551f1 (tag)
       tagging 3aab784aa5cbbe4f86cbc1c8a33579dc32c991eb (commit)
      replaces v2_02_149

Release 2.02.150

A small bug-fix release.

24 files changed, 262 insertions(+), 139 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlcIVm4ACgkQIoGRwVZ+LBe1DQCgg02s7rQe1ll+DpzphKvqXTpw
GQIAn3X5HiuGNflwPFs28bBd3RGyXqmd
=FTsd
-----END PGP SIGNATURE-----

Alasdair G Kergon (6):
      post-release
      lvmdump: Allow dir to exist already if it is empty
      lvmdump: If dir exists check dir perms too.
      libdm: Correct typo.
      activation: Skip another non-prefixed info ioctl.
      pre-release

Marian Csontos (1):
      test: Fix testing of installed lvmdbusd

Peter Rajnoha (3):
      cleanup: use #define for field's quote and pair character and also for the error msg while extending output line
      cleanup: use common init/destroy_processing_handle in _report fn and cleanup error paths
      report: remove superfluous SEGSSTATUS report type

Zdenek Kabelac (17):
      mirror: fix flushing for mirror target
      suspend: fix suspend with noflush limitation
      preload: preserve flushing state
      libdm: improve debug message with ioctl
      lvconvert: show percent with %.2
      cleanup: indent
      tests: verify repair of failing mirror
      tests: do not break teardown on failing losetup
      WHATS_NEW: update
      lvcreate: %FREE -> %PVS
      activation: do not check for devs without LVM-
      tests: use mkfs.ext3
      tests: require newer cache target
      dev_manager: device_is_usable does not flush
      cleanup: reuse _setup_task
      cleanup: simplier to read condition
      cleanup: avoid gcc warns


