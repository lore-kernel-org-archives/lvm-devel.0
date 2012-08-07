From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 20:30:45 +0000 (UTC)
Subject: master - thin: tidy thin discard code
Message-ID: <20120807203045.53D333454@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a6bea990b01a583de830b90fee492823139b7ea
Commit:        3a6bea990b01a583de830b90fee492823139b7ea
Parent:        597590da7412485ccdcb71ca909fbc5f73ec2aa1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 20:40:19 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 20:40:19 2012 +0100

thin: tidy thin discard code

Always store discard setting in LV metadata.  (Note that lvcreate_params
doesn't yet use --discard to set the initial value.)
Remove undocumented env var LVM_THIN_VERSION_MIN that has no use on a
live system.
Change verbose 'feature not found' messages to debug.
Use discard_str for string value of discard.
---
 lib/thin/thin.c |   35 +++++++++++++----------------------
 1 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 27ce6f5..3e562ef 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -87,7 +87,7 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 {
 	const char *lv_name;
 	struct logical_volume *pool_data_lv, *pool_metadata_lv;
-	const char *discard = NULL;
+	const char *discard_str = NULL;
 
 	if (!dm_config_get_str(sn, "metadata", &lv_name))
 		return SEG_LOG_ERROR("Metadata must be a string in");
@@ -115,12 +115,12 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 		return SEG_LOG_ERROR("Could not read chunk_size");
 
 	if (dm_config_has_node(sn, "discard") &&
-	    !dm_config_get_str(sn, "discard", &discard))
+	    !dm_config_get_str(sn, "discard", &discard_str))
 		return SEG_LOG_ERROR("Could not read discard for");
 
-	if (!discard)
+	if (!discard_str)
 		seg->discard = THIN_DISCARD_PASSDOWN;
-	else if (!get_pool_discard(discard, &seg->discard))
+	else if (!get_pool_discard(discard_str, &seg->discard))
 		return SEG_LOG_ERROR("Discard option unsupported for");
 
 	if (dm_config_has_node(sn, "low_water_mark") &&
@@ -165,14 +165,12 @@ static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter
 
 	switch (seg->discard) {
 	case THIN_DISCARD_PASSDOWN:
-		/* nothing to do */
-		break;
 	case THIN_DISCARD_NO_PASSDOWN:
 	case THIN_DISCARD_IGNORE:
 		outf(f, "discard = \"%s\"", get_pool_discard_name(seg->discard));
 		break;
 	default:
-		log_error(INTERNAL_ERROR "Unexportable discard.");
+		log_error(INTERNAL_ERROR "Invalid discard value %d.", seg->discard);
 		return 0;
 	}
 
@@ -278,9 +276,9 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 					       seg->zero_new_blocks ? 0 : 1))
 		return_0;
 
-	if (seg->discard != THIN_DISCARD_PASSDOWN) {
+	if (seg->discard != THIN_DISCARD_PASSDOWN)
 		if (attr & THIN_FEATURE_DISCARD) {
-			/* FIXME: Check whether underlaying dev supports discard */
+			/* FIXME: Check whether underlying dev supports discard */
 			if (!dm_tree_node_set_thin_pool_discard(node,
 								seg->discard == THIN_DISCARD_IGNORE,
 								seg->discard == THIN_DISCARD_NO_PASSDOWN))
@@ -288,7 +286,6 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 		} else
 			log_warn_suppress(_no_discard++, "WARNING: Thin pool target does "
 					  "not support discard (needs kernel >= 3.4).");
-	}
 
 	/*
 	 * Add messages only for activation tree.
@@ -545,30 +542,24 @@ static int _thin_target_present(struct cmd_context *cmd,
 			log_error("Cannot read " THIN_MODULE " target version.");
 			return 0;
 		}
-		log_debug("Target " THIN_MODULE " has version %d:%d:%d.",
-			  maj, min, patchlevel);
-
-		/* For testing allow to override via shell variable */
-		if (getenv("LVM_THIN_VERSION_MIN"))
-			min = atoi(getenv("LVM_THIN_VERSION_MIN"));
 
 		if (maj >=1 && min >= 1)
 			_attrs |= THIN_FEATURE_DISCARD;
 		else
-			log_verbose("Target " THIN_MODULE
-				    " without discard support.");
+		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
+			log_debug("Target " THIN_MODULE " does not support discards.");
 
 		if (maj >=1 && min >= 1)
 			_attrs |= THIN_FEATURE_EXTERNAL_ORIGIN;
 		else
-			log_verbose("Target " THIN_MODULE
-				    " without external origin support.");
+		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
+			log_debug("Target " THIN_MODULE " does not support external origins.");
 #if 0
 		if (maj >=1 && min >= 1)
 			_attrs |= THIN_FEATURE_BLOCK_SIZE;
 		else
-			log_verbose("Target " THIN_MODULE
-				    " without non power of 2 block size.");
+		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
+			log_debug("Target " THIN_MODULE " does not support non power of 2 block sizes.");
 #endif
 		_checked = 1;
 	}


