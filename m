From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Nov 2007 20:40:08 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/disk-rep.c lib/fo ...
Message-ID: <20071102204008.3570.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-02 20:40:05

Modified files:
	.              : WHATS_NEW 
	lib/format1    : disk-rep.c import-export.c 
	lib/metadata   : metadata-exported.h metadata.c pv_manip.c 
	                 snapshot_manip.c 
	lib/snapshot   : snapshot.c 
	tools          : lvconvert.c lvcreate.c lvresize.c pvchange.c 
	                 pvcreate.c pvdisplay.c pvremove.c reporter.c 
	                 toollib.c toollib.h vgcfgrestore.c vgcreate.c 
	                 vgextend.c vgremove.c vgrename.c vgsplit.c 

Log message:
	Fix orphan-related locking in pvdisplay and pvs.
	Fix missing VG unlocks in some pvchange error paths.
	Add some missing validation of VG names.
	Rename validate_vg_name() to validate_new_vg_name().
	Change orphan lock to VG_ORPHANS.
	Change format1 to use ORPHAN as orphan VG name.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.724&r2=1.725
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2007/11/02 14:54:40	1.724
+++ LVM2/WHATS_NEW	2007/11/02 20:40:04	1.725
@@ -1,7 +1,13 @@
 Version 2.02.29 -
 ==================================
+  Fix orphan-related locking in pvdisplay and pvs.
+  Fix missing VG unlocks in some pvchange error paths.
+  Add some missing validation of VG names.
+  Rename validate_vg_name() to validate_new_vg_name().
+  Change orphan lock to VG_ORPHANS.
+  Change format1 to use ORPHAN as orphan VG name.
   Convert pvchange, pvdisplay, pvscan to use is_orphan()
-  Add is_orphan_vg() and change all hardcoded checks to use it.
+  Add is_orphan_vg() and change all hard-coded checks to use it.
   Detect md superblocks version 1.0, 1.1 and 1.2.
   Add _alloc_pv() and _free_pv() from _pv_create() code and fix error paths.
   Add pv_dev_name() to access PV device name.
--- LVM2/lib/format1/disk-rep.c	2007/11/02 13:06:41	1.69
+++ LVM2/lib/format1/disk-rep.c	2007/11/02 20:40:04	1.70
@@ -415,19 +415,19 @@
 struct disk_list *read_disk(const struct format_type *fmt, struct device *dev,
 			    struct dm_pool *mem, const char *vg_name)
 {
-	struct disk_list *r;
+	struct disk_list *dl;
 
 	if (!dev_open(dev)) {
 		stack;
 		return NULL;
 	}
 
-	r = __read_disk(fmt, dev, mem, vg_name);
+	dl = __read_disk(fmt, dev, mem, vg_name);
 
 	if (!dev_close(dev))
 		stack;
 
-	return r;
+	return dl;
 }
 
 static void _add_pv_to_list(struct list *head, struct disk_list *data)
--- LVM2/lib/format1/import-export.c	2007/10/12 14:29:31	1.88
+++ LVM2/lib/format1/import-export.c	2007/11/02 20:40:04	1.89
@@ -25,6 +25,7 @@
 #include "segtype.h"
 #include "pv_alloc.h"
 #include "display.h"
+#include "lvmcache.h"
 
 #include <time.h>
 
@@ -59,8 +60,10 @@
 	memcpy(&pv->id, pvd->pv_uuid, ID_LEN);
 
 	pv->dev = dev;
