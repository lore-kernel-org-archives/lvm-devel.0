From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:27 +0000 (UTC)
Subject: master - debug: monitor_dev_for_events stack trace
Message-ID: <20140924085727.9767760E42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7531a9169e9b9fdb740dbd7c805ade55fb3a440c
Commit:        7531a9169e9b9fdb740dbd7c805ade55fb3a440c
Parent:        03aeb867621ee5facbc01b95629af29b28c559a5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 24 09:58:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:48 2014 +0200

debug: monitor_dev_for_events stack trace

---
 lib/activate/activate.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c5ff84d..3e4b04b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1657,8 +1657,11 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	 * In case of a snapshot device, we monitor lv->snapshot->lv,
 	 * not the actual LV itself.
 	 */
-	if (lv_is_cow(lv) && (laopts->no_merging || !lv_is_merging_cow(lv)))
-		return monitor_dev_for_events(cmd, lv->snapshot->lv, NULL, monitor);
+	if (lv_is_cow(lv) && (laopts->no_merging || !lv_is_merging_cow(lv))) {
+		if (!(r = monitor_dev_for_events(cmd, lv->snapshot->lv, NULL, monitor)))
+			stack;
+		return r;
+	}
 
 	/*
 	 * In case this LV is a snapshot origin, we instead monitor
@@ -1668,8 +1671,10 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	if (!laopts->origin_only && lv_is_origin(lv))
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!monitor_dev_for_events(cmd, dm_list_struct_base(snh,
-				    struct lv_segment, origin_list)->cow, NULL, monitor))
+				struct lv_segment, origin_list)->cow, NULL, monitor)) {
+				stack;
 				r = 0;
+			}
 
 	/*
 	 * If the volume is mirrored and its log is also mirrored, monitor
@@ -1678,8 +1683,10 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	if ((seg = first_seg(lv)) != NULL && seg->log_lv != NULL &&
 	    (log_seg = first_seg(seg->log_lv)) != NULL &&
 	    seg_is_mirrored(log_seg))
-		if (!monitor_dev_for_events(cmd, seg->log_lv, NULL, monitor))
+		if (!monitor_dev_for_events(cmd, seg->log_lv, NULL, monitor)) {
+			stack;
 			r = 0;
+		}
 
 	dm_list_iterate_items(seg, &lv->segments) {
 		/* Recurse for AREA_LV */
@@ -1702,12 +1709,16 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		 */
 		if (seg->pool_lv &&
 		    !monitor_dev_for_events(cmd, seg->pool_lv,
-					    (!monitor) ? laopts : NULL, monitor))
+					    (!monitor) ? laopts : NULL, monitor)) {
+			stack;
 			r = 0;
+		}
 
 		if (seg->metadata_lv &&
-		    !monitor_dev_for_events(cmd, seg->metadata_lv, NULL, monitor))
+		    !monitor_dev_for_events(cmd, seg->metadata_lv, NULL, monitor)) {
+			stack;
 			r = 0;
+		}
 
 		if (!seg_monitored(seg) ||
 		    (seg->status & PVMOVE) ||


