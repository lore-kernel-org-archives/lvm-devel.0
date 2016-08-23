From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 23 Aug 2016 10:31:46 +0000 (UTC)
Subject: master - dmeventd: Start merging back replacement unmonitor code.
Message-ID: <20160823103146.E423B605B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97ee5a1cd326cac4fa5642395d13ebbf13965970
Commit:        97ee5a1cd326cac4fa5642395d13ebbf13965970
Parent:        952e4133283ac4a593d0fa8daccdc55c907379de
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 23 11:30:34 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 23 11:30:34 2016 +0100

dmeventd: Start merging back replacement unmonitor code.

---
 lib/activate/activate.c |   86 ++++++++++++++++------------------------------
 1 files changed, 30 insertions(+), 56 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 908c411..de5deae 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1690,48 +1690,6 @@ int target_register_events(struct cmd_context *cmd, const char *dso, const struc
 
 #endif
 
-#ifdef DMEVENTD
-/* FIXME Restructure all this code so that unmonitoring works cleanly regardless of current target type. */
-static int _segment_independent_unmonitor(struct cmd_context *cmd, const struct logical_volume *lv, const char *dso)
-{
-	int i, pending = 0, monitored;
-	int r;
-
-	log_verbose("Not monitoring %s with %s%s", display_lvname(lv), dso, test_mode() ? " [Test mode: skipping this]" : "");
-
-	/* FIXME Test mode should really continue a bit further. */
-	if (test_mode())
-		return 1;
-
-	if (!target_register_events(cmd, dso, lv, 0, 0, 0)) {
-		log_error("%s: segment unmonitoring function failed.",
-			  display_lvname(lv));
-			 
-		return 0;
-	}
-
-	/* Check [un]monitor results */
-	/* Try a couple times if pending, but not forever... */
-	for (i = 0; i < 40; i++) {
-		pending = 0;
-		monitored = _device_registered_with_dmeventd(cmd, lv, &pending, NULL);
-		if (pending || monitored)
-			log_very_verbose("%s unmonitoring still pending: waiting...",
-					 display_lvname(lv));
-		else
-			break;
-		usleep(10000 * i);
-	}
-
-	r = !monitored;
-
-	if (!r && !error_message_produced())
-		log_error("Not monitoring %s failed.", display_lvname(lv));
-
-	return r;
-}
-#endif
-
 /*
  * Returns 0 if an attempt to (un)monitor the device failed.
  * Returns 1 otherwise.
@@ -1750,6 +1708,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	static const struct lv_activate_opts zlaopts = { 0 };
 	struct lvinfo info;
 	const char *dso;
+	int new_unmonitor;
 
 	if (!laopts)
 		laopts = &zlaopts;
@@ -1867,6 +1826,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		monitored = (pending) ? 0 : monitored;
 
 		monitor_fn = NULL;
+		new_unmonitor = 0;
 
 		if (monitor) {
 			if (monitored)
@@ -1878,30 +1838,44 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 				log_verbose("%s already not monitored.", display_lvname(lv));
 			else if (*dso)
 				/*
-				 * Divert unmonitor away from code that depends on the new segment 
+				 * Divert unmonitor away from code that depends on the new segment
 				 * type instead of the existing one if it's changing.
 				 */
-				return _segment_independent_unmonitor(cmd, lv, dso);
+				new_unmonitor = 1;
 			else if (seg->segtype->ops->target_unmonitor_events)
 				monitor_fn = seg->segtype->ops->target_unmonitor_events;
 		}
 
-		/* Do [un]monitor */
-		if (!monitor_fn)
-			continue;
+		if (new_unmonitor) {
+			log_verbose("Not monitoring %s with %s%s", display_lvname(lv), dso, test_mode() ? " [Test mode: skipping this]" : "");
 
-		log_verbose("%sonitoring %s%s", monitor ? "M" : "Not m", display_lvname(lv),
-			    test_mode() ? " [Test mode: skipping this]" : "");
+			/* FIXME Test mode should really continue a bit further. */
+			if (test_mode())
+				return 1;
+
+			if (!target_register_events(cmd, dso, lv, 0, 0, 0)) {
+				log_error("%s: segment unmonitoring failed.",
+					  display_lvname(lv));
+ 
+				return 0;
+			}
 
-		/* FIXME Test mode should really continue a bit further. */
-		if (test_mode())
+		} else if (!monitor_fn)
 			continue;
+		else if (monitor_fn) {
+			log_verbose("%sonitoring %s%s", monitor ? "M" : "Not m", display_lvname(lv),
+				    test_mode() ? " [Test mode: skipping this]" : "");
 
-		/* FIXME specify events */
-		if (!monitor_fn(seg, 0)) {
-			log_error("%s: %s segment monitoring function failed.",
-				  display_lvname(lv), seg->segtype->name);
-			return 0;
+			/* FIXME Test mode should really continue a bit further. */
+			if (test_mode())
+				continue;
+
+			/* FIXME specify events */
+			if (!monitor_fn(seg, 0)) {
+				log_error("%s: %s segment monitoring function failed.",
+					  display_lvname(lv), seg->segtype->name);
+				return 0;
+			}
 		}
 
 		/* Check [un]monitor results */


