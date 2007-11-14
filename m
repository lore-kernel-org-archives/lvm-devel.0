From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Nov 2007 18:41:06 -0000
Subject: LVM2 ./WHATS_NEW tools/pvdisplay.c tools/pvres ...
Message-ID: <20071114184106.2730.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-14 18:41:05

Modified files:
	.              : WHATS_NEW 
	tools          : pvdisplay.c pvresize.c reporter.c toollib.c 
	                 toollib.h vgreduce.c 

Log message:
	Avoid nested vg_reads when processing PVs in VGs and fix associated locking.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.734&r2=1.735
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/WHATS_NEW	2007/11/14 00:08:24	1.734
+++ LVM2/WHATS_NEW	2007/11/14 18:41:05	1.735
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Avoid nested vg_reads when processing PVs in VGs and fix associated locking.
   Accept sizes with --readahead argument.
   Store size arguments as sectors internally.
   Attempt to remove incomplete LVs with lvcreate zeroing/activation problems.
--- LVM2/tools/pvdisplay.c	2007/11/02 20:40:05	1.41
+++ LVM2/tools/pvdisplay.c	2007/11/14 18:41:05	1.42
@@ -16,7 +16,7 @@
 #include "tools.h"
 
 static int _pvdisplay_single(struct cmd_context *cmd,
-			     struct volume_group *vg __attribute((unused)),
+			     struct volume_group *vg,
 			     struct physical_volume *pv, void *handle)
 {
 	struct pv_list *pvl;
@@ -27,27 +27,27 @@
 	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name = NULL;
 
-	 if (!is_orphan(pv)) {
+	 if (!is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
-	         if (!lock_vol(cmd, vg_name, LCK_VG_READ)) {
-	                 log_error("Can't lock %s: skipping", vg_name);
-	                 return ECMD_FAILED;
-	         }
-
-	         if (!(vg = vg_read(cmd, vg_name, (char *)&pv->vgid, &consistent))) {
-	                 log_error("Can't read %s: skipping", vg_name);
-	                 goto out;
-	         }
-
-		 if (!vg_check_status(vg, CLUSTERED)) {
-	                 ret = ECMD_FAILED;
-	                 goto out;
-	         }
+         	if (!lock_vol(cmd, vg_name, LCK_VG_READ)) {
+                 	log_error("Can't lock %s: skipping", vg_name);
+                 	return ECMD_FAILED;
+         	}
+
+         	if (!(vg = vg_read(cmd, vg_name, (char *)&pv->vgid, &consistent))) {
+                 	log_error("Can't read %s: skipping", vg_name);
+                 	goto out;
+         	}
+
+		if (!vg_check_status(vg, CLUSTERED)) {
+			ret = ECMD_FAILED;
+			goto out;
+		}
 
-		 /*
-		  * Replace possibly incomplete PV structure with new one
-		  * allocated in vg_read() path.
-		  */
+	 	/*
+		 * Replace possibly incomplete PV structure with new one
+		 * allocated in vg_read() path.
+		 */
 		 if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 			 log_error("Unable to find \"%s\" in volume group \"%s\"",
 				   pv_name, vg->name);
@@ -119,5 +119,6 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_pv(cmd, argc, argv, NULL, NULL, _pvdisplay_single);
+	return process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ, NULL,
+			       _pvdisplay_single);
 }
--- LVM2/tools/pvresize.c	2007/11/14 00:08:25	1.16
+++ LVM2/tools/pvresize.c	2007/11/14 18:41:05	1.17
@@ -61,7 +61,8 @@
 	params.done = 0;
 	params.total = 0;
 
-	ret = process_each_pv(cmd, argc, argv, NULL, &params, _pvresize_single);
+	ret = process_each_pv(cmd, argc, argv, NULL, LCK_VG_WRITE, &params,
+			      _pvresize_single);
 
 	log_print("%d physical volume(s) resized / %d physical volume(s) "
 		  "not resized", params.done, params.total - params.done);
--- LVM2/tools/reporter.c	2007/11/02 20:40:05	1.28
+++ LVM2/tools/reporter.c	2007/11/14 18:41:05	1.29
@@ -54,33 +54,15 @@
 	return ECMD_PROCESSED;
 }
 
