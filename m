From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 23:29:35 -0000
Subject: LVM2/tools vgsplit.c vgremove.c vgreduce.c vgc ...
Message-ID: <20070613232935.22123.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 23:29:34

Modified files:
	tools          : vgsplit.c vgremove.c vgreduce.c vgconvert.c 
	                 pvscan.c pvresize.c pvmove.c pvdisplay.c 
	                 pvchange.c 

Log message:
	Convert pv->dev to get_pv_dev

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/tools/vgsplit.c	2007/06/13 22:11:29	1.28
+++ LVM2/tools/vgsplit.c	2007/06/13 23:29:33	1.29
@@ -105,7 +105,7 @@
 					continue;
 				}
 				log_error("Physical Volume %s not found",
-					  dev_name(pv->dev));
+					  dev_name(get_pv_dev(pv)));
 				return 0;
 			}
 
--- LVM2/tools/vgremove.c	2007/03/15 14:00:30	1.38
+++ LVM2/tools/vgremove.c	2007/06/13 23:29:33	1.39
@@ -54,12 +54,12 @@
 	list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 		log_verbose("Removing physical volume \"%s\" from "
-			    "volume group \"%s\"", dev_name(pv->dev), vg_name);
+			    "volume group \"%s\"", dev_name(get_pv_dev(pv)), vg_name);
 		pv->vg_name = ORPHAN;
 		pv->status = ALLOCATABLE_PV;
 
-		if (!dev_get_size(pv->dev, &pv->size)) {
-			log_error("%s: Couldn't get size.", dev_name(pv->dev));
+		if (!dev_get_size(get_pv_dev(pv), &pv->size)) {
+			log_error("%s: Couldn't get size.", dev_name(get_pv_dev(pv)));
 			ret = ECMD_FAILED;
 			continue;
 		}
@@ -68,7 +68,7 @@
 		if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
 			log_error("Failed to remove physical volume \"%s\""
 				  " from volume group \"%s\"",
-				  dev_name(pv->dev), vg_name);
+				  dev_name(get_pv_dev(pv)), vg_name);
 			ret = ECMD_FAILED;
 		}
 	}
--- LVM2/tools/vgreduce.c	2007/06/13 23:02:51	1.62
+++ LVM2/tools/vgreduce.c	2007/06/13 23:29:33	1.63
@@ -185,7 +185,7 @@
 				/* FIXME Also check for segs on deleted LVs */
 
 				pv = seg_pv(seg, s);
