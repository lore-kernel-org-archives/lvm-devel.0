From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Apr 2009 09:56:01 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20090410095601.18446.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-10 09:56:00

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Properly copy the whole pv structure for later use.
	
	The all_pvs list, used in vg_read, should make its own private
	copy of pv structures, otherwise (when vg will use its own pool)
	it will point to released memory pool.
	The same applies for get_pvs() call.
	
	Patch adds pv_list copy helper and adds explicit memory pool
	parameter into _copy_pv.
	
	(Please note that all these helper functions cannot guarantee that
	vg related fields are valid - proper vg read & lock must be used
	if it is requested.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1083&r2=1.1084
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.208&r2=1.209

--- LVM2/WHATS_NEW	2009/04/10 09:54:36	1.1083
+++ LVM2/WHATS_NEW	2009/04/10 09:56:00	1.1084
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Use copy of PV structure when manipulating with global PV lists.
   Always return exit error status when locking of volume group fails.
   Fix mirror log convert validation question.
   Avoid referencing files from DESTDIR during build process.
--- LVM2/lib/metadata/metadata.c	2009/04/02 15:01:11	1.208
+++ LVM2/lib/metadata/metadata.c	2009/04/10 09:56:00	1.209
@@ -198,11 +198,10 @@
 	return 1;
 }
 
-static int _copy_pv(struct physical_volume *pv_to,
+static int _copy_pv(struct dm_pool *pvmem,
+		    struct physical_volume *pv_to,
 		    struct physical_volume *pv_from)
 {
-	struct dm_pool *pvmem = pv_from->fmt->cmd->mem;
-
 	memcpy(pv_to, pv_from, sizeof(*pv_to));
 
 	if (!(pv_to->vg_name = dm_pool_strdup(pvmem, pv_from->vg_name)))
@@ -217,6 +216,25 @@
 	return 1;
 }
 
+static struct pv_list *_copy_pvl(struct dm_pool *pvmem, struct pv_list *pvl_from)
+{
+	struct pv_list *pvl_to = NULL;
+
+	if (!(pvl_to = dm_pool_zalloc(pvmem, sizeof(*pvl_to))))
+		return_NULL;
+
+	if (!(pvl_to->pv = dm_pool_alloc(pvmem, sizeof(*pvl_to->pv))))
+		goto_bad;
+
+	if(!_copy_pv(pvmem, pvl_to->pv, pvl_from->pv))
+		goto_bad;
+
+	return pvl_to;
+bad:
+	dm_pool_free(pvmem, pvl_to);
+	return NULL;
+}
+
 int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 			 const char *vgid, const char *pvid,
 			 struct physical_volume *pv)
@@ -237,7 +255,7 @@
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (id_equal(&pvl->pv->id, (const struct id *) pvid)) {
-			if (!_copy_pv(pv, pvl->pv)) {
+			if (!_copy_pv(fmt->cmd->mem, pv, pvl->pv)) {
 				log_error("internal PV duplication failed");
 				return_0;
 			}
@@ -1669,7 +1687,7 @@
 	return vg;
 }
 
-static int _update_pv_list(struct dm_list *all_pvs, struct volume_group *vg)
+static int _update_pv_list(struct dm_pool *pvmem, struct dm_list *all_pvs, struct volume_group *vg)
 {
 	struct pv_list *pvl, *pvl2;
 
@@ -1678,13 +1696,15 @@
 			if (pvl->pv->dev == pvl2->pv->dev)
 				goto next_pv;
 		}
-		/* PV is not on list so add it.  Note that we don't copy it. */
-       		if (!(pvl2 = dm_pool_zalloc(vg->cmd->mem, sizeof(*pvl2)))) {
+
+		/*
+		 * PV is not on list so add it.
+		 */
+		if (!(pvl2 = _copy_pvl(pvmem, pvl))) {
 			log_error("pv_list allocation for '%s' failed",
 				  pv_dev_name(pvl->pv));
 			return 0;
 		}
-		pvl2->pv = pvl->pv;
 		dm_list_add(all_pvs, &pvl2->list);
   next_pv:
 		;
@@ -1899,7 +1919,7 @@
 			}
 			if (!correct_vg) {
 				correct_vg = vg;
-				if (!_update_pv_list(&all_pvs, correct_vg))
+				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg))
 					return_NULL;
 				continue;
 			}
@@ -1913,7 +1933,7 @@
 			/* FIXME Also ensure contents same - checksums same? */
 			if (correct_vg->seqno != vg->seqno) {
 				inconsistent = 1;
-				if (!_update_pv_list(&all_pvs, vg))
+				if (!_update_pv_list(cmd->mem, &all_pvs, vg))
 					return_NULL;
 				if (vg->seqno > correct_vg->seqno)
 					correct_vg = vg;
@@ -2203,7 +2223,7 @@
 	struct str_list *strl;
 	struct dm_list * uninitialized_var(results);
 	const char *vgname, *vgid;
-	struct dm_list *pvh, *tmp;
+	struct pv_list *pvl, *pvl_copy;
 	struct dm_list *vgids;
 	struct volume_group *vg;
 	int consistent = 0;
@@ -2249,8 +2269,13 @@
 
 		/* Move PVs onto results list */
 		if (pvslist)
-			dm_list_iterate_safe(pvh, tmp, &vg->pvs)
-				dm_list_add(results, pvh);
+			dm_list_iterate_items(pvl, &vg->pvs) {
+				if (!(pvl_copy = _copy_pvl(cmd->mem, pvl))) {
+					log_error("PV list allocation failed");
+					return 0;
+				}
+				dm_list_add(results, &pvl_copy->list);
+			}
 	}
 	init_pvmove(old_pvmove);
 


