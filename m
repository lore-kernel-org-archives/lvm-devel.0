From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Jul 2009 17:01:47 -0000
Subject: LVM2/tools vgreduce.c
Message-ID: <20090701170147.5429.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-01 17:01:46

Modified files:
	tools          : vgreduce.c 

Log message:
	Convert vgreduce to use vg_read_for_update.
	
	Sun May  3 12:50:58 CEST 2009  Petr Rockai <me@mornfall.net>
	* Convert vgreduce to use vg_read_for_update.
	
	Rebased 6/26/2009 - Dave W.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/tools/vgreduce.c	2009/06/15 14:47:40	1.92
+++ LVM2/tools/vgreduce.c	2009/07/01 17:01:46	1.93
@@ -382,7 +382,6 @@
 {
 	struct pv_list *pvl;
 	struct volume_group *orphan_vg = NULL;
-	int consistent = 1;
 	int r = ECMD_FAILED;
 	const char *name = pv_dev_name(pv);
 
@@ -424,11 +423,11 @@
 	vg->free_count -= pv_pe_count(pv) - pv_pe_alloc_count(pv);
 	vg->extent_count -= pv_pe_count(pv);
 
-	if(!(orphan_vg = vg_read_internal(cmd, vg->fid->fmt->orphan_vg_name, NULL, &consistent)) ||
-	   !consistent) {
-		log_error("Unable to read existing orphan PVs");
+	orphan_vg = vg_read_for_update(cmd, vg->fid->fmt->orphan_vg_name,
+				       NULL, LOCK_NONBLOCKING);
+
+	if (vg_read_error(orphan_vg))
 		goto bad;
-	}
 
 	if (!vg_split_mdas(cmd, vg, orphan_vg) || !vg->pv_count) {
 		log_error("Cannot remove final metadata area on \"%s\" from \"%s\"",
@@ -463,7 +462,6 @@
 	struct volume_group *vg;
 	char *vg_name;
 	int ret = ECMD_FAILED;
-	int consistent = 1;
 	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
@@ -511,25 +509,22 @@
 	}
 
 	log_verbose("Finding volume group \"%s\"", vg_name);
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-		log_error("Can't get lock for %s", vg_name);
-		return ECMD_FAILED;
-	}
 
 	if (repairing)
 		init_ignore_suspended_devices(1);
 
-	if ((!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent)) || !consistent)
-	    && !repairing) {
-		log_error("Volume group \"%s\" doesn't exist", vg_name);
+	vg = vg_read_for_update(cmd, vg_name, NULL, READ_ALLOW_EXPORTED);
+	if (vg_read_error(vg) == FAILED_ALLOCATION ||
+	    vg_read_error(vg) == FAILED_NOTFOUND)
 		goto out;
-	}
 
-	if (vg && !vg_check_status(vg, CLUSTERED))
+	/* FIXME We want to allow read-only VGs to be changed here? */
+	if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
+	    && !arg_count(cmd, removemissing_ARG))
 		goto out;
 
 	if (repairing) {
-		if (vg && consistent && !vg_missing_pv_count(vg)) {
+		if (!vg_read_error(vg) && !vg_missing_pv_count(vg)) {
 			log_error("Volume group \"%s\" is already consistent",
 				  vg_name);
 			ret = ECMD_PROCESSED;
@@ -537,13 +532,16 @@
 		}
 
 		vg_release(vg);
-		consistent = !arg_count(cmd, force_ARG);
-		if (!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
-			log_error("Volume group \"%s\" not found", vg_name);
-			goto out;
-		}
-		if (!vg_check_status(vg, CLUSTERED))
+		log_verbose("Trying to open VG %s for recovery...", vg_name);
+
+		vg = vg_read_for_update(cmd, vg_name, NULL,
+					READ_ALLOW_INCONSISTENT
+					| READ_ALLOW_EXPORTED);
+
+		if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
+		    && vg_read_error(vg) != FAILED_INCONSISTENT)
 			goto out;
+
 		if (!archive(vg))
 			goto out;
 


