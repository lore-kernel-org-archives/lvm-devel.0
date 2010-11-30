From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Nov 2010 22:28:07 -0000
Subject: LVM2/lib/activate dev_manager.c dev_manager.h
Message-ID: <20101130222807.10187.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-30 22:28:06

Modified files:
	lib/activate   : dev_manager.c dev_manager.h 

Log message:
	Remove check for lv is NULL
	
	'lv' is deferenced in the begining of the function so any check
	later is not helpful.
	
	Parameters for dev_manager_transien() are marked as nonnull.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.206&r2=1.207
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/lib/activate/dev_manager.c	2010/11/30 11:53:31	1.206
+++ LVM2/lib/activate/dev_manager.c	2010/11/30 22:28:06	1.207
@@ -601,14 +601,13 @@
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length, &type,
 					  &params);
-		if (lv) {
-			if (!(segh = dm_list_next(&lv->segments, segh))) {
-				log_error("Number of segments in active LV %s "
-					  "does not match metadata", lv->name);
-				goto out;
-			}
-			seg = dm_list_item(segh, struct lv_segment);
+
+		if (!(segh = dm_list_next(&lv->segments, segh))) {
+		    log_error("Number of segments in active LV %s "
+			      "does not match metadata", lv->name);
+		    goto out;
 		}
+		seg = dm_list_item(segh, struct lv_segment);
 
 		if (!type || !params)
 			continue;
@@ -619,7 +618,7 @@
 
 	} while (next);
 
-	if (lv && (segh = dm_list_next(&lv->segments, segh))) {
+	if ((segh = dm_list_next(&lv->segments, segh))) {
 		log_error("Number of segments in active LV %s does not "
 			  "match metadata", lv->name);
 		goto out;
--- LVM2/lib/activate/dev_manager.h	2010/11/30 11:53:31	1.35
+++ LVM2/lib/activate/dev_manager.h	2010/11/30 22:28:06	1.36
@@ -56,7 +56,7 @@
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
 			unsigned origin_only, int *flush_required);
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
-int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv);
+int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv) __attribute__((nonnull(1, 2)));
 
 int dev_manager_mknodes(const struct logical_volume *lv);
 


