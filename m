From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Jul 2014 19:51:26 +0000 (UTC)
Subject: master - raid: Moved degraded activation code to raid_manip.
Message-ID: <20140722195126.D830B60DFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99e3c1301294fdd1cd8be25adb303e24e1260c76
Commit:        99e3c1301294fdd1cd8be25adb303e24e1260c76
Parent:        fe5b282a4a51bcc2780da9ef7ab298d97c45f3db
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 22 20:50:29 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 22 20:50:29 2014 +0100

raid: Moved degraded activation code to raid_manip.

Adjust some messages & fn names.
---
 lib/activate/activate.c          |  119 ++-----------------------------------
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/raid_manip.c        |  105 +++++++++++++++++++++++++++++++++
 tools/lvmcmdline.c               |    7 +-
 4 files changed, 117 insertions(+), 115 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index deb09e2..ebeaa79 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2203,112 +2203,6 @@ out:
 	return r;
 }
 
-/* FIXME Move this non-activation code elsewhere */
-static int _lv_raid_is_redundant(struct logical_volume *lv)
-{
-	struct lv_segment *raid_seg = first_seg(lv);
-	uint32_t copies;
-	uint32_t i, s, rebuilds_per_group = 0;
-	uint32_t failed_components = 0;
-
-	if (!(lv->status & PARTIAL_LV)) {
-		/*
-		 * Redundant, but this function shouldn't
-		 * be called in this case.
-		 */
-		log_error(INTERNAL_ERROR "%s is not a partial LV", lv->name);
-		return 1;
-	}
-
-	if (!lv_is_raid(lv))
-		return 0; /* Not RAID, not redundant */
-
-	if (!strcmp(raid_seg->segtype->name, "raid10")) {
-                /* FIXME: We only support 2-way mirrors in RAID10 currently */
-		copies = 2;
-                for (i = 0; i < raid_seg->area_count * copies; i++) {
-                        s = i % raid_seg->area_count;
-                        if (!(i % copies))
-                                rebuilds_per_group = 0;
-                        if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) ||
-                            (seg_metalv(raid_seg, s)->status & PARTIAL_LV) ||
-                            lv_is_virtual(seg_lv(raid_seg, s)) ||
-                            lv_is_virtual(seg_metalv(raid_seg, s)))
-                                rebuilds_per_group++;
-                        if (rebuilds_per_group >= copies) {
-				log_debug("An entire mirror group "
-					  "has failed in %s", lv->name);
-                                return 0; /* Not redundant */
-			}
-                }
-		return 1; /* Redundant */
-        }
-
-	for (s = 0; s < raid_seg->area_count; s++) {
-		if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) ||
-		    (seg_metalv(raid_seg, s)->status & PARTIAL_LV) ||
-		    lv_is_virtual(seg_lv(raid_seg, s)) ||
-		    lv_is_virtual(seg_metalv(raid_seg, s)))
-			failed_components++;
-	}
-        if (failed_components == raid_seg->area_count) {
-		log_debug("All components in %s have failed", lv->name);
-                return 0;
-        } else if (raid_seg->segtype->parity_devs &&
-                   (failed_components > raid_seg->segtype->parity_devs)) {
-                log_debug("More than %u components from (%s) %s/%s have failed",
-                          raid_seg->segtype->parity_devs,
-                          raid_seg->segtype->ops->name(raid_seg),
-                          lv->vg->name, lv->name);
-                return 0;
-        }
-
-	return 1;
-}
-
-static int _lv_is_not_degraded_capable(struct logical_volume *lv, void *data)
-{
-	int *not_capable = (int *)data;
-	uint32_t s;
-	struct lv_segment *seg;
-
-	if (!(lv->status & PARTIAL_LV))
-		return 1;
-
-	if (lv_is_raid(lv))
-		return _lv_raid_is_redundant(lv);
-
-	/* Ignore RAID sub-LVs. */
-	if (lv_is_raid_type(lv))
-		return 1;
-
-	dm_list_iterate_items(seg, &lv->segments)
-		for (s = 0; s < seg->area_count; s++)
-			if (seg_type(seg, s) != AREA_LV) {
-				log_debug("%s is not capable of degraded mode",
-					  lv->name);
-				*not_capable = 1;
-			}
-
-	return 1;
-}
-
-static int lv_is_degraded_capable(struct logical_volume *lv)
-{
-	int not_capable = 0;
-
-	if (!(lv->status & PARTIAL_LV))
-		return 1;
-
-	if (!_lv_is_not_degraded_capable(lv, &not_capable) || not_capable)
-		return 0;
-
-	if (!for_each_sub_lv(lv, _lv_is_not_degraded_capable, &not_capable))
-		log_error(INTERNAL_ERROR "for_each_sub_lv failure.");
-
-	return !not_capable;
-}
-
 static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 			struct lv_activate_opts *laopts, int filter,
 	                struct logical_volume *lv)
@@ -2330,19 +2224,20 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 	}
 
