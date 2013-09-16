From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 16 Sep 2013 20:39:17 +0000 (UTC)
Subject: master - WHATS_NEW: Better description for commit 82228ac
Message-ID: <20130916203917.0BEF460A57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1bcb21e02a33a03795c2e35bd4d16ea67107c5d
Commit:        d1bcb21e02a33a03795c2e35bd4d16ea67107c5d
Parent:        ce9a5cc25712907f05aa780d53d727b16f5dfd7c
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Sep 16 15:37:48 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Sep 16 15:37:48 2013 -0500

WHATS_NEW: Better description for commit 82228ac

More correct description of changes made to disallow thin+mirror.
---
 WHATS_NEW |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 45e0050..29fb822 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -6,7 +6,8 @@ Version 2.02.101 -
   Add man page entries for lvmdump's -u and -l options.
   Fix lvm2app segfault while using lvm_list_pvs_free fn if there are no PVs.
   Improve of clvmd singlenode locking simulation.
-  Disallow thinpools on mirror logical volumes.
+  lvconvert no longer converts LVs of "mirror" segment type to thinpool.
+  lvconvert no longer converts thinpool sub-LVs to "mirror" segment type.
   Direct udev to use 3min timeout for LVM devices. Recent udev has default 30s.
   Do not scan multipath or RAID components and avoid incorrect autoactivation.
   Fix MD/loop udev handling to fire autoactivation after setup or coldplug only.