-static int _pvsegs_sub_single(struct cmd_context *cmd, struct volume_group *vg,
+static int _pvsegs_sub_single(struct cmd_context *cmd __attribute((unused)),
+			      struct volume_group *vg,
 			      struct pv_segment *pvseg, void *handle)
 {
-	int consistent = 0;
-	struct physical_volume *pv = pvseg->pv;
 	int ret = ECMD_PROCESSED;
 
-	if (!lock_vol(cmd, pv_vg_name(pv), LCK_VG_READ)) {
-		log_error("Can't lock %s: skipping", pv_vg_name(pv));
-		return ECMD_FAILED;
-	}
-
-	if (!(vg = vg_read(cmd, pv_vg_name(pv), NULL, &consistent))) {
-		log_error("Can't read %s: skipping", pv_vg_name(pv));
-		goto out;
-	}
-
-	if (!vg_check_status(vg, CLUSTERED)) {
+	if (!report_object(handle, vg, NULL, pvseg->pv, NULL, pvseg))
 		ret = ECMD_FAILED;
-		goto out;
-	}
 
-	if (!report_object(handle, vg, NULL, pv, NULL, pvseg))
-		ret = ECMD_FAILED;
-
-out:
-	unlock_vg(cmd, pv_vg_name(pv));
 	return ret;
 }
 
@@ -108,7 +90,7 @@
 	int ret = ECMD_PROCESSED;
 	const char *vg_name = NULL;
 
-	if (!is_orphan(pv)) {
+	if (!is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
 
 		if (!lock_vol(cmd, vg_name, LCK_VG_READ)) {
@@ -334,7 +316,7 @@
 		break;
 	case PVS:
 		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL,
+			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
 					    report_handle, &_pvs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
@@ -346,7 +328,7 @@
 		break;
 	case PVSEGS:
 		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL,
+			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
 					    report_handle, &_pvsegs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
--- LVM2/tools/toollib.c	2007/11/12 21:50:21	1.114
+++ LVM2/tools/toollib.c	2007/11/14 18:41:05	1.115
@@ -424,8 +424,28 @@
 						      void *handle))
 {
 	struct pv_segment *pvseg;
+	const char *vg_name = NULL;
 	int ret_max = 0;
 	int ret;
+	int consistent = 0;
+
+	if (!vg) {
+		vg_name = pv_vg_name(pv);
+		if (!lock_vol(cmd, vg_name, LCK_VG_READ)) {
+			log_error("Can't lock %s: skipping", vg_name);
+			return ECMD_FAILED;
+		}
+
+		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
+			log_error("Can't read %s: skipping", vg_name);
+			goto out;
+		}
+
+		if (!vg_check_status(vg, CLUSTERED)) {
+			ret = ECMD_FAILED;
+			goto out;
+		}
+	}
 
 	list_iterate_items(pvseg, &pv->segments) {
 		ret = process_single(cmd, vg, pvseg, handle);
@@ -435,6 +455,10 @@
 			return ret_max;
 	}
 
+out:
+	if (vg_name)
+		unlock_vg(cmd, vg_name);
+
 	return ret_max;
 }
 
@@ -665,7 +689,7 @@
 }
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    struct volume_group *vg, void *handle,
+		    struct volume_group *vg, uint32_t lock_type, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct volume_group * vg,
 					   struct physical_volume * pv,
@@ -735,20 +759,32 @@
 		if (!list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
 		    !list_empty(vgnames)) {
 			list_iterate_items(sll, vgnames) {
+				if (!lock_vol(cmd, sll->str, lock_type)) {
+					log_error("Can't lock %s: skipping", sll->str);
+					continue;
+				}
 				if (!(vg = vg_read(cmd, sll->str, NULL, &consistent))) {
 					log_error("Volume group \"%s\" not found", sll->str);
+					unlock_vg(cmd, sll->str);
 					ret_max = ECMD_FAILED;
 					continue;
 				}
-				if (!consistent)
+				if (!consistent) {
+					unlock_vg(cmd, sll->str);
 					continue;
+				}
 
-				if (!vg_check_status(vg, CLUSTERED))
+				if (!vg_check_status(vg, CLUSTERED)) {
+					unlock_vg(cmd, sll->str);
 					continue;
+				}
 
 				ret = process_each_pv_in_vg(cmd, vg, &tags,
 							    handle,
 							    process_single);
+
+				unlock_vg(cmd, sll->str);
+
 				if (ret > ret_max)
 					ret_max = ret;
 				if (sigint_caught())
--- LVM2/tools/toollib.h	2007/11/02 20:40:05	1.51
+++ LVM2/tools/toollib.h	2007/11/14 18:41:05	1.52
@@ -34,7 +34,7 @@
 					   int consistent, void *handle));
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    struct volume_group *vg, void *handle,
+		    struct volume_group *vg, uint32_t lock_type, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct volume_group * vg,
 					   struct physical_volume * pv,
--- LVM2/tools/vgreduce.c	2007/11/12 20:51:54	1.69
+++ LVM2/tools/vgreduce.c	2007/11/14 18:41:05	1.70
@@ -539,7 +539,7 @@
 
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch here? */
-		ret = process_each_pv(cmd, argc, argv, vg, NULL,
+		ret = process_each_pv(cmd, argc, argv, vg, LCK_VG_WRITE, NULL,
 				      _vgreduce_single);
 
 	}


