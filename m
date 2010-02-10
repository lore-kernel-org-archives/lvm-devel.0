From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 10 Feb 2010 14:38:25 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20100210143825.9535.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-02-10 14:38:24

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Add 'fail_if_percent_unsupported' arg to _percent() and _percent_run().
	
	We unfortunately don't yet _know_, in dev_manager_snapshot_percent(), if
	a snapshot-merge target is active (activation is deferred if dev is
	open); so we can't short-circuit origin devices based purely on existing
	LVM LV attributes.
	
	Set 'fail_if_percent_unsupported' in dev_manager_snapshot_percent() for
	a merging origin LV, otherwise passing unsupported LV types to _percent
	will lead to a default successful return with percent_range as
	PERCENT_100.
	
	For a merging origin, PERCENT_100 will result in a polldaemon that runs
	infinitely (because completion is PERCENT_0).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.179&r2=1.180

--- LVM2/lib/activate/dev_manager.c	2010/02/08 23:28:06	1.179
+++ LVM2/lib/activate/dev_manager.c	2010/02/10 14:38:24	1.180
@@ -423,7 +423,7 @@
 			const char *target_type, int wait,
 			const struct logical_volume *lv, float *percent,
 			percent_range_t *overall_percent_range,
-			uint32_t *event_nr)
+			uint32_t *event_nr, int fail_if_percent_unsupported)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -516,10 +516,8 @@
 			/* above ->target_percent() was not executed! */
 			/* FIXME why return PERCENT_100 et. al. in this case? */
 			*overall_percent_range = PERCENT_100;
-			if (lv && lv_is_merging_origin(lv)) {
-				/* must fail in snapshot-merge case */
+			if (fail_if_percent_unsupported)
 				goto_out;
-			}
 		} else
 			*overall_percent_range = combined_percent_range;
 	}
@@ -535,20 +533,24 @@
 static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
 		    const char *target_type, int wait,
 		    const struct logical_volume *lv, float *percent,
-		    percent_range_t *overall_percent_range, uint32_t *event_nr)
+		    percent_range_t *overall_percent_range, uint32_t *event_nr,
+		    int fail_if_percent_unsupported)
 {
 	if (dlid && *dlid) {
 		if (_percent_run(dm, NULL, dlid, target_type, wait, lv, percent,
-				 overall_percent_range, event_nr))
+				 overall_percent_range, event_nr,
+				 fail_if_percent_unsupported))
 			return 1;
 		else if (_percent_run(dm, NULL, dlid + sizeof(UUID_PREFIX) - 1,
 				      target_type, wait, lv, percent,
-				      overall_percent_range, event_nr))
+				      overall_percent_range, event_nr,
+				      fail_if_percent_unsupported))
 			return 1;
 	}
 
 	if (name && _percent_run(dm, name, NULL, target_type, wait, lv, percent,
-				 overall_percent_range, event_nr))
+				 overall_percent_range, event_nr,
+				 fail_if_percent_unsupported))
 		return 1;
 
 	return 0;
@@ -607,6 +609,22 @@
 {
 	char *name;
 	const char *dlid;
+	int fail_if_percent_unsupported = 0;
+
+	if (lv_is_merging_origin(lv)) {
+		/*
+		 * Set 'fail_if_percent_unsupported', otherwise passing
+		 * unsupported LV types to _percent will lead to a default
+		 * successful return with percent_range as PERCENT_100.
+		 * - For a merging origin, this will result in a polldaemon
+		 *   that runs infinitely (because completion is PERCENT_0)
+		 * - We unfortunately don't yet _know_ if a snapshot-merge
+		 *   target is active (activation is deferred if dev is open);
+		 *   so we can't short-circuit origin devices based purely on
+		 *   existing LVM LV attributes.
+		 */
+		fail_if_percent_unsupported = 1;
+	}
 
 	/*
 	 * Build a name for the top layer.
@@ -621,8 +639,8 @@
 	 * Try and get some info on this device.
 	 */
 	log_debug("Getting device status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "snapshot", 0, lv, percent,
-		       percent_range, NULL)))
+	if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
+		       percent_range, NULL, fail_if_percent_unsupported)))
 		return_0;
 
 	/* FIXME dm_pool_free ? */
@@ -657,7 +675,7 @@
 
 	log_debug("Getting device mirror status percentage for %s", name);
 	if (!(_percent(dm, name, dlid, "mirror", wait, lv, percent,
-		       percent_range, event_nr)))
+		       percent_range, event_nr, 0)))
 		return_0;
 
 	return 1;