-	if ((!lv->vg->cmd->partial_activation) && (lv->status & PARTIAL_LV)) {
-		if (!lv_is_degraded_capable(lv)) {
+	if ((!lv->vg->cmd->partial_activation) && (lv->status & PARTIAL_LV) && lv_is_raid_type(lv)) {
+		if (!partial_raid_lv_supports_degraded_activation(lv)) {
 			log_error("Refusing activation of partial LV %s.  "
 				  "Use '--activationmode partial' to override.",
-				  lv->name);
+				  display_lvname(lv));
 			goto out;
-		} else if (!lv->vg->cmd->degraded_activation) {
+		}
+
+		if (!lv->vg->cmd->degraded_activation) {
 			log_error("Refusing activation of partial LV %s.  "
 				  "Try '--activationmode degraded'.",
-				  lv->name);
+				  display_lvname(lv));
 			goto out;
 		}
-		log_print_unless_silent("Attempting activation of partial RAID LV, %s.", lv->name);
 	}
 
 	if (lv_has_unknown_segments(lv)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 2b06718..9d7a653 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1038,6 +1038,7 @@ int lv_raid_reshape(struct logical_volume *lv,
 int lv_raid_replace(struct logical_volume *lv, struct dm_list *remove_pvs,
 		    struct dm_list *allocate_pvs);
 int lv_raid_remove_missing(struct logical_volume *lv);
+int partial_raid_lv_supports_degraded_activation(struct logical_volume *lv);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 6fead9a..ab30af9 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1938,3 +1938,108 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 
 	return 1;
 }
+
+/* Return 1 if a partial raid LV can be activated redundantly */
+static int _partial_raid_lv_is_redundant(struct logical_volume *lv)
+{
+	struct lv_segment *raid_seg = first_seg(lv);
+	uint32_t copies;
+	uint32_t i, s, rebuilds_per_group = 0;
+	uint32_t failed_components = 0;
+
+	if (!strcmp(raid_seg->segtype->name, "raid10")) {
+                /* FIXME: We only support 2-way mirrors in RAID10 currently */
+		copies = 2;
+                for (i = 0; i < raid_seg->area_count * copies; i++) {
+                        s = i % raid_seg->area_count;
+
+                        if (!(i % copies))
+                                rebuilds_per_group = 0;
+
+                        if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) ||
+                            (seg_metalv(raid_seg, s)->status & PARTIAL_LV) ||
+                            lv_is_virtual(seg_lv(raid_seg, s)) ||
+                            lv_is_virtual(seg_metalv(raid_seg, s)))
+                                rebuilds_per_group++;
+
+                        if (rebuilds_per_group >= copies) {
+				log_verbose("An entire mirror group has failed in %s",
+					    display_lvname(lv));
+                		return 0;	/* Insufficient redundancy to activate */
+			}
+                }
+
+		return 1; /* Redundant */
+        }
+
+	for (s = 0; s < raid_seg->area_count; s++) {
+		if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) ||
+		    (seg_metalv(raid_seg, s)->status & PARTIAL_LV) ||
+		    lv_is_virtual(seg_lv(raid_seg, s)) ||
+		    lv_is_virtual(seg_metalv(raid_seg, s)))
+			failed_components++;
+	}
+
+        if (failed_components == raid_seg->area_count) {
+		log_verbose("All components of raid LV %s have failed",
+			    display_lvname(lv));
+                return 0;	/* Insufficient redundancy to activate */
+        } else if (raid_seg->segtype->parity_devs &&
+                   (failed_components > raid_seg->segtype->parity_devs)) {
+                log_verbose("More than %u components from %s %s have failed",
+			    raid_seg->segtype->parity_devs,
+                          raid_seg->segtype->ops->name(raid_seg),
+                          display_lvname(lv));
+                return 0;	/* Insufficient redundancy to activate */
+        }
+
+	return 1;
+}
+
+/* Sets *data to 1 if the LV cannot be activated without data loss */
+static int _lv_may_be_activated_in_degraded_mode(struct logical_volume *lv, void *data)
+{
+	int *not_capable = (int *)data;
+	uint32_t s;
+	struct lv_segment *seg;
+
+	if (*not_capable)
+		return 1;	/* No further checks needed */
+
+	if (!(lv->status & PARTIAL_LV))
+		return 1;
+
+	if (lv_is_raid(lv)) {
+		*not_capable = !_partial_raid_lv_is_redundant(lv);
+		return 1;
+	}
+
+	/* Ignore RAID sub-LVs. */
+	if (lv_is_raid_type(lv))
+		return 1;
+
+	dm_list_iterate_items(seg, &lv->segments)
+		for (s = 0; s < seg->area_count; s++)
+			if (seg_type(seg, s) != AREA_LV) {
+				log_verbose("%s contains a segment incapable of degraded activation",
+					    display_lvname(lv));
+				*not_capable = 1;
+			}
+
+	return 1;
+}
+
+int partial_raid_lv_supports_degraded_activation(struct logical_volume *lv)
+{
+	int not_capable = 0;
+
+	if (!_lv_may_be_activated_in_degraded_mode(lv, &not_capable) || not_capable)
+		return 0;
+
+	if (!for_each_sub_lv(lv, _lv_may_be_activated_in_degraded_mode, &not_capable)) {
+		log_error(INTERNAL_ERROR "for_each_sub_lv failure.");
+		return 0;
+	}
+
+	return !not_capable;
+}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index a9769f2..4654978 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -980,10 +980,9 @@ static int _get_settings(struct cmd_context *cmd)
 	if (!strcmp(activation_mode, "partial")) {
 		cmd->partial_activation = 1;
 		log_warn("PARTIAL MODE. Incomplete logical volumes will be processed.");
-	} else if (!strcmp(activation_mode, "degraded")) {
+	} else if (!strcmp(activation_mode, "degraded"))
 		cmd->degraded_activation = 1;
-		log_verbose("DEGRADED MODE. Incomplete RAID LVs will be processed.");
-	} else if (strcmp(activation_mode, "complete")) {
+	else if (strcmp(activation_mode, "complete")) {
 		log_error("Invalid activation mode given.");
 		return EINVALID_CMD_LINE;
 	}
@@ -1339,6 +1338,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if ((ret = _get_settings(cmd)))
 		goto_out;
 	_apply_settings(cmd);
+	if (cmd->degraded_activation)
+		log_verbose("DEGRADED MODE. Incomplete RAID LVs will be processed.");
 
 	if (!get_activation_monitoring_mode(cmd, &monitoring))
 		goto_out;


