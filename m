From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 12 Jun 2015 20:46:48 +0000 (UTC)
Subject: v2_02_121 annotated tag has been created
Message-ID: <20150612204648.B760360F02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e071e87b703fdf7f980554795292cdd97427173c
Commit:        e071e87b703fdf7f980554795292cdd97427173c
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-06-12 20:41 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-06-12 20:41 +0000

annotated tag: v2_02_121 has been created
	    at e071e87b703fdf7f980554795292cdd97427173c (tag)
       tagging 2c64762a40dba77a52de8a3459d68a740a5da1c7 (commit)
      replaces v2_02_120

Release 2.02.121.

73 files changed, 884 insertions(+), 392 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlV7RBsACgkQIoGRwVZ+LBcvcACgpv0XWlgCDl+VVoLFGbeXYK0K
KBMAoN1LsC8Vxl1xlSc76GfSzNIpDES+
=xAeA
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      libdm: Add dm_task_get_errno to return ioctl errno.
      pre-release

David Teigland (10):
      tests: add test for duplicate pvs
      pvmove.c: call vg_read directly
      lvconvert.c: call vg_read directly
      polldaemon.c: call vg_read directly
      lvconvert.c: call find_lv directly
      polldaemon: remove get_copy_vg and get_copy_lv wrappers
      pvmove.c: code cleanup
      lvconvert.c: drop get_vg_lock_and_logical_volume fn
      man: lvmthin chunk and metadata sizes
      lvmetad, lvmpolld: remove DL_LIBS from Makefile

Lidong Zhong (1):
      lvconvert: change how to get failed mirrors number

Ondrej Kozina (16):
      polldaemon: move dev_close_all out of poll_get_copy_vg
      polldaemon.c: call find_lv directly
      polldaemon.c: do not report error when LV not found
      WHATS_NEW: various updates
      polldaemon.c: modify log levels in report_progress
      lvmpolld-client.c: debug print when querying progress
      lvmetad.c: ignore lvmetad global handle on disconnect
      tests: add test for pvscan --cache --background
      WHATS_NEW: update
      lvconvert.c: fix whitespace mess
      lvmpolld: zero errno in before strtoul call
      dmsetup: zero errno in before strtoul call
      WHATS_NEW: various updates
      lvmpolld: terminate error message with a dot and LF
      lvmetad.h: rephrase API descriptions
      lvmetad.c: internal err on modifying global handle with open connection

Peter Rajnoha (1):
      scripts: activation generator: do not use --sysinit if lvmpolld used

Petr Rockai (13):
      lvmetad: Maintain info about outdated PVs.
      lvmetad: Clear the vgid_to_outdated_pvs hash on shutdown.
      lvmetad: Attach an outdated_pvs list to vg_lookup replies.
      metadata: Factor _wipe_outdated_pvs() PVs out of _vg_read().
      metadata: Add pvs_outdated to struct volume_group.
      lvmetad: Provide entire pvmeta sections for outdated_pvs.
      lvmetad: Set up lvmcache & PV structs for outdated_pvs.
      format_text: Parse (optional) outdated_pvs section in VG metadata.
      metadata: Explain the pvs_outdated field in struct volume_group.
      lvmetad: Make it possible to clear the outdated PVs list for a VG.
      metadata: Reject lvmetad metadata extensions when reading from disk.
      metadata: When outdated PVs are wiped, notify lvmetad about the fact.
      test: Ensure that outdated PVs are wiped just once.

Zdenek Kabelac (18):
      tests: no warn if test does not need thin_repair
      configure: move DEFS to configure.h
      makefiles: use single target
      makefiles: use := for shell calls
      makefiles: better clean
      makefiles: drop LVM_SHARED_PATH
      tests: thin_restore  not needed
      tests: fix calcucaltion
      configure: LOCALEDIR needs evaluated value
      configure: update localedir
      configure: fix missing [
      makefiles: use bash subshell
      cleanup: gcc warn fix, don't hide pvs()
      tests: drop debug print
      tests: better check for array in sync
      tests: check for clmvd socket
      lvmetad: missing wrapper for lvmetad less compilation
      tests: check for idle only for raid type


