From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 6 Oct 2017 17:30:51 -0400
Subject: v2_02_175 annotated tag has been created
Message-ID: <201710062130.v96LUpIq026946@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=79177d1c89d99596d612e79e2b689336dd57cd26
Commit:        79177d1c89d99596d612e79e2b689336dd57cd26
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2017-10-06 21:12 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2017-10-06 21:12 +0000

annotated tag: v2_02_175 has been created
	    at 79177d1c89d99596d612e79e2b689336dd57cd26 (tag)
       tagging 73b72b8331949a1af778ad34491de3c7663c107f (commit)
      replaces v2_02_174

Release 2.02.175.

A small release with an assortment of fixes.

Also note that we do not intend to develop lvm2app or the python bindings any
further, and would like any users to move towards the D-Bus interface.
(Reference: https://github.com/lvmteam/lvm2/issues/1 )

48 files changed, 712 insertions(+), 194 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlnX8qcACgkQIoGRwVZ+LBfDMwCfVMlyP3W3510chWCuDHzCjmED
McoAni9FgeEsWxBxupz3b/G7/1dCRLjs
=KwpA
-----END PGP SIGNATURE-----

Alasdair G Kergon (5):
      kernel: Refresh dm-ioctl.h
      dmsetup: Process -S to filter input device lists.
      vgsplit: Fix intermediate metadata corruption.
      vgmerge: Fix intermediate metadata corruption
      pre-release

David Teigland (7):
      revert tidy: prefer not using else after return
      lvcreate: use cmd defs to deny unspported lockd cases
      man pvscan: just write --activate in description
      toollib: fix parentheses in assignment + comparison
      lvmlockd: activate mirror LVs in shared mode with cmirrord
      pvmove: require LV name in a shared VG
      improve error messages when command rules fail

Heinz Mauelshagen (1):
      raid: enhance conversion rejection message

Marian Csontos (5):
      liblvm: Deprecate library and bindings
      liblvm: Add deprecation warning to configure
      configure: Update configure
      configure: Add warning for D-Bus w/o notifications
      pvmove: Change error message

Peter Rajnoha (6):
      blkdeactivate: fix --{dm,lvm,mpath}options option name recognition
      blkdeactivate: fix blkdeactivate regression with failing DM/MD devs deactivation
      blkdeactivate: add blkdeactivate -r wait option to wait for MD resync/recovery/reshape
      blk-availability: use blkdeactivate -r wait in blk-availability systemd service/initscript
      blkdeactivate: also try to unmount /boot on blkdeactivate -u if on top of supported device
      blkdeactivate: cleanup

Thomas Lamprecht (1):
      dmeventd: ensure systemd service gets stopped on shutdown

Tony Asleson (6):
      lvmdbusd: Fix hang in MThreadRunner
      lvmdbusd: Ensure vg_uuid is present
      lvmdbusd: Improve args comparison
      lvmdbusd: Main thread exception logging
      lvmdbusd: Give threads names
      lvmdbusd: thread stacks dump support

Zdenek Kabelac (8):
      lvconvert: repair supports poometadatespare switch
      lvconvert: support repair of cache/cachepool
      libdm: fix parentheses in assignment + comparison
      tests: check for free space in test dir
      tests: repair of cachepool
      tests: use portable df output
      dmeventd: schedule exit on break
      fsadm: add --help