-				if (!pv || !pv->dev) {
+				if (!pv || !get_pv_dev(pv)) {
 					if (arg_count(cmd, mirrorsonly_ARG) &&
 					    !(lv->status & MIRROR_IMAGE)) {
 						log_error("Non-mirror-image LV %s found: can't remove.", lv->name);
@@ -365,7 +365,7 @@
 			    void *handle __attribute((unused)))
 {
 	struct pv_list *pvl;
-	const char *name = dev_name(pv->dev);
+	const char *name = dev_name(get_pv_dev(pv));
 
 	if (get_pv_pe_alloc_count(pv)) {
 		log_error("Physical volume \"%s\" still in use", name);
@@ -391,8 +391,8 @@
 	pv->vg_name = ORPHAN;
 	pv->status = ALLOCATABLE_PV;
 
-	if (!dev_get_size(pv->dev, &pv->size)) {
-		log_error("%s: Couldn't get size.", dev_name(pv->dev));
+	if (!dev_get_size(get_pv_dev(pv), &pv->size)) {
+		log_error("%s: Couldn't get size.", dev_name(get_pv_dev(pv)));
 		return ECMD_FAILED;
 	}
 
--- LVM2/tools/vgconvert.c	2007/06/13 23:02:51	1.20
+++ LVM2/tools/vgconvert.c	2007/06/13 23:29:33	1.21
@@ -136,30 +136,30 @@
 		change_made = 1;
 
 		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
-			    " available sectors", dev_name(pv->dev), get_pv_size(pv));
+			    " available sectors", dev_name(get_pv_dev(pv)), get_pv_size(pv));
 
 		/* Wipe existing label first */
-		if (!label_remove(pv->dev)) {
+		if (!label_remove(get_pv_dev(pv))) {
 			log_error("Failed to wipe existing label on %s",
-				  dev_name(pv->dev));
+				  dev_name(get_pv_dev(pv)));
 			log_error("Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
 			return ECMD_FAILED;
 		}
 
 		log_very_verbose("Writing physical volume data to disk \"%s\"",
-				 dev_name(pv->dev));
+				 dev_name(get_pv_dev(pv)));
 		if (!(pv_write(cmd, pv, &mdas,
 			       arg_int64_value(cmd, labelsector_ARG,
 					       DEFAULT_LABELSECTOR)))) {
 			log_error("Failed to write physical volume \"%s\"",
-				  dev_name(pv->dev));
+				  dev_name(get_pv_dev(pv)));
 			log_error("Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
 			return ECMD_FAILED;
 		}
 		log_verbose("Physical volume \"%s\" successfully created",
-			    dev_name(pv->dev));
+			    dev_name(get_pv_dev(pv)));
 
 	}
 
--- LVM2/tools/pvscan.c	2007/06/13 23:02:51	1.34
+++ LVM2/tools/pvscan.c	2007/06/13 23:29:33	1.35
@@ -31,7 +31,7 @@
 
 	/* short listing? */
 	if (arg_count(cmd, short_ARG) > 0) {
-		log_print("%s", dev_name(pv->dev));
+		log_print("%s", dev_name(get_pv_dev(pv)));
 		return;
 	}
 
@@ -57,9 +57,9 @@
 		}
 
 		sprintf(pv_tmp_name, "%-*s with UUID %s",
-			pv_max_name_len - 2, dev_name(pv->dev), uuid);
+			pv_max_name_len - 2, dev_name(get_pv_dev(pv)), uuid);
 	} else {
-		sprintf(pv_tmp_name, "%s", dev_name(pv->dev));
+		sprintf(pv_tmp_name, "%s", dev_name(get_pv_dev(pv)));
 	}
 
 	if (!*pv->vg_name) {
@@ -166,7 +166,7 @@
 	pv_max_name_len = vg_max_name_len = 0;
 	list_iterate_items(pvl, pvslist) {
 		pv = pvl->pv;
-		len = strlen(dev_name(pv->dev));
+		len = strlen(dev_name(get_pv_dev(pv)));
 		if (pv_max_name_len < len)
 			pv_max_name_len = len;
 		len = strlen(pv->vg_name);
--- LVM2/tools/pvresize.c	2007/06/13 23:02:51	1.7
+++ LVM2/tools/pvresize.c	2007/06/13 23:29:33	1.8
@@ -33,7 +33,7 @@
 	uint64_t size = 0;
 	uint32_t new_pe_count = 0;
 	struct list mdas;
-	const char *pv_name = dev_name(pv->dev);
+	const char *pv_name = dev_name(get_pv_dev(pv));
 	struct pvresize_params *params = (struct pvresize_params *) handle;
 	const char *vg_name;
 
@@ -103,7 +103,7 @@
 	}
 
 	/* Get new size */
-	if (!dev_get_size(pv->dev, &size)) {
+	if (!dev_get_size(get_pv_dev(pv), &size)) {
 		log_error("%s: Couldn't get size.", pv_name);
 		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
--- LVM2/tools/pvmove.c	2007/06/06 19:40:28	1.34
+++ LVM2/tools/pvmove.c	2007/06/13 23:29:33	1.35
@@ -100,7 +100,7 @@
 		pvl = list_item(pvh, struct pv_list);
 
 		/* Don't allocate onto the PV we're clearing! */
-		if ((alloc != ALLOC_ANYWHERE) && (pvl->pv->dev == pv->dev)) {
+		if ((alloc != ALLOC_ANYWHERE) && (pvl->pv->dev == get_pv_dev(pv))) {
 			list_del(&pvl->list);
 			continue;
 		}
@@ -296,7 +296,7 @@
 		return ECMD_FAILED;
 	}
 
-	if ((lv_mirr = find_pvmove_lv(vg, pv->dev, PVMOVE))) {
+	if ((lv_mirr = find_pvmove_lv(vg, get_pv_dev(pv), PVMOVE))) {
 		log_print("Detected pvmove in progress for %s", pv_name);
 		if (argc || lv_name)
 			log_error("Ignoring remaining command line arguments");
--- LVM2/tools/pvdisplay.c	2007/06/13 23:02:51	1.32
+++ LVM2/tools/pvdisplay.c	2007/06/13 23:29:33	1.33
@@ -24,7 +24,7 @@
 	int ret = ECMD_PROCESSED;
 	uint64_t size;
 
-	const char *pv_name = dev_name(pv->dev);
+	const char *pv_name = dev_name(get_pv_dev(pv));
 
 	 if (pv->vg_name) {
 	         if (!lock_vol(cmd, pv->vg_name, LCK_VG_READ)) {
--- LVM2/tools/pvchange.c	2007/06/13 22:04:45	1.46
+++ LVM2/tools/pvchange.c	2007/06/13 23:29:33	1.47
@@ -26,7 +26,7 @@
 	uint64_t sector;
 	uint32_t orig_pe_alloc_count;
 
-	const char *pv_name = dev_name(pv->dev);
+	const char *pv_name = dev_name(get_pv_dev(pv));
 	const char *tag = NULL;
 	const char *orig_vg_name;
 	char uuid[64] __attribute((aligned(8)));


