From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Feb 2018 16:20:47 -0500
Subject: master - activation: cleanup error to warning
Message-ID: <201802122120.w1CLKl3A023739@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6dff5dc653a6f31c2e995beb1c5ca5c58e83515e
Commit:        6dff5dc653a6f31c2e995beb1c5ca5c58e83515e
Parent:        d90a6478026dc2810947d552d6165ec7f0534894
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 12 16:15:35 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 12 22:15:03 2018 +0100

activation: cleanup error to warning

Since for the code it's not fatal to fail on monitoring,
issue correct warning message instead of error.
---
 lib/activate/activate.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6a4bc32..d8e1ccd 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1955,9 +1955,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 				continue;
 			if (!monitor_dev_for_events(cmd, seg_lv(seg, s), NULL,
 						    monitor)) {
-				log_error("Failed to %smonitor %s",
-					  monitor ? "" : "un",
-					  display_lvname(seg_lv(seg, s)));
+				stack;
 				r = 0;
 			}
 		}
@@ -2040,16 +2038,15 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 
 		if (new_unmonitor) {
 			if (!target_register_events(cmd, dso, seg_is_snapshot(seg) ? seg->cow : lv, 0, 0, 10)) {
-				log_error("%s: segment unmonitoring failed.",
-					  display_lvname(lv));
- 
+				log_warn("WARNING: %s: segment unmonitoring failed.",
+					 display_lvname(lv));
 				return 0;
 			}
 		} else if (monitor_fn) {
 			/* FIXME specify events */
 			if (!monitor_fn(seg, 0)) {
-				log_error("%s: %s segment monitoring function failed.",
-					  display_lvname(lv), lvseg_name(seg));
+				log_warn("WARNING: %s: %s segment monitoring function failed.",
+					 display_lvname(lv), lvseg_name(seg));
 				return 0;
 			}
 		} else
@@ -2076,8 +2073,8 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	}
 
 	if (!r && !error_message_produced())
-		log_error("%sonitoring %s failed.", monitor ? "M" : "Not m",
-			  display_lvname(lv));
+		log_warn("WARNING: %sonitoring %s failed.", monitor ? "M" : "Not m",
+			 display_lvname(lv));
 	return r;
 #else
 	return 1;


