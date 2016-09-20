From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 20 Sep 2016 01:32:51 +0000 (UTC)
Subject: master - snapshots: Fix monitoring to use cow not internal LV.
Message-ID: <20160920013251.2653C603AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=414d39085c3f248601bec4cea6ce508acfa59283
Commit:        414d39085c3f248601bec4cea6ce508acfa59283
Parent:        ed37b4a62669e0e511941984c52544b3ae87589d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Sep 20 02:30:58 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Sep 20 02:30:58 2016 +0100

snapshots: Fix monitoring to use cow not internal LV.

---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ebb9c8c..924d7c5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Always specify snapshot cow LV for monitoring not internal LV. (2.02.165)
   Fix lvchange --discard|--zero for active thin-pool.
   Enforce 4MiB or 25% metadata free space for thin pool operations.
   Fix lock-holder device for thin pool with inactive thin volumes.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 69d40a0..5550955 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1774,7 +1774,8 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	/*
 	 * In case this LV is a snapshot origin, we instead monitor
 	 * each of its respective snapshots.  The origin itself may
-	 * also need to be monitored if it is a mirror, for example.
+	 * also need to be monitored if it is a mirror, for example,
+	 * so fall through to process it afterwards.
 	 */
 	if (!laopts->origin_only && lv_is_origin(lv))
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
@@ -1835,7 +1836,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 
 		if (!monitor)
 			/* When unmonitoring, obtain existing dso being used. */
-			monitored = _device_registered_with_dmeventd(cmd, seg->lv, &pending, &dso);
+			monitored = _device_registered_with_dmeventd(cmd, seg_is_snapshot(seg) ? seg->cow : seg->lv, &pending, &dso);
 		else
 			monitored = seg->segtype->ops->target_monitored(seg, &pending);
 
@@ -1870,7 +1871,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 			continue;
 
 		if (new_unmonitor) {
-			if (!target_register_events(cmd, dso, lv, 0, 0, 10)) {
+			if (!target_register_events(cmd, dso, seg_is_snapshot(seg) ? seg->cow : lv, 0, 0, 10)) {
 				log_error("%s: segment unmonitoring failed.",
 					  display_lvname(lv));
  


