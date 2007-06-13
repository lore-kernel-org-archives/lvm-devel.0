From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 23:53:39 -0000
Subject: LVM2/tools reporter.c pvscan.c pvresize.c pvre ...
Message-ID: <20070613235339.26357.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 23:53:38

Modified files:
	tools          : reporter.c pvscan.c pvresize.c pvremove.c 
	                 pvmove.c pvdisplay.c pvcreate.c pvchange.c 

Log message:
	Convert pv->vg_name to get_pv_vg_name

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/tools/reporter.c	2007/06/06 19:40:28	1.22
+++ LVM2/tools/reporter.c	2007/06/13 23:53:38	1.23
@@ -62,12 +62,12 @@
 	int ret = ECMD_PROCESSED;
 
 	if (!lock_vol(cmd, pv->vg_name, LCK_VG_READ)) {
-		log_error("Can't lock %s: skipping", pv->vg_name);
+		log_error("Can't lock %s: skipping", get_pv_vg_name(pv));
 		return ECMD_FAILED;
 	}
 
 	if (!(vg = vg_read(cmd, pv->vg_name, NULL, &consistent))) {
-		log_error("Can't read %s: skipping", pv->vg_name);
+		log_error("Can't read %s: skipping", get_pv_vg_name(pv));
 		goto out;
 	}
 
@@ -80,7 +80,7 @@
 		ret = ECMD_FAILED;
 
 out:
-	unlock_vg(cmd, pv->vg_name);
+	unlock_vg(cmd, get_pv_vg_name(pv));
 	return ret;
 }
 
@@ -106,14 +106,14 @@
 	int consistent = 0;
 	int ret = ECMD_PROCESSED;
 
