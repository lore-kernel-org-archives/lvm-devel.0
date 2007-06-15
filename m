From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Jun 2007 22:16:56 -0000
Subject: LVM2 lib/metadata/metadata.c lib/metadata/meta ...
Message-ID: <20070615221656.25369.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-15 22:16:55

Modified files:
	lib/metadata   : metadata.c metadata.h 
	tools          : pvchange.c pvcreate.c pvdisplay.c pvmove.c 
	                 pvremove.c pvresize.c pvscan.c reporter.c 
	                 vgconvert.c vgreduce.c vgremove.c vgsplit.c 

Log message:
	Remove get_ prefix from get_pv_* functions

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.162&r2=1.163
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/lib/metadata/metadata.c	2007/06/14 15:48:05	1.117
+++ LVM2/lib/metadata/metadata.c	2007/06/15 22:16:55	1.118
@@ -1784,57 +1784,57 @@
 /*
  * Gets/Sets for external LVM library
  */
-struct id get_pv_id(pv_t *pv)
+struct id pv_id(pv_t *pv)
 {
 	return pv_field(pv, id);
 }
 
-const struct format_type *get_pv_format_type(pv_t *pv)
+const struct format_type *pv_format_type(pv_t *pv)
 {
 	return pv_field(pv, fmt);
 }
 
-struct id get_pv_vgid(pv_t *pv)
+struct id pv_vgid(pv_t *pv)
 {
 	return pv_field(pv, vgid);
 }
 
-struct device *get_pv_dev(pv_t *pv)
+struct device *pv_dev(pv_t *pv)
 {
 	return pv_field(pv, dev);
 }
 
-const char *get_pv_vg_name(pv_t *pv)
+const char *pv_vg_name(pv_t *pv)
 {
 	return pv_field(pv, vg_name);
 }
 
-uint64_t get_pv_size(pv_t *pv)
+uint64_t pv_size(pv_t *pv)
 {
 	return pv_field(pv, size);
 }
 
-uint32_t get_pv_status(pv_t *pv)
+uint32_t pv_status(pv_t *pv)
 {
 	return pv_field(pv, status);
 }
 
-uint32_t get_pv_pe_size(pv_t *pv)
+uint32_t pv_pe_size(pv_t *pv)
 {
 	return pv_field(pv, pe_size);
 }
 
-uint64_t get_pv_pe_start(pv_t *pv)
+uint64_t pv_pe_start(pv_t *pv)
 {
 	return pv_field(pv, pe_start);
 }
 
-uint32_t get_pv_pe_count(pv_t *pv)
+uint32_t pv_pe_count(pv_t *pv)
 {
 	return pv_field(pv, pe_count);
 }
 
-uint32_t get_pv_pe_alloc_count(pv_t *pv)
+uint32_t pv_pe_alloc_count(pv_t *pv)
 {
 	return pv_field(pv, pe_alloc_count);
 }
--- LVM2/lib/metadata/metadata.h	2007/06/14 15:48:05	1.162
+++ LVM2/lib/metadata/metadata.h	2007/06/15 22:16:55	1.163
@@ -639,16 +639,16 @@
 /*
  * Gets/Sets for external LVM library
  */
-struct id get_pv_id(pv_t *pv);
-const struct format_type *get_pv_format_type(pv_t *pv);
-struct id get_pv_vgid(pv_t *pv);
-struct device *get_pv_dev(pv_t *pv);
-const char *get_pv_vg_name(pv_t *pv);
-uint64_t get_pv_size(pv_t *pv);
-uint32_t get_pv_status(pv_t *pv);
-uint32_t get_pv_pe_size(pv_t *pv);
-uint64_t get_pv_pe_start(pv_t *pv);
-uint32_t get_pv_pe_count(pv_t *pv);
-uint32_t get_pv_pe_alloc_count(pv_t *pv);
+struct id pv_id(pv_t *pv);
+const struct format_type *pv_format_type(pv_t *pv);
+struct id pv_vgid(pv_t *pv);
+struct device *pv_dev(pv_t *pv);
+const char *pv_vg_name(pv_t *pv);
+uint64_t pv_size(pv_t *pv);
+uint32_t pv_status(pv_t *pv);
+uint32_t pv_pe_size(pv_t *pv);
+uint64_t pv_pe_start(pv_t *pv);
+uint32_t pv_pe_count(pv_t *pv);
+uint32_t pv_pe_alloc_count(pv_t *pv);
 
 #endif
--- LVM2/tools/pvchange.c	2007/06/14 15:25:35	1.50
+++ LVM2/tools/pvchange.c	2007/06/15 22:16:55	1.51
@@ -26,7 +26,7 @@
 	uint64_t sector;
 	uint32_t orig_pe_alloc_count;
 
-	const char *pv_name = dev_name(get_pv_dev(pv));
+	const char *pv_name = dev_name(pv_dev(pv));
 	const char *tag = NULL;
 	const char *orig_vg_name;
 	char uuid[64] __attribute((aligned(8)));
