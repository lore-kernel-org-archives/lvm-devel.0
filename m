From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 22 Jan 2010 15:40:33 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20100122154033.29385.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-22 15:40:32

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Eliminate extra ioctls just to check open_count in _add_new_lv_to_dtree.
	
	DM >= 4.7.0 always returns open_count so just use the associated nodes'
	existing info.
	
	Introduce _cached_info() to get an LV's cached info.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1403&r2=1.1404
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.176&r2=1.177

--- LVM2/WHATS_NEW	2010/01/22 14:33:33	1.1403
+++ LVM2/WHATS_NEW	2010/01/22 15:40:31	1.1404
@@ -1,5 +1,6 @@
 Version 2.02.60
 ===================================
+  Eliminate extra ioctls just to check open_count in _add_new_lv_to_dtree.
   Disable not thread-safe memory debugging if dmeventd is configured.
   Fix first log message prefix in syslog for dmeventd plugins.
   Fix exported symbols names for dmeventd lvm2 wrapper plugin.
--- LVM2/lib/activate/dev_manager.c	2010/01/22 13:28:54	1.176
+++ LVM2/lib/activate/dev_manager.c	2010/01/22 15:40:32	1.177
@@ -249,6 +249,35 @@
 		     info, read_ahead);
 }
 
+static const struct dm_info *_cached_info(struct dm_pool *mem,
+					  const struct logical_volume *lv,
+					  struct dm_tree *dtree)
+{
+	const char *dlid;
+	struct dm_tree_node *dnode;
+	const struct dm_info *dinfo;
+
+	if (!(dlid = _build_dlid(mem, lv->lvid.s, NULL))) {
+		log_error("dlid build failed for %s", lv->name);
+		return NULL;
+	}
+
+	if (!(dnode = dm_tree_find_node_by_uuid(dtree, dlid))) {
+		log_error("failed to find tree node for %s", lv->name);
+		return NULL;
+	}
+
+	if (!(dinfo = dm_tree_node_get_info(dnode))) {
+		log_error("failed to get info from tree node for %s", lv->name);
+		return NULL;
+	}
+
+	if (!dinfo->exists)
+		return NULL;
+
+	return dinfo;
+}
+
 /* FIXME Interface must cope with multiple targets */
 static int _status_run(const char *name, const char *uuid,
 		       unsigned long long *s, unsigned long long *l,
@@ -1117,7 +1146,7 @@
 	struct lv_segment *seg;
 	struct lv_layer *lvlayer;
 	struct dm_tree_node *dnode;
-	struct dm_info dinfo;
+	const struct dm_info *dinfo;
 	char *name, *dlid, *lv_name;
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
@@ -1130,15 +1159,14 @@
 		/*
 		 * Clear merge attributes if merge isn't currently possible:
 		 * either origin or merging snapshot are open
-		 * - must refresh info's open_count, so using the tree's
-		 *   existing nodes' info isn't an option
-		 * - but use "snapshot-merge" if it is already being used
+		 * - but use "snapshot-merge" if it is already in use
+		 * - open_count is always retrieved (as of dm-ioctl 4.7.0)
+		 *   so just use the tree's existing nodes' info
 		 */
-		/* FIXME Avoid this - open_count is always returned by kernel now. */
-		if ((dev_manager_info(dm->mem, NULL, lv,
-				      0, 1, 0, &dinfo, NULL) && dinfo.open_count) ||
-		    (dev_manager_info(dm->mem, NULL, find_merging_cow(lv)->cow,
-				      0, 1, 0, &dinfo, NULL) && dinfo.open_count)) {
+		if (((dinfo = _cached_info(dm->mem, lv,
+					   dtree)) && dinfo->open_count) ||
+		    ((dinfo = _cached_info(dm->mem, find_merging_cow(lv)->cow,
+					   dtree)) && dinfo->open_count)) {
 			/* FIXME Is there anything simpler to check for instead? */
 			if (!_lv_has_target_type(dm, lv, NULL, "snapshot-merge"))
 				clear_snapshot_merge(lv);


