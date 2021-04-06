From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:35 +0000 (GMT)
Subject: main - WHATS_NEW: updates
Message-ID: <20210406200735.5AD003857823@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9980ed9527e73d8396f8e1ce877837c0355ba8dc
Commit:        9980ed9527e73d8396f8e1ce877837c0355ba8dc
Parent:        79a168d119d31b99463a286dff8a42e25863895a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 6 21:20:18 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 22:02:31 2021 +0200

WHATS_NEW: updates

---
 WHATS_NEW    | 3 +++
 WHATS_NEW_DM | 1 +
 2 files changed, 4 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 83c94701a..c2676c820 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.03.12 - 
 ===================================
+  Improve signal handling with lvmpolld.
+  Signal handler can interrupt command also for SIGTERM.
+  Lvreduce --yes support.
   Add configure option --with/out-symvers for non-glibc builds.
   Report error when the filesystem is missing on fsadm resized volume.
   Handle better blockdev with --getsize64 support for fsadm.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 400e458b4..822ca14eb 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.177 - 
 ====================================
+  Fix symbol versioning build with -O2 -flto.
   Add dm_tree_node_add_thin_pool_target_v1 with crop_metadata support.
 
 Version 1.02.175 - 08th January 2021