@@ -51,17 +51,17 @@
 	}
 
 	/* If in a VG, must change using volume group. */
-	if (*get_pv_vg_name(pv)) {
+	if (*pv_vg_name(pv)) {
 		log_verbose("Finding volume group of physical volume \"%s\"",
 			    pv_name);
 
-		if (!lock_vol(cmd, get_pv_vg_name(pv), LCK_VG_WRITE)) {
-			log_error("Can't get lock for %s", get_pv_vg_name(pv));
+		if (!lock_vol(cmd, pv_vg_name(pv), LCK_VG_WRITE)) {
+			log_error("Can't get lock for %s", pv_vg_name(pv));
 			return 0;
 		}
 
-		if (!(vg = vg_read(cmd, get_pv_vg_name(pv), NULL, &consistent))) {
-			unlock_vg(cmd, get_pv_vg_name(pv));
+		if (!(vg = vg_read(cmd, pv_vg_name(pv), NULL, &consistent))) {
+			unlock_vg(cmd, pv_vg_name(pv));
 			log_error("Unable to find volume group of \"%s\"",
 				  pv_name);
 			return 0;
@@ -69,25 +69,25 @@
 
 		if (!vg_check_status(vg,
 				     CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			return 0;
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			log_error
 			    ("Unable to find \"%s\" in volume group \"%s\"",
 			     pv_name, vg->name);
 			return 0;
 		}
 		if (tagarg && !(vg->fid->fmt->features & FMT_TAGS)) {
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			log_error("Volume group containing %s does not "
 				  "support tags", pv_name);
 			return 0;
 		}
 		if (arg_count(cmd, uuid_ARG) && lvs_in_vg_activated(vg)) {
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			log_error("Volume group containing %s has active "
 				  "logical volumes", pv_name);
 			return 0;
@@ -115,7 +115,7 @@
 	}
 
 	if (arg_count(cmd, allocatable_ARG)) {
-		if (!*get_pv_vg_name(pv) &&
+		if (!*pv_vg_name(pv) &&
 		    !(pv->fmt->features & FMT_ORPHAN_ALLOCATABLE)) {
 			log_error("Allocatability not supported by orphan "
 				  "%s format PV %s", pv->fmt->name, pv_name);
@@ -124,21 +124,21 @@
 		}
 
 		/* change allocatability for a PV */
-		if (allocatable && (get_pv_status(pv) & ALLOCATABLE_PV)) {
+		if (allocatable && (pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "allocatable", pv_name);
-			if (*get_pv_vg_name(pv))
-				unlock_vg(cmd, get_pv_vg_name(pv));
+			if (*pv_vg_name(pv))
+				unlock_vg(cmd, pv_vg_name(pv));
 			else
 				unlock_vg(cmd, ORPHAN);
 			return 1;
 		}
 
-		if (!allocatable && !(get_pv_status(pv) & ALLOCATABLE_PV)) {
+		if (!allocatable && !(pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "unallocatable", pv_name);
-			if (*get_pv_vg_name(pv))
-				unlock_vg(cmd, get_pv_vg_name(pv));
+			if (*pv_vg_name(pv))
+				unlock_vg(cmd, pv_vg_name(pv));
 			else
 				unlock_vg(cmd, ORPHAN);
 			return 1;
@@ -180,9 +180,9 @@
 			return 0;
 		}
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
-		if (*get_pv_vg_name(pv)) {
-			orig_vg_name = get_pv_vg_name(pv);
-			orig_pe_alloc_count = get_pv_pe_alloc_count(pv);
+		if (*pv_vg_name(pv)) {
+			orig_vg_name = pv_vg_name(pv);
+			orig_pe_alloc_count = pv_pe_alloc_count(pv);
 			pv->vg_name = ORPHAN;
 			pv->pe_alloc_count = 0;
 			if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
@@ -196,15 +196,15 @@
 	}
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
-	if (*get_pv_vg_name(pv)) {
+	if (*pv_vg_name(pv)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
 			return 0;
 		}
 		backup(vg);
-		unlock_vg(cmd, get_pv_vg_name(pv));
+		unlock_vg(cmd, pv_vg_name(pv));
 	} else {
 		if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
 			unlock_vg(cmd, ORPHAN);
--- LVM2/tools/pvcreate.c	2007/06/15 10:11:14	1.52
+++ LVM2/tools/pvcreate.c	2007/06/15 22:16:55	1.53
@@ -47,13 +47,13 @@
 	/* We must have -ff to overwrite a non orphan */
 	if (pv && !is_orphan(pv) && arg_count(cmd, force_ARG) != 2) {
 		log_error("Can't initialize physical volume \"%s\" of "
-			  "volume group \"%s\" without -ff", name, get_pv_vg_name(pv));
+			  "volume group \"%s\" without -ff", name, pv_vg_name(pv));
 		return 0;
 	}
 
 	/* prompt */
 	if (pv && !is_orphan(pv) && !arg_count(cmd, yes_ARG) &&
-	    yes_no_prompt(_really_init, name, get_pv_vg_name(pv)) == 'n') {
+	    yes_no_prompt(_really_init, name, pv_vg_name(pv)) == 'n') {
 		log_print("%s: physical volume not initialized", name);
 		return 0;
 	}
@@ -113,7 +113,7 @@
 		log_print("WARNING: Forcing physical volume creation on "
 			  "%s%s%s%s", name,
 			  !is_orphan(pv) ? " of volume group \"" : "",
-			  !is_orphan(pv) ? get_pv_vg_name(pv) : "",
+			  !is_orphan(pv) ? pv_vg_name(pv) : "",
 			  !is_orphan(pv) ? "\"" : "");
 	}
 
@@ -166,9 +166,9 @@
 				  uuid, restorefile);
 			return ECMD_FAILED;
 		}
-		pe_start = get_pv_pe_start(existing_pv);
-		extent_size = get_pv_pe_size(existing_pv);
-		extent_count = get_pv_pe_count(existing_pv);
+		pe_start = pv_pe_start(existing_pv);
+		extent_size = pv_pe_size(existing_pv);
+		extent_count = pv_pe_count(existing_pv);
 	}
 
 	if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
@@ -220,10 +220,10 @@
 	}
 
 	log_verbose("Set up physical volume for \"%s\" with %" PRIu64
-		    " available sectors", pv_name, get_pv_size(pv));
+		    " available sectors", pv_name, pv_size(pv));
 
 	/* Wipe existing label first */
-	if (!label_remove(get_pv_dev(pv))) {
+	if (!label_remove(pv_dev(pv))) {
 		log_error("Failed to wipe existing label on %s", pv_name);
 		goto error;
 	}
--- LVM2/tools/pvdisplay.c	2007/06/14 15:25:36	1.36
+++ LVM2/tools/pvdisplay.c	2007/06/15 22:16:55	1.37
@@ -24,16 +24,16 @@
 	int ret = ECMD_PROCESSED;
 	uint64_t size;
 
-	const char *pv_name = dev_name(get_pv_dev(pv));
+	const char *pv_name = dev_name(pv_dev(pv));
 
-	 if (get_pv_vg_name(pv)) {
-	         if (!lock_vol(cmd, get_pv_vg_name(pv), LCK_VG_READ)) {
-	                 log_error("Can't lock %s: skipping", get_pv_vg_name(pv));
+	 if (pv_vg_name(pv)) {
+	         if (!lock_vol(cmd, pv_vg_name(pv), LCK_VG_READ)) {
+	                 log_error("Can't lock %s: skipping", pv_vg_name(pv));
 	                 return ECMD_FAILED;
 	         }
 
-	         if (!(vg = vg_read(cmd, get_pv_vg_name(pv), (char *)&pv->vgid, &consistent))) {
-	                 log_error("Can't read %s: skipping", get_pv_vg_name(pv));
+	         if (!(vg = vg_read(cmd, pv_vg_name(pv), (char *)&pv->vgid, &consistent))) {
+	                 log_error("Can't read %s: skipping", pv_vg_name(pv));
 	                 goto out;
 	         }
 
@@ -56,11 +56,11 @@
 		 pv = pvl->pv;
 	}
 
-	if (!*get_pv_vg_name(pv))
-		size = get_pv_size(pv);
+	if (!*pv_vg_name(pv))
+		size = pv_size(pv);
 	else
-		size = (get_pv_pe_count(pv) - get_pv_pe_alloc_count(pv)) * 
-			get_pv_pe_size(pv);
+		size = (pv_pe_count(pv) - pv_pe_alloc_count(pv)) * 
+			pv_pe_size(pv);
 
 	if (arg_count(cmd, short_ARG)) {
 		log_print("Device \"%s\" has a capacity of %s", pv_name,
@@ -68,11 +68,11 @@
 		goto out;
 	}
 
-	if (get_pv_status(pv) & EXPORTED_VG)
+	if (pv_status(pv) & EXPORTED_VG)
 		log_print("Physical volume \"%s\" of volume group \"%s\" "
-			  "is exported", pv_name, get_pv_vg_name(pv));
+			  "is exported", pv_name, pv_vg_name(pv));
 
-	if (!get_pv_vg_name(pv))
+	if (!pv_vg_name(pv))
 		log_print("\"%s\" is a new physical volume of \"%s\"",
 			  pv_name, display_size(cmd, size));
 
@@ -87,8 +87,8 @@
 		pvdisplay_segments(pv);
 
 out:
-        if (get_pv_vg_name(pv))
-                unlock_vg(cmd, get_pv_vg_name(pv));
+        if (pv_vg_name(pv))
+                unlock_vg(cmd, pv_vg_name(pv));
 
 	return ret;
 }
--- LVM2/tools/pvmove.c	2007/06/14 15:25:36	1.37
+++ LVM2/tools/pvmove.c	2007/06/15 22:16:55	1.38
@@ -100,7 +100,7 @@
 		pvl = list_item(pvh, struct pv_list);
 
 		/* Don't allocate onto the PV we're clearing! */
-		if ((alloc != ALLOC_ANYWHERE) && (pvl->pv->dev == get_pv_dev(pv))) {
+		if ((alloc != ALLOC_ANYWHERE) && (pvl->pv->dev == pv_dev(pv))) {
 			list_del(&pvl->list);
 			continue;
 		}
@@ -281,7 +281,7 @@
 	}
 
 	if (arg_count(cmd, name_ARG)) {
-		if (!(lv_name = _extract_lvname(cmd, get_pv_vg_name(pv),
+		if (!(lv_name = _extract_lvname(cmd, pv_vg_name(pv),
 						arg_value(cmd, name_ARG)))) {
 			stack;
 			return EINVALID_CMD_LINE;
@@ -289,14 +289,14 @@
 	}
 
 	/* Read VG */
-	log_verbose("Finding volume group \"%s\"", get_pv_vg_name(pv));
+	log_verbose("Finding volume group \"%s\"", pv_vg_name(pv));
 
-	if (!(vg = _get_vg(cmd, get_pv_vg_name(pv)))) {
+	if (!(vg = _get_vg(cmd, pv_vg_name(pv)))) {
 		stack;
 		return ECMD_FAILED;
 	}
 
-	if ((lv_mirr = find_pvmove_lv(vg, get_pv_dev(pv), PVMOVE))) {
+	if ((lv_mirr = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
 		log_print("Detected pvmove in progress for %s", pv_name);
 		if (argc || lv_name)
 			log_error("Ignoring remaining command line arguments");
@@ -304,7 +304,7 @@
 		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
 			log_error
 			    ("ABORTING: Failed to generate list of moving LVs");
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
@@ -312,7 +312,7 @@
 		if (!activate_lv_excl(cmd, lv_mirr)) {
 			log_error
 			    ("ABORTING: Temporary mirror activation failed.");
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
@@ -322,7 +322,7 @@
 		if (!(source_pvl = create_pv_list(cmd->mem, vg, 1,
 						  &pv_name_arg, 0))) {
 			stack;
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
@@ -334,12 +334,12 @@
 		if (!(allocatable_pvs = _get_allocatable_pvs(cmd, argc, argv,
 							     vg, pv, alloc))) {
 			stack;
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
 		if (!archive(vg)) {
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			stack;
 			return ECMD_FAILED;
 		}
@@ -348,7 +348,7 @@
 						  allocatable_pvs, alloc,
 						  &lvs_changed))) {
 			stack;
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 	}
@@ -356,7 +356,7 @@
 	/* Lock lvs_changed for exclusive use and activate (with old metadata) */
 	if (!activate_lvs_excl(cmd, lvs_changed)) {
 		stack;
-		unlock_vg(cmd, get_pv_vg_name(pv));
+		unlock_vg(cmd, pv_vg_name(pv));
 		return ECMD_FAILED;
 	}
 
@@ -368,13 +368,13 @@
 		if (!_update_metadata
 		    (cmd, vg, lv_mirr, lvs_changed, first_time)) {
 			stack;
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 	}
 
 	/* LVs are all in status LOCKED */
-	unlock_vg(cmd, get_pv_vg_name(pv));
+	unlock_vg(cmd, pv_vg_name(pv));
 
 	return ECMD_PROCESSED;
 }
@@ -469,7 +469,7 @@
 		return NULL;
 	}
 
-	return _get_vg(cmd, get_pv_vg_name(pv));
+	return _get_vg(cmd, pv_vg_name(pv));
 }
 
 static struct poll_functions _pvmove_fns = {
--- LVM2/tools/pvremove.c	2007/06/14 15:51:36	1.16
+++ LVM2/tools/pvremove.c	2007/06/15 22:16:55	1.17
@@ -50,13 +50,13 @@
 	/* we must have -ff to overwrite a non orphan */
 	if (arg_count(cmd, force_ARG) < 2) {
 		log_error("Can't pvremove physical volume \"%s\" of "
-			  "volume group \"%s\" without -ff", name, get_pv_vg_name(pv));
+			  "volume group \"%s\" without -ff", name, pv_vg_name(pv));
 		return 0;
 	}
 
 	/* prompt */
 	if (!arg_count(cmd, yes_ARG) &&
-	    yes_no_prompt(_really_wipe, name, get_pv_vg_name(pv)) == 'n') {
+	    yes_no_prompt(_really_wipe, name, pv_vg_name(pv)) == 'n') {
 		log_print("%s: physical volume label not removed", name);
 		return 0;
 	}
@@ -65,7 +65,7 @@
 		log_print("WARNING: Wiping physical volume label from "
 			  "%s%s%s%s", name,
 			  !is_orphan(pv) ? " of volume group \"" : "",
-			  !is_orphan(pv) ? get_pv_vg_name(pv) : "",
+			  !is_orphan(pv) ? pv_vg_name(pv) : "",
 			  !is_orphan(pv) ? "\"" : "");
 	}
 
--- LVM2/tools/pvresize.c	2007/06/14 15:25:36	1.10
+++ LVM2/tools/pvresize.c	2007/06/15 22:16:55	1.11
@@ -33,7 +33,7 @@
 	uint64_t size = 0;
 	uint32_t new_pe_count = 0;
 	struct list mdas;
-	const char *pv_name = dev_name(get_pv_dev(pv));
+	const char *pv_name = dev_name(pv_dev(pv));
 	struct pvresize_params *params = (struct pvresize_params *) handle;
 	const char *vg_name;
 
@@ -41,7 +41,7 @@
 
 	params->total++;
 
-	if (!*get_pv_vg_name(pv)) {
+	if (!*pv_vg_name(pv)) {
 		vg_name = ORPHAN;
 
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
@@ -63,10 +63,10 @@
 			return ECMD_FAILED;
 		}
 	} else {
-		vg_name = get_pv_vg_name(pv);
+		vg_name = pv_vg_name(pv);
 
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for %s", get_pv_vg_name(pv));
+			log_error("Can't get lock for %s", pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
@@ -103,7 +103,7 @@
 	}
 
 	/* Get new size */
-	if (!dev_get_size(get_pv_dev(pv), &size)) {
+	if (!dev_get_size(pv_dev(pv), &size)) {
 		log_error("%s: Couldn't get size.", pv_name);
 		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
@@ -114,7 +114,7 @@
 			log_print("WARNING: %s: Overriding real size. "
 				  "You could lose data.", pv_name);
 		log_verbose("%s: Pretending size is %" PRIu64 " not %" PRIu64
-			    " sectors.", pv_name, params->new_size, get_pv_size(pv));
+			    " sectors.", pv_name, params->new_size, pv_size(pv));
 		size = params->new_size;
 	}
 
@@ -125,9 +125,9 @@
 		return ECMD_FAILED;
 	}
 
-	if (size < get_pv_pe_start(pv)) {
+	if (size < pv_pe_start(pv)) {
 		log_error("%s: Size must exceed physical extent start of "
-			  "%" PRIu64 " sectors.", pv_name, get_pv_pe_start(pv));
+			  "%" PRIu64 " sectors.", pv_name, pv_pe_start(pv));
 		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
 	}
@@ -135,14 +135,14 @@
 	pv->size = size;
 
 	if (vg) {
-		pv->size -= get_pv_pe_start(pv);
-		new_pe_count = get_pv_size(pv) / vg->extent_size;
+		pv->size -= pv_pe_start(pv);
+		new_pe_count = pv_size(pv) / vg->extent_size;
 		
  		if (!new_pe_count) {
 			log_error("%s: Size must leave space for at "
 				  "least one physical extent of "
 				  "%" PRIu32 " sectors.", pv_name,
-				  get_pv_pe_size(pv));
+				  pv_pe_size(pv));
 			unlock_vg(cmd, vg_name);
 			return ECMD_FAILED;
 		}
@@ -155,12 +155,12 @@
 	}
 
 	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
-		    pv_name, get_pv_size(pv));
+		    pv_name, pv_size(pv));
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
-	if (*get_pv_vg_name(pv)) {
+	if (*pv_vg_name(pv)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
-			unlock_vg(cmd, get_pv_vg_name(pv));
+			unlock_vg(cmd, pv_vg_name(pv));
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
 			return ECMD_FAILED;
--- LVM2/tools/pvscan.c	2007/06/14 15:25:36	1.38
+++ LVM2/tools/pvscan.c	2007/06/15 22:16:55	1.39
@@ -31,7 +31,7 @@
 
 	/* short listing? */
 	if (arg_count(cmd, short_ARG) > 0) {
-		log_print("%s", dev_name(get_pv_dev(pv)));
+		log_print("%s", dev_name(pv_dev(pv)));
 		return;
 	}
 
@@ -48,7 +48,7 @@
 
 	memset(pv_tmp_name, 0, sizeof(pv_tmp_name));
 
-	vg_name_len = strlen(get_pv_vg_name(pv)) + 1;
+	vg_name_len = strlen(pv_vg_name(pv)) + 1;
 
 	if (arg_count(cmd, uuid_ARG)) {
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
@@ -57,43 +57,43 @@
 		}
 
 		sprintf(pv_tmp_name, "%-*s with UUID %s",
-			pv_max_name_len - 2, dev_name(get_pv_dev(pv)), uuid);
+			pv_max_name_len - 2, dev_name(pv_dev(pv)), uuid);
 	} else {
-		sprintf(pv_tmp_name, "%s", dev_name(get_pv_dev(pv)));
+		sprintf(pv_tmp_name, "%s", dev_name(pv_dev(pv)));
 	}
 
-	if (!*get_pv_vg_name(pv)) {
+	if (!*pv_vg_name(pv)) {
 		log_print("PV %-*s    %-*s %s [%s]",
 			  pv_max_name_len, pv_tmp_name,
 			  vg_max_name_len, " ",
 			  pv->fmt ? pv->fmt->name : "    ",
-			  display_size(cmd, get_pv_size(pv)));
+			  display_size(cmd, pv_size(pv)));
 		return;
 	}
 
-	if (get_pv_status(pv) & EXPORTED_VG) {
-		strncpy(vg_name_this, get_pv_vg_name(pv), vg_name_len);
+	if (pv_status(pv) & EXPORTED_VG) {
+		strncpy(vg_name_this, pv_vg_name(pv), vg_name_len);
 		log_print("PV %-*s  is in exported VG %s "
 			  "[%s / %s free]",
 			  pv_max_name_len, pv_tmp_name,
 			  vg_name_this,
-			  display_size(cmd, (uint64_t) get_pv_pe_count(pv) *
-				       get_pv_pe_size(pv)),
-			  display_size(cmd, (uint64_t) (get_pv_pe_count(pv) -
-						get_pv_pe_alloc_count(pv))
-				       * get_pv_pe_size(pv)));
+			  display_size(cmd, (uint64_t) pv_pe_count(pv) *
+				       pv_pe_size(pv)),
+			  display_size(cmd, (uint64_t) (pv_pe_count(pv) -
+						pv_pe_alloc_count(pv))
+				       * pv_pe_size(pv)));
 		return;
 	}
 
-	sprintf(vg_tmp_name, "%s", get_pv_vg_name(pv));
+	sprintf(vg_tmp_name, "%s", pv_vg_name(pv));
 	log_print("PV %-*s VG %-*s %s [%s / %s free]", pv_max_name_len,
 		  pv_tmp_name, vg_max_name_len, vg_tmp_name,
 		  pv->fmt ? pv->fmt->name : "    ",
-		  display_size(cmd, (uint64_t) get_pv_pe_count(pv) * 
-					       get_pv_pe_size(pv)),
-		  display_size(cmd, (uint64_t) (get_pv_pe_count(pv) - 
-						get_pv_pe_alloc_count(pv)) *
-					   get_pv_pe_size(pv)));
+		  display_size(cmd, (uint64_t) pv_pe_count(pv) * 
+					       pv_pe_size(pv)),
+		  display_size(cmd, (uint64_t) (pv_pe_count(pv) - 
+						pv_pe_alloc_count(pv)) *
+					   pv_pe_size(pv)));
 	return;
 }
 
@@ -136,8 +136,8 @@
 		pv = pvl->pv;
 
 		if ((arg_count(cmd, exported_ARG)
-		     && !(get_pv_status(pv) & EXPORTED_VG))
-		    || (arg_count(cmd, novolumegroup_ARG) && (*get_pv_vg_name(pv)))) {
+		     && !(pv_status(pv) & EXPORTED_VG))
+		    || (arg_count(cmd, novolumegroup_ARG) && (*pv_vg_name(pv)))) {
 			list_del(&pvl->list);
 			continue;
 		}
@@ -154,22 +154,22 @@
 ********/
 		pvs_found++;
 
-		if (!*get_pv_vg_name(pv)) {
+		if (!*pv_vg_name(pv)) {
 			new_pvs_found++;
-			size_new += get_pv_size(pv);
-			size_total += get_pv_size(pv);
+			size_new += pv_size(pv);
+			size_total += pv_size(pv);
 		} else
-			size_total += get_pv_pe_count(pv) * get_pv_pe_size(pv);
+			size_total += pv_pe_count(pv) * pv_pe_size(pv);
 	}
 
 	/* find maximum pv name length */
 	pv_max_name_len = vg_max_name_len = 0;
 	list_iterate_items(pvl, pvslist) {
 		pv = pvl->pv;
-		len = strlen(dev_name(get_pv_dev(pv)));
+		len = strlen(dev_name(pv_dev(pv)));
 		if (pv_max_name_len < len)
 			pv_max_name_len = len;
-		len = strlen(get_pv_vg_name(pv));
+		len = strlen(pv_vg_name(pv));
 		if (vg_max_name_len < len)
 			vg_max_name_len = len;
 	}
--- LVM2/tools/reporter.c	2007/06/14 15:25:36	1.24
+++ LVM2/tools/reporter.c	2007/06/15 22:16:55	1.25
@@ -61,13 +61,13 @@
 	struct physical_volume *pv = pvseg->pv;
 	int ret = ECMD_PROCESSED;
 
-	if (!lock_vol(cmd, get_pv_vg_name(pv), LCK_VG_READ)) {
-		log_error("Can't lock %s: skipping", get_pv_vg_name(pv));
+	if (!lock_vol(cmd, pv_vg_name(pv), LCK_VG_READ)) {
+		log_error("Can't lock %s: skipping", pv_vg_name(pv));
 		return ECMD_FAILED;
 	}
 
-	if (!(vg = vg_read(cmd, get_pv_vg_name(pv), NULL, &consistent))) {
-		log_error("Can't read %s: skipping", get_pv_vg_name(pv));
+	if (!(vg = vg_read(cmd, pv_vg_name(pv), NULL, &consistent))) {
+		log_error("Can't read %s: skipping", pv_vg_name(pv));
 		goto out;
 	}
 
@@ -80,7 +80,7 @@
 		ret = ECMD_FAILED;
 
 out:
-	unlock_vg(cmd, get_pv_vg_name(pv));
+	unlock_vg(cmd, pv_vg_name(pv));
 	return ret;
 }
 
@@ -106,14 +106,14 @@
 	int consistent = 0;
 	int ret = ECMD_PROCESSED;
 
-	if (get_pv_vg_name(pv)) {
-		if (!lock_vol(cmd, get_pv_vg_name(pv), LCK_VG_READ)) {
-			log_error("Can't lock %s: skipping", get_pv_vg_name(pv));
+	if (pv_vg_name(pv)) {
+		if (!lock_vol(cmd, pv_vg_name(pv), LCK_VG_READ)) {
+			log_error("Can't lock %s: skipping", pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
-		if (!(vg = vg_read(cmd, get_pv_vg_name(pv), (char *)&pv->vgid, &consistent))) {
-			log_error("Can't read %s: skipping", get_pv_vg_name(pv));
+		if (!(vg = vg_read(cmd, pv_vg_name(pv), (char *)&pv->vgid, &consistent))) {
+			log_error("Can't read %s: skipping", pv_vg_name(pv));
 			goto out;
 		}
 
@@ -127,8 +127,8 @@
 		ret = ECMD_FAILED;
 
 out:
-	if (get_pv_vg_name(pv))
-		unlock_vg(cmd, get_pv_vg_name(pv));
+	if (pv_vg_name(pv))
+		unlock_vg(cmd, pv_vg_name(pv));
 
 	return ret;
 }
--- LVM2/tools/vgconvert.c	2007/06/13 23:29:33	1.21
+++ LVM2/tools/vgconvert.c	2007/06/15 22:16:55	1.22
@@ -114,18 +114,18 @@
 	list_iterate_items(pvl, &vg->pvs) {
 		existing_pv = pvl->pv;
 
-		pe_start = get_pv_pe_start(existing_pv);
-		pe_end = get_pv_pe_count(existing_pv) * get_pv_pe_size(existing_pv)
+		pe_start = pv_pe_start(existing_pv);
+		pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv)
 		    + pe_start - 1;
 
 		list_init(&mdas);
-		if (!(pv = pv_create(cmd->fmt, get_pv_dev(existing_pv),
+		if (!(pv = pv_create(cmd->fmt, pv_dev(existing_pv),
 				     &existing_pv->id, size,
-				     pe_start, get_pv_pe_count(existing_pv),
-				     get_pv_pe_size(existing_pv), pvmetadatacopies,
+				     pe_start, pv_pe_count(existing_pv),
+				     pv_pe_size(existing_pv), pvmetadatacopies,
 				     pvmetadatasize, &mdas))) {
 			log_error("Failed to setup physical volume \"%s\"",
-				  dev_name(get_pv_dev(existing_pv)));
+				  dev_name(pv_dev(existing_pv)));
 			if (change_made)
 				log_error("Use pvcreate and vgcfgrestore to "
 					  "repair from archived metadata.");
@@ -136,30 +136,30 @@
 		change_made = 1;
 
 		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
-			    " available sectors", dev_name(get_pv_dev(pv)), get_pv_size(pv));
+			    " available sectors", dev_name(pv_dev(pv)), pv_size(pv));
 
 		/* Wipe existing label first */
-		if (!label_remove(get_pv_dev(pv))) {
+		if (!label_remove(pv_dev(pv))) {
 			log_error("Failed to wipe existing label on %s",
-				  dev_name(get_pv_dev(pv)));
+				  dev_name(pv_dev(pv)));
 			log_error("Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
 			return ECMD_FAILED;
 		}
 
 		log_very_verbose("Writing physical volume data to disk \"%s\"",
-				 dev_name(get_pv_dev(pv)));
+				 dev_name(pv_dev(pv)));
 		if (!(pv_write(cmd, pv, &mdas,
 			       arg_int64_value(cmd, labelsector_ARG,
 					       DEFAULT_LABELSECTOR)))) {
 			log_error("Failed to write physical volume \"%s\"",
-				  dev_name(get_pv_dev(pv)));
+				  dev_name(pv_dev(pv)));
 			log_error("Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
 			return ECMD_FAILED;
 		}
 		log_verbose("Physical volume \"%s\" successfully created",
-			    dev_name(get_pv_dev(pv)));
+			    dev_name(pv_dev(pv)));
 
 	}
 
--- LVM2/tools/vgreduce.c	2007/06/13 23:29:33	1.63
+++ LVM2/tools/vgreduce.c	2007/06/15 22:16:55	1.64
@@ -185,7 +185,7 @@
 				/* FIXME Also check for segs on deleted LVs */
 
 				pv = seg_pv(seg, s);
-				if (!pv || !get_pv_dev(pv)) {
+				if (!pv || !pv_dev(pv)) {
 					if (arg_count(cmd, mirrorsonly_ARG) &&
 					    !(lv->status & MIRROR_IMAGE)) {
 						log_error("Non-mirror-image LV %s found: can't remove.", lv->name);
@@ -365,9 +365,9 @@
 			    void *handle __attribute((unused)))
 {
 	struct pv_list *pvl;
-	const char *name = dev_name(get_pv_dev(pv));
+	const char *name = dev_name(pv_dev(pv));
 
-	if (get_pv_pe_alloc_count(pv)) {
+	if (pv_pe_alloc_count(pv)) {
 		log_error("Physical volume \"%s\" still in use", name);
 		return ECMD_FAILED;
 	}
@@ -391,14 +391,14 @@
 	pv->vg_name = ORPHAN;
 	pv->status = ALLOCATABLE_PV;
 
-	if (!dev_get_size(get_pv_dev(pv), &pv->size)) {
-		log_error("%s: Couldn't get size.", dev_name(get_pv_dev(pv)));
+	if (!dev_get_size(pv_dev(pv), &pv->size)) {
+		log_error("%s: Couldn't get size.", dev_name(pv_dev(pv)));
 		return ECMD_FAILED;
 	}
 
 	vg->pv_count--;
-	vg->free_count -= get_pv_pe_count(pv) - get_pv_pe_alloc_count(pv);
-	vg->extent_count -= get_pv_pe_count(pv);
+	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
+	vg->extent_count -= pv_pe_count(pv);
 
 	if (!vg_write(vg) || !vg_commit(vg)) {
 		log_error("Removal of physical volume \"%s\" from "
--- LVM2/tools/vgremove.c	2007/06/13 23:29:33	1.39
+++ LVM2/tools/vgremove.c	2007/06/15 22:16:55	1.40
@@ -54,12 +54,12 @@
 	list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 		log_verbose("Removing physical volume \"%s\" from "
-			    "volume group \"%s\"", dev_name(get_pv_dev(pv)), vg_name);
+			    "volume group \"%s\"", dev_name(pv_dev(pv)), vg_name);
 		pv->vg_name = ORPHAN;
 		pv->status = ALLOCATABLE_PV;
 
-		if (!dev_get_size(get_pv_dev(pv), &pv->size)) {
-			log_error("%s: Couldn't get size.", dev_name(get_pv_dev(pv)));
+		if (!dev_get_size(pv_dev(pv), &pv->size)) {
+			log_error("%s: Couldn't get size.", dev_name(pv_dev(pv)));
 			ret = ECMD_FAILED;
 			continue;
 		}
@@ -68,7 +68,7 @@
 		if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
 			log_error("Failed to remove physical volume \"%s\""
 				  " from volume group \"%s\"",
-				  dev_name(get_pv_dev(pv)), vg_name);
+				  dev_name(pv_dev(pv)), vg_name);
 			ret = ECMD_FAILED;
 		}
 	}
--- LVM2/tools/vgsplit.c	2007/06/13 23:29:33	1.29
+++ LVM2/tools/vgsplit.c	2007/06/15 22:16:55	1.30
@@ -35,11 +35,11 @@
 
 	pv = list_item(pvl, struct pv_list)->pv;
 
-	vg_from->extent_count -= get_pv_pe_count(pv);
-	vg_to->extent_count += get_pv_pe_count(pv);
+	vg_from->extent_count -= pv_pe_count(pv);
+	vg_to->extent_count += pv_pe_count(pv);
 
-	vg_from->free_count -= get_pv_pe_count(pv) - get_pv_pe_alloc_count(pv);
-	vg_to->free_count += get_pv_pe_count(pv) - get_pv_pe_alloc_count(pv);
+	vg_from->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
+	vg_to->free_count += pv_pe_count(pv) - pv_pe_alloc_count(pv);
 
 	return 1;
 }
@@ -105,7 +105,7 @@
 					continue;
 				}
 				log_error("Physical Volume %s not found",
-					  dev_name(get_pv_dev(pv)));
+					  dev_name(pv_dev(pv)));
 				return 0;
 			}
 


