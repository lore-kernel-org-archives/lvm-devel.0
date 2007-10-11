From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Oct 2007 18:51:22 -0000
Subject: LVM2 lib/format1/import-export.c lib/metadata/ ...
Message-ID: <20071011185122.10151.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-10-11 18:51:22

Modified files:
	lib/format1    : import-export.c 
	lib/metadata   : metadata-exported.h snapshot_manip.c 
	lib/snapshot   : snapshot.c 
	tools          : lvconvert.c lvcreate.c 

Log message:
	Non-functional change - refactor vg_add_snapshot fid parameter.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151

--- LVM2/lib/format1/import-export.c	2007/08/22 14:38:16	1.86
+++ LVM2/lib/format1/import-export.c	2007/10/11 18:51:21	1.87
@@ -644,7 +644,7 @@
 				continue;
 
 			/* insert the snapshot */
-			if (!vg_add_snapshot(vg->fid, NULL, org, cow, NULL,
+			if (!vg_add_snapshot(vg, NULL, org, cow, NULL,
 					     org->le_count, 
 					     lvd->lv_chunk_size)) {
 				log_err("Couldn't add snapshot.");
--- LVM2/lib/metadata/metadata-exported.h	2007/09/24 21:30:00	1.16
+++ LVM2/lib/metadata/metadata-exported.h	2007/10/11 18:51:21	1.17
@@ -412,7 +412,7 @@
 /* Given a cow LV, return its origin */
 struct logical_volume *origin_from_cow(const struct logical_volume *lv);
 
-int vg_add_snapshot(struct format_instance *fid, const char *name,
+int vg_add_snapshot(struct volume_group *vg, const char *name,
 		    struct logical_volume *origin, struct logical_volume *cow,
 		    union lvid *lvid, uint32_t extent_count,
 		    uint32_t chunk_size);
--- LVM2/lib/metadata/snapshot_manip.c	2007/08/20 20:55:26	1.25
+++ LVM2/lib/metadata/snapshot_manip.c	2007/10/11 18:51:21	1.26
@@ -48,11 +48,12 @@
 	return lv->snapshot->origin;
 }
 
-int vg_add_snapshot(struct format_instance *fid, const char *name,
+int vg_add_snapshot(struct volume_group *vg, const char *name,
 		    struct logical_volume *origin,
 		    struct logical_volume *cow, union lvid *lvid,
 		    uint32_t extent_count, uint32_t chunk_size)
 {
+	struct format_instance *fid = vg->fid;
 	struct logical_volume *snap;
 	struct lv_segment *seg;
 
--- LVM2/lib/snapshot/snapshot.c	2007/08/22 14:38:18	1.22
+++ LVM2/lib/snapshot/snapshot.c	2007/10/11 18:51:21	1.23
@@ -69,7 +69,7 @@
 		return 0;
 	}
 
-	if (!vg_add_snapshot(seg->lv->vg->fid, seg->lv->name, org, cow,
+	if (!vg_add_snapshot(seg->lv->vg, seg->lv->name, org, cow,
 			     &seg->lv->lvid, seg->len, chunk_size)) {
 		stack;
 		return 0;
--- LVM2/tools/lvconvert.c	2007/08/30 19:34:19	1.40
+++ LVM2/tools/lvconvert.c	2007/10/11 18:51:21	1.41
@@ -515,7 +515,7 @@
 		return 0;
 	}
 
-	if (!vg_add_snapshot(lv->vg->fid, NULL, org, lv, NULL, org->le_count,
+	if (!vg_add_snapshot(lv->vg, NULL, org, lv, NULL, org->le_count,
 			     lp->chunk_size)) {
 		log_error("Couldn't create snapshot.");
 		return 0;
--- LVM2/tools/lvcreate.c	2007/10/01 15:01:26	1.150
+++ LVM2/tools/lvcreate.c	2007/10/11 18:51:21	1.151
@@ -853,7 +853,7 @@
 
 		/* cow LV remains active and becomes snapshot LV */
 
-		if (!vg_add_snapshot(vg->fid, NULL, org, lv, NULL,
+		if (!vg_add_snapshot(vg, NULL, org, lv, NULL,
 				     org->le_count, lp->chunk_size)) {
 			log_err("Couldn't create snapshot.");
 			return 0;


