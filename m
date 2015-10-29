From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Oct 2015 11:39:41 +0000 (UTC)
Subject: master - thin: enable usage of kernel low_water_mark
Message-ID: <20151029113941.718B760E62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99237f0908d87592815f4bdf3c239e8a108e835c
Commit:        99237f0908d87592815f4bdf3c239e8a108e835c
Parent:        099466939e4d6bdbe4b105f6b052dee6fc99b9d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 29 11:58:06 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 29 12:14:20 2015 +0100

thin: enable usage of kernel low_water_mark

Now with correctly functioning dmeventd enable usage of
low_water_mark for faster reaction on pool's threshold.

When user select e.g. 80% as a threshold value,
dmeventd doesn't need to wait 10 seconds till monitoring
timer expires, but nearly instantly resizes thin-pool
to fit bellow threshold.
---
 WHATS_NEW       |    1 +
 lib/thin/thin.c |   14 +++++++++++++-
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 869e506..f453604 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Thin pool targets uses low_water_mark from profile.
   Dropping 'yet' from error of unsupported thick snapshot of snapshots.
   Do not support unpartitioned DASD devices with CDL formatted with pvcreate.
   For thins use flush for suspend only when volume size is reduced.
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 7bf7f4e..d042473 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -266,6 +266,8 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 	struct lvinfo info;
 	uint64_t transaction_id = 0;
 	unsigned attr;
+	uint64_t low_water_mark;
+	int threshold;
 
 	if (!_thin_target_present(cmd, NULL, &attr))
 		return_0;
@@ -294,10 +296,20 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 		return 0;
 	}
 
+	threshold = find_config_tree_int(seg->lv->vg->cmd,
+					 activation_thin_pool_autoextend_threshold_CFG,
+					 lv_config_profile(seg->lv));
+	if (threshold < 50)
+		threshold = 50;
+	if (threshold < 100)
+		low_water_mark = (len * threshold + 99) / 100;
+	else
+		low_water_mark = len;
+
 	if (!dm_tree_node_add_thin_pool_target(node, len,
 					       seg->transaction_id,
 					       metadata_dlid, pool_dlid,
-					       seg->chunk_size, seg->low_water_mark,
+					       seg->chunk_size, low_water_mark,
 					       seg->zero_new_blocks ? 0 : 1))
 		return_0;
 


