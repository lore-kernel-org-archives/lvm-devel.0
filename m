From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 23 Aug 2016 01:27:18 +0000 (UTC)
Subject: master - dmeventd: Fix unmonitoring when segtype changes.
Message-ID: <20160823012718.D550960D66@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=952e4133283ac4a593d0fa8daccdc55c907379de
Commit:        952e4133283ac4a593d0fa8daccdc55c907379de
Parent:        7646741ec67845f47b77eb647ef0fedc78d6b92c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 23 02:24:30 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 23 02:26:14 2016 +0100

dmeventd: Fix unmonitoring when segtype changes.

When the segment type is being changed, unmonitoring an LV requires
the existing dso to be specified as a parameter, not the new one.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   90 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 89 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0b23018..fdf63e4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Fix dmeventd unmonitoring when segment type (and dso) changes.
   Don't allow lvconvert --repair on raid0 devices or attempt to monitor them.
   No longer adjust incorrect number of raid stripes supplied to lvcreate.
   Move lcm and gcd to lib/misc.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index d4c297e..908c411 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1548,7 +1548,7 @@ static struct dm_event_handler *_create_dm_event_handler(struct cmd_context *cmd
 	if (dm_event_handler_set_dmeventd_path(dmevh, find_config_tree_str(cmd, dmeventd_executable_CFG, NULL)))
 		goto_bad;
 
-	if (dm_event_handler_set_dso(dmevh, dso))
+	if (dso && dm_event_handler_set_dso(dmevh, dso))
 		goto_bad;
 
 	if (dm_event_handler_set_uuid(dmevh, dmuuid))
@@ -1592,6 +1592,39 @@ static char *_build_target_uuid(struct cmd_context *cmd, const struct logical_vo
 	return build_dm_uuid(cmd->mem, lv, layer);
 }
 
+static int _device_registered_with_dmeventd(struct cmd_context *cmd, const struct logical_volume *lv, int *pending, const char **dso)
+{
+	char *uuid;
+	enum dm_event_mask evmask = 0;
+	struct dm_event_handler *dmevh;
+
+	*pending = 0;
+
+	if (!(uuid = _build_target_uuid(cmd, lv)))
+		return_0;
+
+	if (!(dmevh = _create_dm_event_handler(cmd, uuid, NULL, 0, DM_EVENT_ALL_ERRORS)))
+		return_0;
+
+	if (dm_event_get_registered_device(dmevh, 0)) {
+		dm_event_handler_destroy(dmevh);
+		return 0;
+	}
+
+	evmask = dm_event_handler_get_event_mask(dmevh);
+	if (evmask & DM_EVENT_REGISTRATION_PENDING) {
+		*pending = 1;
+		evmask &= ~DM_EVENT_REGISTRATION_PENDING;
+	}
+
+	if (dso && (*dso = dm_event_handler_get_dso(dmevh)) && !(*dso = dm_pool_strdup(cmd->mem, *dso)))
+		log_error("Failed to duplicate dso name.");
+
+	dm_event_handler_destroy(dmevh);
+
+	return evmask;
+}
+
 int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
 				    const struct logical_volume *lv, int *pending)
 {
@@ -1657,6 +1690,48 @@ int target_register_events(struct cmd_context *cmd, const char *dso, const struc
 
 #endif
 
+#ifdef DMEVENTD
+/* FIXME Restructure all this code so that unmonitoring works cleanly regardless of current target type. */
+static int _segment_independent_unmonitor(struct cmd_context *cmd, const struct logical_volume *lv, const char *dso)
+{
+	int i, pending = 0, monitored;
+	int r;
+
+	log_verbose("Not monitoring %s with %s%s", display_lvname(lv), dso, test_mode() ? " [Test mode: skipping this]" : "");
+
+	/* FIXME Test mode should really continue a bit further. */
+	if (test_mode())
+		return 1;
+
+	if (!target_register_events(cmd, dso, lv, 0, 0, 0)) {
+		log_error("%s: segment unmonitoring function failed.",
+			  display_lvname(lv));
+			 
+		return 0;
+	}
+
+	/* Check [un]monitor results */
+	/* Try a couple times if pending, but not forever... */
+	for (i = 0; i < 40; i++) {
+		pending = 0;
+		monitored = _device_registered_with_dmeventd(cmd, lv, &pending, NULL);
+		if (pending || monitored)
+			log_very_verbose("%s unmonitoring still pending: waiting...",
+					 display_lvname(lv));
+		else
+			break;
+		usleep(10000 * i);
+	}
+
+	r = !monitored;
+
+	if (!r && !error_message_produced())
+		log_error("Not monitoring %s failed.", display_lvname(lv));
+
+	return r;
+}
+#endif
+
 /*
  * Returns 0 if an attempt to (un)monitor the device failed.
  * Returns 1 otherwise.
@@ -1674,6 +1749,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	uint32_t s;
 	static const struct lv_activate_opts zlaopts = { 0 };
 	struct lvinfo info;
+	const char *dso;
 
 	if (!laopts)
 		laopts = &zlaopts;
@@ -1781,7 +1857,11 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		    !seg->segtype->ops->target_monitored) /* doesn't support registration */
 			continue;
 
-		monitored = seg->segtype->ops->target_monitored(seg, &pending);
+		if (!monitor)
+			/* When unmonitoring, obtain existing dso being used. */
+			monitored = _device_registered_with_dmeventd(cmd, seg->lv, &pending, &dso);
+		else
+			monitored = seg->segtype->ops->target_monitored(seg, &pending);
 
 		/* FIXME: We should really try again if pending */
 		monitored = (pending) ? 0 : monitored;
@@ -1796,6 +1876,12 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		} else {
 			if (!monitored)
 				log_verbose("%s already not monitored.", display_lvname(lv));
+			else if (*dso)
+				/*
+				 * Divert unmonitor away from code that depends on the new segment 
+				 * type instead of the existing one if it's changing.
+				 */
+				return _segment_independent_unmonitor(cmd, lv, dso);
 			else if (seg->segtype->ops->target_unmonitor_events)
 				monitor_fn = seg->segtype->ops->target_unmonitor_events;
 		}


