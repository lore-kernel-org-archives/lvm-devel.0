From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 23 Aug 2016 11:17:02 +0000 (UTC)
Subject: master - dmeventd: Simplify replacement unmonitor code.
Message-ID: <20160823111702.CBD5861AE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b975532433dcbcc01e3cc0ebe8c6165e2d6470f8
Commit:        b975532433dcbcc01e3cc0ebe8c6165e2d6470f8
Parent:        97ee5a1cd326cac4fa5642395d13ebbf13965970
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 23 12:16:39 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 23 12:16:39 2016 +0100

dmeventd: Simplify replacement unmonitor code.

---
 lib/activate/activate.c |   35 +++++++++++++----------------------
 1 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index de5deae..22e3afa 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1831,52 +1831,43 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		if (monitor) {
 			if (monitored)
 				log_verbose("%s already monitored.", display_lvname(lv));
-			else if (seg->segtype->ops->target_monitor_events)
+			else if (seg->segtype->ops->target_monitor_events) {
+				log_verbose("Monitoring %s%s", display_lvname(lv), test_mode() ? " [Test mode: skipping this]" : "");
 				monitor_fn = seg->segtype->ops->target_monitor_events;
+			}
 		} else {
 			if (!monitored)
 				log_verbose("%s already not monitored.", display_lvname(lv));
-			else if (*dso)
+			else if (*dso) {
 				/*
 				 * Divert unmonitor away from code that depends on the new segment
 				 * type instead of the existing one if it's changing.
 				 */
+				log_verbose("Not monitoring %s with %s%s", display_lvname(lv), dso, test_mode() ? " [Test mode: skipping this]" : "");
 				new_unmonitor = 1;
-			else if (seg->segtype->ops->target_unmonitor_events)
-				monitor_fn = seg->segtype->ops->target_unmonitor_events;
+			}
 		}
 
-		if (new_unmonitor) {
-			log_verbose("Not monitoring %s with %s%s", display_lvname(lv), dso, test_mode() ? " [Test mode: skipping this]" : "");
-
-			/* FIXME Test mode should really continue a bit further. */
-			if (test_mode())
-				return 1;
+		/* FIXME Test mode should really continue a bit further. */
+		if (test_mode())
+			continue;
 
+		if (new_unmonitor) {
 			if (!target_register_events(cmd, dso, lv, 0, 0, 0)) {
 				log_error("%s: segment unmonitoring failed.",
 					  display_lvname(lv));
  
 				return 0;
 			}
-
-		} else if (!monitor_fn)
-			continue;
-		else if (monitor_fn) {
-			log_verbose("%sonitoring %s%s", monitor ? "M" : "Not m", display_lvname(lv),
-				    test_mode() ? " [Test mode: skipping this]" : "");
-
-			/* FIXME Test mode should really continue a bit further. */
-			if (test_mode())
-				continue;
-
+		} else if (monitor_fn) {
 			/* FIXME specify events */
 			if (!monitor_fn(seg, 0)) {
 				log_error("%s: %s segment monitoring function failed.",
 					  display_lvname(lv), seg->segtype->name);
 				return 0;
 			}
-		}
+		} else
+			continue;
 
 		/* Check [un]monitor results */
 		/* Try a couple times if pending, but not forever... */


