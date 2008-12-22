From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Dec 2008 09:00:53 -0000
Subject: LVM2/tools commands.h toollib.c toollib.h vgch ...
Message-ID: <20081222090053.1811.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2008-12-22 09:00:51

Modified files:
	tools          : commands.h toollib.c toollib.h vgchange.c 
	                 vgmknodes.c vgrename.c 

Log message:
	Add "--refresh" functionality to vgchange and vgmknodes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmknodes.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/tools/commands.h	2008/09/19 07:08:22	1.120
+++ LVM2/tools/commands.h	2008/12/22 09:00:51	1.121
@@ -665,6 +665,7 @@
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
+   "\t[--refresh]\n"
    "\t[-t|--test]" "\n"
    "\t[-u|--uuid] " "\n"
    "\t[-v|--verbose] " "\n"
@@ -682,7 +683,8 @@
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, partial_ARG,
-   physicalextentsize_ARG, resizeable_ARG, resizable_ARG, test_ARG, uuid_ARG)
+   physicalextentsize_ARG, refresh_ARG, resizeable_ARG, resizable_ARG,
+   test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
@@ -834,11 +836,12 @@
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--refresh]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\t[VolumeGroupName...]\n",
 
-   ignorelockingfailure_ARG)
+   ignorelockingfailure_ARG, refresh_ARG)
 
 xx(vgreduce,
    "Remove physical volume(s) from a volume group",
--- LVM2/tools/toollib.c	2008/12/19 14:22:48	1.139
+++ LVM2/tools/toollib.c	2008/12/22 09:00:51	1.140
@@ -1237,3 +1237,16 @@
 {
 	return suspend_lv(cmd, lv) && resume_lv(cmd, lv);
 }
+
+int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	int r = 1;
+	
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (lv_is_visible(lvl->lv))
+			if (!lv_refresh(cmd, lvl->lv))
+				r = 0;
+	
+	return r;
+}
--- LVM2/tools/toollib.h	2008/12/19 14:22:48	1.59
+++ LVM2/tools/toollib.h	2008/12/22 09:00:51	1.60
@@ -102,4 +102,5 @@
 			  struct vgcreate_params *vp_def);
 
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv);
+int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg);
 #endif
--- LVM2/tools/vgchange.c	2008/12/18 05:27:18	1.67
+++ LVM2/tools/vgchange.c	2008/12/22 09:00:51	1.68
@@ -510,6 +510,16 @@
 	return ECMD_PROCESSED;
 }
 
+static int _vgchange_refresh(struct cmd_context *cmd, struct volume_group *vg)
+{
+	log_verbose("Refreshing volume group \"%s\"", vg->name);
+
+	if (!vg_refresh_visible(cmd, vg))
+		return ECMD_FAILED;
+	
+	return ECMD_PROCESSED;
+}
+
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg, int consistent,
 			   void *handle __attribute((unused)))
@@ -576,6 +586,9 @@
 	else if (arg_count(cmd, clustered_ARG))
 		r = _vgchange_clustered(cmd, vg);
 
+	else if (arg_count(cmd, refresh_ARG))
+		r = _vgchange_refresh(cmd, vg);
+
 	return r;
 }
 
@@ -588,9 +601,9 @@
 	     arg_count(cmd, addtag_ARG) + arg_count(cmd, uuid_ARG) +
 	     arg_count(cmd, physicalextentsize_ARG) +
 	     arg_count(cmd, clustered_ARG) + arg_count(cmd, alloc_ARG) +
-	     arg_count(cmd, monitor_ARG))) {
-		log_error("One of -a, -c, -l, -p, -s, -x, --uuid, --alloc, "
-			  "--addtag or --deltag required");
+	     arg_count(cmd, monitor_ARG) + arg_count(cmd, refresh_ARG))) {
+		log_error("One of -a, -c, -l, -p, -s, -x, --refresh, "
+				"--uuid, --alloc, --addtag or --deltag required");
 		return EINVALID_CMD_LINE;
 	}
 
--- LVM2/tools/vgmknodes.c	2008/01/30 14:00:02	1.6
+++ LVM2/tools/vgmknodes.c	2008/12/22 09:00:51	1.7
@@ -18,6 +18,10 @@
 static int _vgmknodes_single(struct cmd_context *cmd, struct logical_volume *lv,
 			     void *handle __attribute((unused)))
 {
+	if (arg_count(cmd, refresh_ARG) && lv_is_visible(lv))
+		if (!lv_refresh(cmd, lv))
+			return ECMD_FAILED;
+
 	if (!lv_mknodes(cmd, lv))
 		return ECMD_FAILED;
 
@@ -26,13 +30,9 @@
 
 int vgmknodes(struct cmd_context *cmd, int argc, char **argv)
 {
-	int r;
+	if (!lv_mknodes(cmd, NULL))
+		return ECMD_FAILED;
 
-	r = process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
+	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
 			    &_vgmknodes_single);
-
-	if (!lv_mknodes(cmd, NULL) && (r < ECMD_FAILED))
-		r = ECMD_FAILED;
-
-	return r;
 }
--- LVM2/tools/vgrename.c	2008/12/19 14:22:48	1.56
+++ LVM2/tools/vgrename.c	2008/12/22 09:00:51	1.57
@@ -23,9 +23,7 @@
 	int consistent = 1;
 	int match = 0;
 	int found_id = 0;
-	int symlinks_refresh_ok = 1;
 	struct dm_list *vgids;
-	struct lv_list *lvl;
 	struct str_list *sl;
 	char *vg_name_new;
 	const char *vgid = NULL, *vg_name, *vg_name_old;
@@ -140,12 +138,7 @@
 			log_verbose("Test mode: Skipping rename.");
 
 		else if (lvs_in_vg_activated_by_uuid_only(vg)) {
-			dm_list_iterate_items(lvl, &vg->lvs)
-				if (lv_is_visible(lvl->lv))
-					if (!lv_refresh(cmd, lvl->lv))
-						symlinks_refresh_ok = 0;
-
-			if (!symlinks_refresh_ok) {
+			if (!vg_refresh_visible(cmd, vg)) {
 				log_error("Renaming \"%s\" to \"%s\" failed", 
 					old_path, new_path);
 				goto error;