-	if (!(pv->vg_name = dm_pool_strdup(mem, (char *)pvd->vg_name))) {
-		stack;
+	if (!*pvd->vg_name)
+		pv->vg_name = ORPHAN;
+	else if (!(pv->vg_name = dm_pool_strdup(mem, (char *)pvd->vg_name))) {
+		log_error("Volume Group name allocation failed.");
 		return 0;
 	}
 
@@ -644,7 +647,7 @@
 				continue;
 
 			/* insert the snapshot */
-			if (!vg_add_snapshot(vg, NULL, org, cow, NULL,
+			if (!vg_add_snapshot(NULL, org, cow, NULL,
 					     org->le_count, 
 					     lvd->lv_chunk_size)) {
 				log_err("Couldn't add snapshot.");
--- LVM2/lib/metadata/metadata-exported.h	2007/11/02 13:06:41	1.21
+++ LVM2/lib/metadata/metadata-exported.h	2007/11/02 20:40:04	1.22
@@ -412,7 +412,7 @@
 /* Given a cow LV, return its origin */
 struct logical_volume *origin_from_cow(const struct logical_volume *lv);
 
-int vg_add_snapshot(struct volume_group *vg, const char *name,
+int vg_add_snapshot(const char *name,
 		    struct logical_volume *origin, struct logical_volume *cow,
 		    union lvid *lvid, uint32_t extent_count,
 		    uint32_t chunk_size);
--- LVM2/lib/metadata/metadata.c	2007/11/02 13:06:41	1.141
+++ LVM2/lib/metadata/metadata.c	2007/11/02 20:40:04	1.142
@@ -33,7 +33,7 @@
  * FIXME: Check for valid handle before dereferencing field or log error?
  */
 #define pv_field(handle, field)				\
-	(((struct physical_volume *)(handle))->field)
+	(((const struct physical_volume *)(handle))->field)
 
 static struct physical_volume *_pv_read(struct cmd_context *cmd, 
 					const char *pv_name,
@@ -1931,6 +1931,12 @@
 	if (!(misc_flags & CORRECT_INCONSISTENT))
 		consistent = 0;
 
+	if (!validate_name(vg_name)) {
+		log_error("Volume group name %s has invalid characters",
+			  vg_name);
+		return NULL;
+	}
+
 	if (!lock_vol(cmd, vg_name, lock_flags)) {
 		log_error("Can't get lock for %s", vg_name);
 		return NULL;
--- LVM2/lib/metadata/pv_manip.c	2007/11/02 13:06:41	1.16
+++ LVM2/lib/metadata/pv_manip.c	2007/11/02 20:40:04	1.17
@@ -456,8 +456,7 @@
 	list_init(&mdas);
 
 	if (is_orphan_vg(pv_vg_name(pv))) {
-		vg_name = ORPHAN;
-
+		vg_name = VG_ORPHANS;
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 			log_error("Can't get lock for orphans");
 			return 0;
@@ -583,7 +582,7 @@
 		unlock_vg(cmd, vg_name);
 	} else {
 		if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
-			unlock_vg(cmd, ORPHAN);
+			unlock_vg(cmd, VG_ORPHANS);
 			log_error("Failed to store physical volume \"%s\"",
 				  pv_name);
 			return 0;
--- LVM2/lib/metadata/snapshot_manip.c	2007/10/11 19:20:38	1.27
+++ LVM2/lib/metadata/snapshot_manip.c	2007/11/02 20:40:04	1.28
@@ -48,8 +48,7 @@
 	return lv->snapshot->origin;
 }
 
-int vg_add_snapshot(struct volume_group *vg, const char *name,
-		    struct logical_volume *origin,
+int vg_add_snapshot(const char *name, struct logical_volume *origin,
 		    struct logical_volume *cow, union lvid *lvid,
 		    uint32_t extent_count, uint32_t chunk_size)
 {
--- LVM2/lib/snapshot/snapshot.c	2007/10/11 18:51:21	1.23
+++ LVM2/lib/snapshot/snapshot.c	2007/11/02 20:40:04	1.24
@@ -69,7 +69,7 @@
 		return 0;
 	}
 
-	if (!vg_add_snapshot(seg->lv->vg, seg->lv->name, org, cow,
+	if (!vg_add_snapshot(seg->lv->name, org, cow,
 			     &seg->lv->lvid, seg->len, chunk_size)) {
 		stack;
 		return 0;
--- LVM2/tools/lvconvert.c	2007/10/11 18:51:21	1.41
+++ LVM2/tools/lvconvert.c	2007/11/02 20:40:04	1.42
@@ -515,7 +515,7 @@
 		return 0;
 	}
 
-	if (!vg_add_snapshot(lv->vg, NULL, org, lv, NULL, org->le_count,
+	if (!vg_add_snapshot(NULL, org, lv, NULL, org->le_count,
 			     lp->chunk_size)) {
 		log_error("Couldn't create snapshot.");
 		return 0;
--- LVM2/tools/lvcreate.c	2007/10/11 19:20:38	1.152
+++ LVM2/tools/lvcreate.c	2007/11/02 20:40:04	1.153
@@ -125,6 +125,12 @@
 		}
 	}
 
+	if (!validate_name(lp->vg_name)) {
+		log_error("Volume group name %s has invalid characters",
+			  lp->vg_name);
+		return 0;
+	}
+
 	if (lp->lv_name) {
 		if ((ptr = strrchr(lp->lv_name, '/')))
 			lp->lv_name = ptr + 1;
@@ -853,7 +859,7 @@
 
 		/* cow LV remains active and becomes snapshot LV */
 
-		if (!vg_add_snapshot(vg, NULL, org, lv, NULL,
+		if (!vg_add_snapshot(NULL, org, lv, NULL,
 				     org->le_count, lp->chunk_size)) {
 			log_err("Couldn't create snapshot.");
 			return 0;
--- LVM2/tools/lvresize.c	2007/09/24 21:30:00	1.84
+++ LVM2/tools/lvresize.c	2007/11/02 20:40:04	1.85
@@ -239,6 +239,12 @@
 		log_error("Please provide a volume group name");
 		return 0;
 	}
+	
+	if (!validate_name(lp->vg_name)) {
+		log_error("Volume group name %s has invalid characters",
+			  lp->vg_name);
+		return NULL;
+	}
 
 	if ((st = strrchr(lp->lv_name, '/')))
 		lp->lv_name = st + 1;
--- LVM2/tools/pvchange.c	2007/11/02 14:54:40	1.54
+++ LVM2/tools/pvchange.c	2007/11/02 20:40:04	1.55
@@ -21,6 +21,7 @@
 			    void *handle __attribute((unused)))
 {
 	struct volume_group *vg = NULL;
+	const char *vg_name = NULL;
 	struct pv_list *pvl;
 	struct list mdas;
 	uint64_t sector;
@@ -56,13 +57,14 @@
 		log_verbose("Finding volume group of physical volume \"%s\"",
 			    pv_name);
 
-		if (!lock_vol(cmd, pv_vg_name(pv), LCK_VG_WRITE)) {
-			log_error("Can't get lock for %s", pv_vg_name(pv));
+		vg_name = pv_vg_name(pv);
+		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
+			log_error("Can't get lock for %s", vg_name);
 			return 0;
 		}
 
-		if (!(vg = vg_read(cmd, pv_vg_name(pv), NULL, &consistent))) {
-			unlock_vg(cmd, pv_vg_name(pv));
+		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
+			unlock_vg(cmd, vg_name);
 			log_error("Unable to find volume group of \"%s\"",
 				  pv_name);
 			return 0;
@@ -70,25 +72,25 @@
 
 		if (!vg_check_status(vg,
 				     CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
-			unlock_vg(cmd, pv_vg_name(pv));
+			unlock_vg(cmd, vg_name);
 			return 0;
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			unlock_vg(cmd, pv_vg_name(pv));
+			unlock_vg(cmd, vg_name);
 			log_error
 			    ("Unable to find \"%s\" in volume group \"%s\"",
 			     pv_name, vg->name);
 			return 0;
 		}
 		if (tagarg && !(vg->fid->fmt->features & FMT_TAGS)) {
-			unlock_vg(cmd, pv_vg_name(pv));
+			unlock_vg(cmd, vg_name);
 			log_error("Volume group containing %s does not "
 				  "support tags", pv_name);
 			return 0;
 		}
 		if (arg_count(cmd, uuid_ARG) && lvs_in_vg_activated(vg)) {
-			unlock_vg(cmd, pv_vg_name(pv));
+			unlock_vg(cmd, vg_name);
 			log_error("Volume group containing %s has active "
 				  "logical volumes", pv_name);
 			return 0;
@@ -102,17 +104,19 @@
 				  "in volume group", pv_name);
 			return 0;
 		}
-		if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
+
+		vg_name = VG_ORPHANS;
+
+		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 			log_error("Can't get lock for orphans");
 			return 0;
 		}
 
 		if (!(pv = pv_read(cmd, pv_name, &mdas, &sector, 1))) {
-			unlock_vg(cmd, ORPHAN);
+			unlock_vg(cmd, vg_name);
 			log_error("Unable to read PV \"%s\"", pv_name);
 			return 0;
 		}
-
 	}
 
 	if (arg_count(cmd, allocatable_ARG)) {
@@ -120,7 +124,7 @@
 		    !(pv->fmt->features & FMT_ORPHAN_ALLOCATABLE)) {
 			log_error("Allocatability not supported by orphan "
 				  "%s format PV %s", pv->fmt->name, pv_name);
-			unlock_vg(cmd, ORPHAN);
+			unlock_vg(cmd, vg_name);
 			return 0;
 		}
 
@@ -128,20 +132,14 @@
 		if (allocatable && (pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "allocatable", pv_name);
-			if (!is_orphan(pv))
-				unlock_vg(cmd, pv_vg_name(pv));
-			else
-				unlock_vg(cmd, ORPHAN);
+			unlock_vg(cmd, vg_name);
 			return 1;
 		}
 
 		if (!allocatable && !(pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "unallocatable", pv_name);
-			if (!is_orphan(pv))
-				unlock_vg(cmd, pv_vg_name(pv));
-			else
-				unlock_vg(cmd, ORPHAN);
+			unlock_vg(cmd, vg_name);
 			return 1;
 		}
 
@@ -160,12 +158,14 @@
 			if (!str_list_add(cmd->mem, &pv->tags, tag)) {
 				log_error("Failed to add tag %s to physical "
 					  "volume %s", tag, pv_name);
+				unlock_vg(cmd, vg_name);
 				return 0;
 			}
 		} else {
 			if (!str_list_del(&pv->tags, tag)) {
 				log_error("Failed to remove tag %s from "
 					  "physical volume" "%s", tag, pv_name);
+				unlock_vg(cmd, vg_name);
 				return 0;
 			}
 		}
@@ -174,10 +174,12 @@
 		if (!id_create(&pv->id)) {
 			log_error("Failed to generate new random UUID for %s.",
 				  pv_name);
+			unlock_vg(cmd, vg_name);
 			return 0;
 		}
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
 			stack;
+			unlock_vg(cmd, vg_name);
 			return 0;
 		}
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
@@ -189,6 +191,7 @@
 			if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
 				log_error("pv_write with new uuid failed "
 					  "for %s.", pv_name);
+				unlock_vg(cmd, vg_name);
 				return 0;
 			}
 			pv->vg_name = orig_vg_name;
@@ -199,23 +202,21 @@
 	log_verbose("Updating physical volume \"%s\"", pv_name);
 	if (!is_orphan(pv)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
-			unlock_vg(cmd, pv_vg_name(pv));
+			unlock_vg(cmd, vg_name);
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
 			return 0;
 		}
 		backup(vg);
-		unlock_vg(cmd, pv_vg_name(pv));
-	} else {
-		if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
-			unlock_vg(cmd, ORPHAN);
-			log_error("Failed to store physical volume \"%s\"",
-				  pv_name);
-			return 0;
-		}
-		unlock_vg(cmd, ORPHAN);
+	} else if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
+		unlock_vg(cmd, vg_name);
+		log_error("Failed to store physical volume \"%s\"",
+			  pv_name);
+		return 0;
 	}
 
+	unlock_vg(cmd, vg_name);
+
 	log_print("Physical volume \"%s\" changed", pv_name);
 
 	return 1;
--- LVM2/tools/pvcreate.c	2007/08/20 20:55:30	1.55
+++ LVM2/tools/pvcreate.c	2007/11/02 20:40:05	1.56
@@ -65,13 +65,13 @@
 
 	/* Is there an md superblock here? */
 	if (!dev && md_filtering()) {
-		unlock_vg(cmd, ORPHAN);
+		unlock_vg(cmd, VG_ORPHANS);
 
 		persistent_filter_wipe(cmd->filter);
 		lvmcache_destroy();
 
 		init_md_filtering(0);
-		if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
+		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 			log_error("Can't get lock for orphan PVs");
 			init_md_filtering(1);
 			return 0;
@@ -171,7 +171,7 @@
 		extent_count = pv_pe_count(existing_pv);
 	}
 
-	if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
@@ -254,11 +254,11 @@
 
 	log_print("Physical volume \"%s\" successfully created", pv_name);
 
-	unlock_vg(cmd, ORPHAN);
+	unlock_vg(cmd, VG_ORPHANS);
 	return ECMD_PROCESSED;
 
       error:
-	unlock_vg(cmd, ORPHAN);
+	unlock_vg(cmd, VG_ORPHANS);
 	return ECMD_FAILED;
 }
 
--- LVM2/tools/pvdisplay.c	2007/11/02 14:54:40	1.40
+++ LVM2/tools/pvdisplay.c	2007/11/02 20:40:05	1.41
@@ -25,15 +25,17 @@
 	uint64_t size;
 
 	const char *pv_name = pv_dev_name(pv);
+	const char *vg_name = NULL;
 
-	 if (pv_vg_name(pv)) {
-	         if (!lock_vol(cmd, pv_vg_name(pv), LCK_VG_READ)) {
-	                 log_error("Can't lock %s: skipping", pv_vg_name(pv));
+	 if (!is_orphan(pv)) {
+		vg_name = pv_vg_name(pv);
+	         if (!lock_vol(cmd, vg_name, LCK_VG_READ)) {
+	                 log_error("Can't lock %s: skipping", vg_name);
 	                 return ECMD_FAILED;
 	         }
 
-	         if (!(vg = vg_read(cmd, pv_vg_name(pv), (char *)&pv->vgid, &consistent))) {
-	                 log_error("Can't read %s: skipping", pv_vg_name(pv));
+	         if (!(vg = vg_read(cmd, vg_name, (char *)&pv->vgid, &consistent))) {
+	                 log_error("Can't read %s: skipping", vg_name);
 	                 goto out;
 	         }
 
@@ -87,8 +89,8 @@
 		pvdisplay_segments(pv);
 
 out:
-        if (pv_vg_name(pv))
-                unlock_vg(cmd, pv_vg_name(pv));
+        if (vg_name)
+                unlock_vg(cmd, vg_name);
 
 	return ret;
 }
--- LVM2/tools/pvremove.c	2007/08/20 20:55:30	1.19
+++ LVM2/tools/pvremove.c	2007/11/02 20:40:05	1.20
@@ -76,8 +76,9 @@
 			   void *handle __attribute((unused)))
 {
 	struct device *dev;
+	int ret = ECMD_FAILED;
 
-	if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
@@ -106,12 +107,12 @@
 	log_print("Labels on physical volume \"%s\" successfully wiped",
 		  pv_name);
 
-	unlock_vg(cmd, ORPHAN);
-	return ECMD_PROCESSED;
+	ret = ECMD_PROCESSED;
 
       error:
-	unlock_vg(cmd, ORPHAN);
-	return ECMD_FAILED;
+	unlock_vg(cmd, VG_ORPHANS);
+
+	return ret;
 }
 
 int pvremove(struct cmd_context *cmd, int argc, char **argv)
--- LVM2/tools/reporter.c	2007/08/22 14:38:18	1.27
+++ LVM2/tools/reporter.c	2007/11/02 20:40:05	1.28
@@ -103,17 +103,21 @@
 static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		       struct physical_volume *pv, void *handle)
 {
+	struct pv_list *pvl;
 	int consistent = 0;
 	int ret = ECMD_PROCESSED;
+	const char *vg_name = NULL;
 
-	if (pv_vg_name(pv)) {
-		if (!lock_vol(cmd, pv_vg_name(pv), LCK_VG_READ)) {
-			log_error("Can't lock %s: skipping", pv_vg_name(pv));
+	if (!is_orphan(pv)) {
+		vg_name = pv_vg_name(pv);
+
+		if (!lock_vol(cmd, vg_name, LCK_VG_READ)) {
+			log_error("Can't lock %s: skipping", vg_name);
 			return ECMD_FAILED;
 		}
 
-		if (!(vg = vg_read(cmd, pv_vg_name(pv), (char *)&pv->vgid, &consistent))) {
-			log_error("Can't read %s: skipping", pv_vg_name(pv));
+		if (!(vg = vg_read(cmd, vg_name, (char *)&pv->vgid, &consistent))) {
+			log_error("Can't read %s: skipping", vg_name);
 			goto out;
 		}
 
@@ -121,14 +125,27 @@
 			ret = ECMD_FAILED;
 			goto out;
 		}
+
+		/*
+		 * Replace possibly incomplete PV structure with new one
+		 * allocated in vg_read() path.
+		*/
+		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
+			log_error("Unable to find \"%s\" in volume group \"%s\"",
+				  pv_dev_name(pv), vg->name);
+			ret = ECMD_FAILED;
+			goto out;
+		}
+
+                 pv = pvl->pv;
 	}
 
 	if (!report_object(handle, vg, NULL, pv, NULL, NULL))
 		ret = ECMD_FAILED;
 
 out:
-	if (pv_vg_name(pv))
-		unlock_vg(cmd, pv_vg_name(pv));
+	if (vg_name)
+		unlock_vg(cmd, vg_name);
 
 	return ret;
 }
--- LVM2/tools/toollib.c	2007/11/02 13:06:42	1.109
+++ LVM2/tools/toollib.c	2007/11/02 20:40:05	1.110
@@ -341,7 +341,7 @@
 
 	list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
-		if (!vgname || is_orphan_vg(vgname))
+		if (is_orphan_vg(vgname))
 			continue;	/* FIXME Unnecessary? */
 		if (!lock_vol(cmd, vgname, lock_type)) {
 			log_error("Can't lock %s: skipping", vgname);
@@ -474,7 +474,7 @@
 	int ret = 0;
 
 	if (!lock_vol(cmd, vg_name, lock_type)) {
-		log_error("Can't lock %s: skipping", vg_name);
+		log_error("Can't lock volume group %s: skipping", vg_name);
 		return ret_max;
 	}
 
@@ -588,7 +588,7 @@
 	} else {
 		list_iterate_items(sl, vgnames) {
 			vg_name = sl->str;
-			if (!vg_name || is_orphan_vg(vg_name))
+			if (is_orphan_vg(vg_name))
 				continue;	/* FIXME Unnecessary? */
 			ret_max = _process_one_vg(cmd, vg_name, NULL, &tags,
 						  &arg_vgnames,
@@ -1192,16 +1192,13 @@
 	return 1;
 }
 
-int validate_vg_name(struct cmd_context *cmd, const char *vg_name)
+int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
 {
 	char vg_path[PATH_MAX];
 
 	if (!validate_name(vg_name))
 		return 0;
 
-	if (is_orphan_vg(vg_name))
-		return 0;
-
 	snprintf(vg_path, PATH_MAX, "%s%s", cmd->dev_dir, vg_name);
 	if (path_exists(vg_path)) {
 		log_error("%s: already exists in filesystem", vg_path);
--- LVM2/tools/toollib.h	2007/08/22 14:38:18	1.50
+++ LVM2/tools/toollib.h	2007/11/02 20:40:05	1.51
@@ -96,7 +96,7 @@
 
 int apply_lvname_restrictions(const char *name);
 
-int validate_vg_name(struct cmd_context *cmd, const char *vg_name);
+int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name);
 
 int generate_log_name_format(struct volume_group *vg, const char *lv_name,
                              char *buffer, size_t size);
--- LVM2/tools/vgcfgrestore.c	2007/08/20 20:55:30	1.16
+++ LVM2/tools/vgcfgrestore.c	2007/11/02 20:40:05	1.17
@@ -43,14 +43,14 @@
 		return ECMD_PROCESSED;
 	}
 
-	if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Unable to lock orphans");
 		return ECMD_FAILED;
 	}
 
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
 		log_error("Unable to lock volume group %s", vg_name);
-		unlock_vg(cmd, ORPHAN);
+		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
@@ -59,7 +59,7 @@
 				       arg_str_value(cmd, file_ARG, "")) :
 	      backup_restore(cmd, vg_name))) {
 		unlock_vg(cmd, vg_name);
-		unlock_vg(cmd, ORPHAN);
+		unlock_vg(cmd, VG_ORPHANS);
 		log_err("Restore failed.");
 		return ECMD_FAILED;
 	}
@@ -67,6 +67,6 @@
 	log_print("Restored volume group %s", vg_name);
 
 	unlock_vg(cmd, vg_name);
-	unlock_vg(cmd, ORPHAN);
+	unlock_vg(cmd, VG_ORPHANS);
 	return ECMD_PROCESSED;
 }
--- LVM2/tools/vgcreate.c	2007/08/20 20:55:30	1.50
+++ LVM2/tools/vgcreate.c	2007/11/02 20:40:05	1.51
@@ -84,7 +84,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!validate_vg_name(cmd, vg_name)) {
+	if (!validate_new_vg_name(cmd, vg_name)) {
 		log_error("New volume group name \"%s\" is invalid", vg_name);
 		return ECMD_FAILED;
 	}
@@ -131,32 +131,32 @@
 	else
 		vg->status &= ~CLUSTERED;
 
-	if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
 
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
 		log_error("Can't get lock for %s", vg_name);
-		unlock_vg(cmd, ORPHAN);
+		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
 	if (!archive(vg)) {
 		unlock_vg(cmd, vg_name);
-		unlock_vg(cmd, ORPHAN);
+		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
 	/* Store VG on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg)) {
 		unlock_vg(cmd, vg_name);
-		unlock_vg(cmd, ORPHAN);
+		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
 	unlock_vg(cmd, vg_name);
-	unlock_vg(cmd, ORPHAN);
+	unlock_vg(cmd, VG_ORPHANS);
 
 	backup(vg);
 
--- LVM2/tools/vgextend.c	2007/08/20 20:55:30	1.34
+++ LVM2/tools/vgextend.c	2007/11/02 20:40:05	1.35
@@ -35,23 +35,17 @@
 	argc--;
 	argv++;
 
-	if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
 
-	if (!validate_name(vg_name)) {
-		log_error("Volume group name \"%s\" is invalid",
-			  vg_name);
-		return ECMD_FAILED;
-	}
-
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	if (!(vg = vg_lock_and_read(cmd, vg_name, LCK_VG_WRITE | LCK_NONBLOCK,
 				    CLUSTERED | EXPORTED_VG | 
 				    LVM_WRITE | RESIZEABLE_VG,
 				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
-		 unlock_vg(cmd, ORPHAN);
+		 unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	 }
 /********** FIXME
@@ -79,7 +73,7 @@
 	backup(vg);
 
 	unlock_vg(cmd, vg_name);
-	unlock_vg(cmd, ORPHAN);
+	unlock_vg(cmd, VG_ORPHANS);
 
 	log_print("Volume group \"%s\" successfully extended", vg_name);
 
@@ -87,6 +81,6 @@
 
       error:
 	unlock_vg(cmd, vg_name);
-	unlock_vg(cmd, ORPHAN);
+	unlock_vg(cmd, VG_ORPHANS);
 	return ECMD_FAILED;
 }
--- LVM2/tools/vgremove.c	2007/08/21 17:38:20	1.44
+++ LVM2/tools/vgremove.c	2007/11/02 20:40:05	1.45
@@ -35,7 +35,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
@@ -44,7 +44,7 @@
 			      LCK_VG_WRITE | LCK_NONBLOCK, 1, 
 			      NULL, &vgremove_single);
 
-	unlock_vg(cmd, ORPHAN);
+	unlock_vg(cmd, VG_ORPHANS);
 
 	return ret;
 }
--- LVM2/tools/vgrename.c	2007/11/02 13:06:42	1.47
+++ LVM2/tools/vgrename.c	2007/11/02 20:40:05	1.48
@@ -44,7 +44,7 @@
 		return 0;
 	}
 
-	if (!validate_vg_name(cmd, vg_name_new)) {
+	if (!validate_new_vg_name(cmd, vg_name_new)) {
 		log_error("New volume group name \"%s\" is invalid",
 			  vg_name_new);
 		return 0;
@@ -65,8 +65,8 @@
 
 	list_iterate_items(sl, vgids) {
 		vgid = sl->str;
-		if (!vgid || !(vg_name = vgname_from_vgid(NULL, vgid))
-					|| is_orphan_vg(vg_name))
+		if (!vgid || !(vg_name = vgname_from_vgid(NULL, vgid)) ||
+		    is_orphan_vg(vg_name))
 			continue;
 		if (!strcmp(vg_name, vg_name_old)) {
 			if (match) {
--- LVM2/tools/vgsplit.c	2007/10/12 14:29:32	1.37
+++ LVM2/tools/vgsplit.c	2007/11/02 20:40:05	1.38
@@ -228,12 +228,6 @@
 	argc -= 2;
 	argv += 2;
 
-	if (!validate_name(vg_name_from)) {
-		log_error("Volume group name \"%s\" is invalid",
-			  vg_name_from);
-		return ECMD_FAILED;
-	}
-
 	if (!strcmp(vg_name_to, vg_name_from)) {
 		log_error("Duplicate volume group name \"%s\"", vg_name_from);
 		return ECMD_FAILED;
@@ -253,6 +247,13 @@
 		return ECMD_FAILED;
 	}
 
+	if (!validate_new_vg_name(cmd, vg_name_to)) {
+		log_error("New volume group name \"%s\" is invalid",
+			   vg_name_to);
+		unlock_vg(cmd, vg_name_from);
+		return ECMD_FAILED;
+	}
+
 	consistent = 0;
 	if ((vg_to = vg_read(cmd, vg_name_to, NULL, &consistent))) {
 		/* FIXME Remove this restriction */
@@ -260,12 +261,6 @@
 		goto error;
 	}
 
-	if (!validate_vg_name(cmd, vg_name_to)) {
-		log_error("New volume group name \"%s\" is invalid",
-			   vg_name_to);
-		goto error;
-	}
-
 	if ((active = lvs_in_vg_activated(vg_from))) {
 		/* FIXME Remove this restriction */
 		log_error("Logical volumes in \"%s\" must be inactive",


