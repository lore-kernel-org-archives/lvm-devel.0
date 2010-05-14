From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 14 May 2010 15:19:45 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20100514151945.10315.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-05-14 15:19:43

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c mirror.c 

Log message:
	Disallow toggling the cluster attribute of a volume group if there
	are active mirrors or snapshots.
	
	We don't have the mechanisms in place to change the device-mapper
	tables for those targets that have behavioral differences between
	cluster and single machine instances.  Allowing users to change
	the attribute but not changing the target's behavior can lead to
	data corruption.
	
	The following bugs are fixed/avoided by this patch:
	235123 - vgchange -c [ny] do not change target types when necessary
	289331 - RFE: switching from cluster domain to local domain needs to deactivate volume somehow
	289541 - when changing from local to cluster, volumes can not appear to be deactivated

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1558&r2=1.1559
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.143&r2=1.144
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.338&r2=1.339
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117

--- LVM2/WHATS_NEW	2010/05/14 11:33:20	1.1558
+++ LVM2/WHATS_NEW	2010/05/14 15:19:42	1.1559
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Disallow cluster attr toggling if there are active mirrors or snapshots.
   Use /bin/bash for scripts with bashisms.
   Skip internal lvm devices in scan if ignore suspended devices is requested.
   Do not merge old device cache after we run full scan. (2.02.56)
--- LVM2/lib/metadata/metadata-exported.h	2010/04/23 19:27:10	1.143
+++ LVM2/lib/metadata/metadata-exported.h	2010/05/14 15:19:43	1.144
@@ -691,6 +691,7 @@
 
 int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
+int lv_is_mirrored(const struct logical_volume *lv);
 uint32_t lv_mirror_count(const struct logical_volume *lv);
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
                                     uint32_t region_size);
--- LVM2/lib/metadata/metadata.c	2010/04/23 19:27:10	1.338
+++ LVM2/lib/metadata/metadata.c	2010/05/14 15:19:43	1.339
@@ -1208,8 +1208,19 @@
 int vg_set_clustered(struct volume_group *vg, int clustered)
 {
 	struct lv_list *lvl;
-	if (clustered) {
-		dm_list_iterate_items(lvl, &vg->lvs) {
+
+	/*
+	 * We do not currently support switching the cluster attribute
+	 * on active mirrors or snapshots.
+	 */
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lv_is_mirrored(lvl->lv) && lv_is_active(lvl->lv)) {
+			log_error("Mirror logical volumes must be inactive "
+				  "when changing the cluster attribute.");
+			return 0;
+		}
+
+		if (clustered) {
 			if (lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) {
 				log_error("Volume group %s contains snapshots "
 					  "that are not yet supported.",
@@ -1217,6 +1228,13 @@
 				return 0;
 			}
 		}
+
+		if ((lv_is_origin(lvl->lv) || lv_is_cow(lvl->lv)) &&
+		    lv_is_active(lvl->lv)) {
+			log_error("Snapshot logical volumes must be inactive "
+				  "when changing the cluster attribute.");
+			return 0;
+		}
 	}
 
 	if (clustered)
--- LVM2/lib/metadata/mirror.c	2010/04/27 15:26:59	1.116
+++ LVM2/lib/metadata/mirror.c	2010/05/14 15:19:43	1.117
@@ -72,6 +72,14 @@
 	return NULL;
 }
 
+int lv_is_mirrored(const struct logical_volume *lv)
+{
+	if (lv->status & MIRRORED)
+		return 1;
+
+	return 0;
+}
+
 /*
  * Returns the number of mirrors of the LV
  */