-	if (pv->vg_name) {
+	if (get_pv_vg_name(pv)) {
 		if (!lock_vol(cmd, pv->vg_name, LCK_VG_READ)) {
-			log_error("Can't lock %s: skipping", pv->vg_name);
+			log_error("Can't lock %s: skipping", get_pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
 		if (!(vg = vg_read(cmd, pv->vg_name, (char *)&pv->vgid, &consistent))) {
-			log_error("Can't read %s: skipping", pv->vg_name);
+			log_error("Can't read %s: skipping", get_pv_vg_name(pv));
 			goto out;
 		}
 
@@ -127,8 +127,8 @@
 		ret = ECMD_FAILED;
 
 out:
-	if (pv->vg_name)
-		unlock_vg(cmd, pv->vg_name);
+	if (get_pv_vg_name(pv))
+		unlock_vg(cmd, get_pv_vg_name(pv));
 
 	return ret;
 }
--- LVM2/tools/pvscan.c	2007/06/13 23:33:45	1.36
+++ LVM2/tools/pvscan.c	2007/06/13 23:53:38	1.37
@@ -48,7 +48,7 @@
 
 	memset(pv_tmp_name, 0, sizeof(pv_tmp_name));
 
-	vg_name_len = strlen(pv->vg_name) + 1;
+	vg_name_len = strlen(get_pv_vg_name(pv)) + 1;
 
 	if (arg_count(cmd, uuid_ARG)) {
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
@@ -62,7 +62,7 @@
 		sprintf(pv_tmp_name, "%s", dev_name(get_pv_dev(pv)));
 	}
 
-	if (!*pv->vg_name) {
+	if (!*get_pv_vg_name(pv)) {
 		log_print("PV %-*s    %-*s %s [%s]",
 			  pv_max_name_len, pv_tmp_name,
 			  vg_max_name_len, " ",
@@ -85,7 +85,7 @@
 		return;
 	}
 
-	sprintf(vg_tmp_name, "%s", pv->vg_name);
+	sprintf(vg_tmp_name, "%s", get_pv_vg_name(pv));
 	log_print("PV %-*s VG %-*s %s [%s / %s free]", pv_max_name_len,
 		  pv_tmp_name, vg_max_name_len, vg_tmp_name,
 		  pv->fmt ? pv->fmt->name : "    ",
@@ -137,7 +137,7 @@
 
 		if ((arg_count(cmd, exported_ARG)
 		     && !(get_pv_status(pv) & EXPORTED_VG))
-		    || (arg_count(cmd, novolumegroup_ARG) && (*pv->vg_name))) {
+		    || (arg_count(cmd, novolumegroup_ARG) && (*get_pv_vg_name(pv)))) {
 			list_del(&pvl->list);
 			continue;
 		}
@@ -154,7 +154,7 @@
 ********/
 		pvs_found++;
 
-		if (!*pv->vg_name) {
+		if (!*get_pv_vg_name(pv)) {
 			new_pvs_found++;
 			size_new += get_pv_size(pv);
 			size_total += get_pv_size(pv);
@@ -169,7 +169,7 @@
 		len = strlen(dev_name(get_pv_dev(pv)));
 		if (pv_max_name_len < len)
 			pv_max_name_len = len;
-		len = strlen(pv->vg_name);
+		len = strlen(get_pv_vg_name(pv));
 		if (vg_max_name_len < len)
 			vg_max_name_len = len;
 	}
--- LVM2/tools/pvresize.c	2007/06/13 23:29:33	1.8
+++ LVM2/tools/pvresize.c	2007/06/13 23:53:38	1.9
@@ -41,7 +41,7 @@
 
 	params->total++;
 
-	if (!*pv->vg_name) {
+	if (!*get_pv_vg_name(pv)) {
 		vg_name = ORPHAN;
 
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
@@ -66,7 +66,7 @@
 		vg_name = pv->vg_name;
 
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for %s", pv->vg_name);
+			log_error("Can't get lock for %s", get_pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
@@ -158,9 +158,9 @@
 		    pv_name, get_pv_size(pv));
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
-	if (*pv->vg_name) {
+	if (*get_pv_vg_name(pv)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
 			return ECMD_FAILED;
--- LVM2/tools/pvremove.c	2006/12/13 18:40:23	1.12
+++ LVM2/tools/pvremove.c	2007/06/13 23:53:38	1.13
@@ -50,13 +50,13 @@
 	/* we must have -ff to overwrite a non orphan */
 	if (arg_count(cmd, force_ARG) < 2) {
 		log_error("Can't pvremove physical volume \"%s\" of "
-			  "volume group \"%s\" without -ff", name, pv->vg_name);
+			  "volume group \"%s\" without -ff", name, get_pv_vg_name(pv));
 		return 0;
 	}
 
 	/* prompt */
 	if (!arg_count(cmd, yes_ARG) &&
-	    yes_no_prompt(_really_wipe, name, pv->vg_name) == 'n') {
+	    yes_no_prompt(_really_wipe, name, get_pv_vg_name(pv)) == 'n') {
 		log_print("%s: physical volume label not removed", name);
 		return 0;
 	}
--- LVM2/tools/pvmove.c	2007/06/13 23:29:33	1.35
+++ LVM2/tools/pvmove.c	2007/06/13 23:53:38	1.36
@@ -289,9 +289,9 @@
 	}
 
 	/* Read VG */
-	log_verbose("Finding volume group \"%s\"", pv->vg_name);
+	log_verbose("Finding volume group \"%s\"", get_pv_vg_name(pv));
 
-	if (!(vg = _get_vg(cmd, pv->vg_name))) {
+	if (!(vg = _get_vg(cmd, get_pv_vg_name(pv)))) {
 		stack;
 		return ECMD_FAILED;
 	}
@@ -304,7 +304,7 @@
 		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
 			log_error
 			    ("ABORTING: Failed to generate list of moving LVs");
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
@@ -312,7 +312,7 @@
 		if (!activate_lv_excl(cmd, lv_mirr)) {
 			log_error
 			    ("ABORTING: Temporary mirror activation failed.");
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
@@ -322,7 +322,7 @@
 		if (!(source_pvl = create_pv_list(cmd->mem, vg, 1,
 						  &pv_name_arg, 0))) {
 			stack;
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
@@ -334,12 +334,12 @@
 		if (!(allocatable_pvs = _get_allocatable_pvs(cmd, argc, argv,
 							     vg, pv, alloc))) {
 			stack;
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 
 		if (!archive(vg)) {
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			stack;
 			return ECMD_FAILED;
 		}
@@ -348,7 +348,7 @@
 						  allocatable_pvs, alloc,
 						  &lvs_changed))) {
 			stack;
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 	}
@@ -356,7 +356,7 @@
 	/* Lock lvs_changed for exclusive use and activate (with old metadata) */
 	if (!activate_lvs_excl(cmd, lvs_changed)) {
 		stack;
-		unlock_vg(cmd, pv->vg_name);
+		unlock_vg(cmd, get_pv_vg_name(pv));
 		return ECMD_FAILED;
 	}
 
@@ -368,13 +368,13 @@
 		if (!_update_metadata
 		    (cmd, vg, lv_mirr, lvs_changed, first_time)) {
 			stack;
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			return ECMD_FAILED;
 		}
 	}
 
 	/* LVs are all in status LOCKED */
-	unlock_vg(cmd, pv->vg_name);
+	unlock_vg(cmd, get_pv_vg_name(pv));
 
 	return ECMD_PROCESSED;
 }
@@ -469,7 +469,7 @@
 		return NULL;
 	}
 
-	return _get_vg(cmd, pv->vg_name);
+	return _get_vg(cmd, get_pv_vg_name(pv));
 }
 
 static struct poll_functions _pvmove_fns = {
--- LVM2/tools/pvdisplay.c	2007/06/13 23:33:45	1.34
+++ LVM2/tools/pvdisplay.c	2007/06/13 23:53:38	1.35
@@ -26,14 +26,14 @@
 
 	const char *pv_name = dev_name(get_pv_dev(pv));
 
-	 if (pv->vg_name) {
+	 if (get_pv_vg_name(pv)) {
 	         if (!lock_vol(cmd, pv->vg_name, LCK_VG_READ)) {
-	                 log_error("Can't lock %s: skipping", pv->vg_name);
+	                 log_error("Can't lock %s: skipping", get_pv_vg_name(pv));
 	                 return ECMD_FAILED;
 	         }
 
 	         if (!(vg = vg_read(cmd, pv->vg_name, (char *)&pv->vgid, &consistent))) {
-	                 log_error("Can't read %s: skipping", pv->vg_name);
+	                 log_error("Can't read %s: skipping", get_pv_vg_name(pv));
 	                 goto out;
 	         }
 
@@ -56,7 +56,7 @@
 		 pv = pvl->pv;
 	}
 
-	if (!*pv->vg_name)
+	if (!*get_pv_vg_name(pv))
 		size = get_pv_size(pv);
 	else
 		size = (get_pv_pe_count(pv) - get_pv_pe_alloc_count(pv)) * 
@@ -70,9 +70,9 @@
 
 	if (get_pv_status(pv) & EXPORTED_VG)
 		log_print("Physical volume \"%s\" of volume group \"%s\" "
-			  "is exported", pv_name, pv->vg_name);
+			  "is exported", pv_name, get_pv_vg_name(pv));
 
-	if (!pv->vg_name)
+	if (!get_pv_vg_name(pv))
 		log_print("\"%s\" is a new physical volume of \"%s\"",
 			  pv_name, display_size(cmd, size));
 
@@ -87,8 +87,8 @@
 		pvdisplay_segments(pv);
 
 out:
-        if (pv->vg_name)
-                unlock_vg(cmd, pv->vg_name);
+        if (get_pv_vg_name(pv))
+                unlock_vg(cmd, get_pv_vg_name(pv));
 
 	return ret;
 }
--- LVM2/tools/pvcreate.c	2007/06/12 22:41:27	1.49
+++ LVM2/tools/pvcreate.c	2007/06/13 23:53:38	1.50
@@ -47,13 +47,13 @@
 	/* We must have -ff to overwrite a non orphan */
 	if (pv && pv->vg_name[0] && arg_count(cmd, force_ARG) != 2) {
 		log_error("Can't initialize physical volume \"%s\" of "
-			  "volume group \"%s\" without -ff", name, pv->vg_name);
+			  "volume group \"%s\" without -ff", name, get_pv_vg_name(pv));
 		return 0;
 	}
 
 	/* prompt */
 	if (pv && pv->vg_name[0] && !arg_count(cmd, yes_ARG) &&
-	    yes_no_prompt(_really_init, name, pv->vg_name) == 'n') {
+	    yes_no_prompt(_really_init, name, get_pv_vg_name(pv)) == 'n') {
 		log_print("%s: physical volume not initialized", name);
 		return 0;
 	}
--- LVM2/tools/pvchange.c	2007/06/13 23:33:45	1.48
+++ LVM2/tools/pvchange.c	2007/06/13 23:53:38	1.49
@@ -51,17 +51,17 @@
 	}
 
 	/* If in a VG, must change using volume group. */
-	if (*pv->vg_name) {
+	if (*get_pv_vg_name(pv)) {
 		log_verbose("Finding volume group of physical volume \"%s\"",
 			    pv_name);
 
 		if (!lock_vol(cmd, pv->vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for %s", pv->vg_name);
+			log_error("Can't get lock for %s", get_pv_vg_name(pv));
 			return 0;
 		}
 
 		if (!(vg = vg_read(cmd, pv->vg_name, NULL, &consistent))) {
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			log_error("Unable to find volume group of \"%s\"",
 				  pv_name);
 			return 0;
@@ -69,25 +69,25 @@
 
 		if (!vg_check_status(vg,
 				     CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			return 0;
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			log_error
 			    ("Unable to find \"%s\" in volume group \"%s\"",
 			     pv_name, vg->name);
 			return 0;
 		}
 		if (tagarg && !(vg->fid->fmt->features & FMT_TAGS)) {
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			log_error("Volume group containing %s does not "
 				  "support tags", pv_name);
 			return 0;
 		}
 		if (arg_count(cmd, uuid_ARG) && lvs_in_vg_activated(vg)) {
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			log_error("Volume group containing %s has active "
 				  "logical volumes", pv_name);
 			return 0;
@@ -127,8 +127,8 @@
 		if (allocatable && (get_pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "allocatable", pv_name);
-			if (*pv->vg_name)
-				unlock_vg(cmd, pv->vg_name);
+			if (*get_pv_vg_name(pv))
+				unlock_vg(cmd, get_pv_vg_name(pv));
 			else
 				unlock_vg(cmd, ORPHAN);
 			return 1;
@@ -137,8 +137,8 @@
 		if (!allocatable && !(get_pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "unallocatable", pv_name);
-			if (*pv->vg_name)
-				unlock_vg(cmd, pv->vg_name);
+			if (*get_pv_vg_name(pv))
+				unlock_vg(cmd, get_pv_vg_name(pv));
 			else
 				unlock_vg(cmd, ORPHAN);
 			return 1;
@@ -180,7 +180,7 @@
 			return 0;
 		}
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
-		if (*pv->vg_name) {
+		if (*get_pv_vg_name(pv)) {
 			orig_vg_name = pv->vg_name;
 			orig_pe_alloc_count = get_pv_pe_alloc_count(pv);
 			pv->vg_name = ORPHAN;
@@ -196,15 +196,15 @@
 	}
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
-	if (*pv->vg_name) {
+	if (*get_pv_vg_name(pv)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
-			unlock_vg(cmd, pv->vg_name);
+			unlock_vg(cmd, get_pv_vg_name(pv));
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
 			return 0;
 		}
 		backup(vg);
-		unlock_vg(cmd, pv->vg_name);
+		unlock_vg(cmd, get_pv_vg_name(pv));
 	} else {
 		if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
 			unlock_vg(cmd, ORPHAN);


