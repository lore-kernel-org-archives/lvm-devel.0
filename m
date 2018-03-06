From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:45:42 -0500
Subject: master - raid: fix error path for lv_raid_data_offset
Message-ID: <201803061445.w26Ejgnm026605@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce199db848e663ffa040015106725553eafb1c98
Commit:        ce199db848e663ffa040015106725553eafb1c98
Parent:        9be086fbeef0a24fc6f441dec29ee2385bca0280
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 2 15:49:12 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:36:11 2018 +0100

raid: fix error path for lv_raid_data_offset

Avoid using allocated status on error path.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 46f66b0..52cf4bc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Fix memleak on error path when obtaining lv_raid_data_offset.
   Fix compatibility size test of extended external origin.
   Add external_origin visiting in for_each_sub_lv().
   Ensure cluster commands drop their device cache before locking VG.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 3052f31..f5e9ef9 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1006,8 +1006,10 @@ int lv_raid_data_offset(const struct logical_volume *lv, uint64_t *data_offset)
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
-	if (!(r = dev_manager_raid_status(dm, lv, &status)))
-		stack;
+	if (!(r = dev_manager_raid_status(dm, lv, &status))) {
+		dev_manager_destroy(dm);
+		return_0;
+	}
 
 	*data_offset = status->data_offset;
 


