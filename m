From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 11:04:01 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20120213110401.11097.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 11:04:00

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c vg.c vg.h 
	tools          : pvcreate.c vgconvert.c 

Log message:
	Add free_orphan_vg
	
	Move commod code to destroy orphan VG into free_orphan_vg() function.
	Use orphan vgmem for creation of PV lists.
	Remove some free_pv_fid() calls (FIXME: check all of them)
	FIXME: Check whether we could merge release_vg back again for all VGs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2285&r2=1.2286
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.191&r2=1.192
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.483&r2=1.484
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/WHATS_NEW	2012/02/13 11:01:34	1.2285
+++ LVM2/WHATS_NEW	2012/02/13 11:03:59	1.2286
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Add free_orphan_vg.
   Skip pv/vg_set_fid processing if the fid is same.
   Check for foreach loop errors in _vg_read_orphans() (2.02.91).
   Clean error paths for format instance creation (2.02.91).
--- LVM2/lib/format1/format1.c	2012/02/13 10:56:31	1.145
+++ LVM2/lib/format1/format1.c	2012/02/13 11:03:59	1.146
@@ -546,12 +546,8 @@
 
 static void _format1_destroy(struct format_type *fmt)
 {
-	/* FIXME out of place, but the main (cmd) pool has been already
-	 * destroyed and touching the fid (also via release_vg) will crash the
-	 * program */
-	dm_hash_destroy(fmt->orphan_vg->hostnames);
-	dm_pool_destroy(fmt->orphan_vg->fid->mem);
-	dm_pool_destroy(fmt->orphan_vg->vgmem);
+	if (fmt->orphan_vg)
+		free_orphan_vg(fmt->orphan_vg);
 
 	dm_free(fmt);
 }
--- LVM2/lib/format_pool/format_pool.c	2012/02/13 10:56:31	1.49
+++ LVM2/lib/format_pool/format_pool.c	2012/02/13 11:04:00	1.50
@@ -259,12 +259,8 @@
 
 static void _pool_destroy(struct format_type *fmt)
 {
-	/* FIXME out of place, but the main (cmd) pool has been already
-	 * destroyed and touching the fid (also via release_vg) will crash the
-	 * program */
-	dm_hash_destroy(fmt->orphan_vg->hostnames);
-	dm_pool_destroy(fmt->orphan_vg->fid->mem);
-	dm_pool_destroy(fmt->orphan_vg->vgmem);
+	if (fmt->orphan_vg)
+		free_orphan_vg(fmt->orphan_vg);
 
 	dm_free(fmt);
 }
--- LVM2/lib/format_text/format-text.c	2012/02/13 10:56:31	1.191
+++ LVM2/lib/format_text/format-text.c	2012/02/13 11:04:00	1.192
@@ -1541,13 +1541,8 @@
 
 static void _text_destroy(struct format_type *fmt)
 {
-	/* FIXME out of place, but the main (cmd) pool has been already
-	 * destroyed and touching the fid (also via release_vg) will crash the
-	 * program */
-	dm_hash_destroy(fmt->orphan_vg->fid->metadata_areas_index);
-	dm_hash_destroy(fmt->orphan_vg->hostnames);
-	dm_pool_destroy(fmt->orphan_vg->fid->mem);
-	dm_pool_destroy(fmt->orphan_vg->vgmem);
+	if (fmt->orphan_vg)
+		free_orphan_vg(fmt->orphan_vg);
 
 	if (fmt->private) {
 		_free_dirs(&((struct mda_lists *) fmt->private)->dirs);
--- LVM2/lib/metadata/metadata.c	2012/02/13 11:01:35	1.483
+++ LVM2/lib/metadata/metadata.c	2012/02/13 11:04:00	1.484
@@ -1551,7 +1551,6 @@
 	return pv;
 
 bad:
-	free_pv_fid(pv);
 	return NULL;
 }
 
@@ -1575,6 +1574,7 @@
 
 /**
  * pv_create - initialize a physical volume for use with a volume group
+ * created PV belongs to Orphan VG.
  *
  * @fmt: format type
  * @dev: PV device to initialize
@@ -1609,9 +1609,10 @@
 				  unsigned metadataignore)
 {
 	const struct format_type *fmt = cmd->fmt;
-	struct dm_pool *mem = fmt->cmd->mem;
+	struct dm_pool *mem = fmt->orphan_vg->vgmem;
 	struct physical_volume *pv = _alloc_pv(mem, dev);
 	unsigned mda_index;
+	struct pv_list *pvl;
 
 	if (!pv)
 		return_NULL;
@@ -1650,7 +1651,6 @@
 		goto bad;
 	}
 
-	struct pv_list *pvl;
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
 		log_error("pv_list allocation in pv_create failed");
 		goto bad;
@@ -1687,8 +1687,9 @@
 	return pv;
 
       bad:
-	free_pv_fid(pv);
-	dm_pool_free(mem, pv);
+	// FIXME: detach from orphan in error path
+	//free_pv_fid(pv);
+	//dm_pool_free(mem, pv);
 	return NULL;
 }
 
--- LVM2/lib/metadata/vg.c	2012/02/10 02:53:05	1.16
+++ LVM2/lib/metadata/vg.c	2012/02/13 11:04:00	1.17
@@ -90,6 +90,18 @@
 	_free_vg(vg);
 }
 
+/*
+ * FIXME out of place, but the main (cmd) pool has been already
+ * destroyed and touching the fid (also via release_vg) will crash the
+ * program
+ *
+ * For now quick wrapper to allow destroy of orphan vg
+ */
+void free_orphan_vg(struct volume_group *vg)
+{
+	_free_vg(vg);
+}
+
 char *vg_fmt_dup(const struct volume_group *vg)
 {
 	if (!vg->fid || !vg->fid->fmt)
--- LVM2/lib/metadata/vg.h	2012/01/19 15:31:45	1.17
+++ LVM2/lib/metadata/vg.h	2012/02/13 11:04:00	1.18
@@ -121,6 +121,7 @@
  * by vg_create() or vg_read_internal() to free it when no longer required.
  */
 void release_vg(struct volume_group *vg);
+void free_orphan_vg(struct volume_group *vg);
 
 char *vg_fmt_dup(const struct volume_group *vg);
 char *vg_name_dup(const struct volume_group *vg);
--- LVM2/tools/pvcreate.c	2011/08/30 14:55:19	1.97
+++ LVM2/tools/pvcreate.c	2012/02/13 11:04:00	1.98
@@ -117,7 +117,6 @@
 			ret = ECMD_FAILED;
 		}
 
-		free_pv_fid(pv);
 		unlock_vg(cmd, VG_ORPHANS);
 		if (sigint_caught())
 			return ret;
--- LVM2/tools/vgconvert.c	2011/03/11 14:56:56	1.51
+++ LVM2/tools/vgconvert.c	2012/02/13 11:04:00	1.52
@@ -146,7 +146,6 @@
 				  pv_dev_name(pv));
 			log_error("Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
-			free_pv_fid(pv);
 			return ECMD_FAILED;
 		}
 
@@ -157,13 +156,10 @@
 				  pv_dev_name(pv));
 			log_error("Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
-			free_pv_fid(pv);
 			return ECMD_FAILED;
 		}
 		log_verbose("Physical volume \"%s\" successfully created",
 			    pv_dev_name(pv));
-
-		free_pv_fid(pv);
 	}
 
 	log_verbose("Deleting existing metadata for VG %s", vg_name);


