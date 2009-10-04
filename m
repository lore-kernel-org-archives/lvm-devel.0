From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  4 Oct 2009 19:11:37 -0400
Subject: [PATCH 0/10]: Add implicit pvcreate support in vgcreate / vgextend.
Message-ID: <1254697907-16448-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patch set is a rebase and rewrite of the earlier implicit pvcreate
patchset.  These patches should address most, if not all, feedback to date,
and include updated tests.  Once these patches are in, a user should no
longer need pvcreate, except in rare recovery scenarios (usage of 
--uuid, --restorefile, and --physicalvolumesize are not supported with
vgcreate and vgextend).

Patches 1-7 are just refactoring of existing code and should not change
functionality.  Patch 8 changes the behavior of vgcreate and vgextend to
implicitly pvcreate if a device is not already initialized.  Patch 9
updates the man pages and patch 10 the nightly tests.

One issue that has yet to be addressed is PV vs VG metadatacopies.
A separate patch should address this soon after this patchset.

Applies cleanly and passes testsuite on the following commit:
commit 60ba4943ecb0cf6375de1d6711b4de9ea668d68b
Author: Zden?k Kabel?? <zkabelac@redhat.com>
Date:   Fri Oct 2 11:41:54 2009 +0000

    Update distclean target for rename clogd to cmirrord. (2.02.52)


