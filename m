From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 1 Jun 2009 14:43:30 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20090601144330.24361.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-01 14:43:28

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h mirror.c 
	test           : t-mirror-lvconvert.sh 
	tools          : lvchange.c lvconvert.c polldaemon.c 
	                 polldaemon.h pvmove.c tools.h 

Log message:
	Fix convert polling to ignore LV with different UUID.
	
	When mirror convert polling is started (mainly as backgound process,
	in lvchange -a y or in lvconvert itself) it tries to read VG
	and LV identified by its name.
	
	Unfortunatelly, the VG can have already different LV under the same name,
	and various more or less funny things can happen (note that
	_finish_lvconvert_mirror suspends the volume for example).
	
	(the typical example is our testing script which continuously recreates
	LVs under the same name in the same VG.)
	
	This patch adds optional uuid parameter which helps to properly
	select the monitoring object. For lvconvert polling it is set to LV UUID
	and both _get_lvconvert_vg and _get_lvconvert_lv uses it to read proper VG/LV.
	
	(In the pvmove case it is NULL, here we poll for physical volume name).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1136&r2=1.1137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.63&r2=1.64

--- LVM2/WHATS_NEW	2009/06/01 12:43:31	1.1136
+++ LVM2/WHATS_NEW	2009/06/01 14:43:27	1.1137
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Fix convert polling to ignore LV with different UUID.
   Cache underlying device readahead only before activation calls.
   Fix segfault when calculating readahead on missing device in vgreduce.
   Remove verbose 'visited' messages.
--- LVM2/lib/metadata/metadata-exported.h	2009/05/21 03:04:53	1.74
+++ LVM2/lib/metadata/metadata-exported.h	2009/06/01 14:43:28	1.75
@@ -621,6 +621,7 @@
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
 						  struct volume_group *vg,
 						  const char *name,
+						  const char *uuid,
 						  uint32_t lv_type);
 const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
--- LVM2/lib/metadata/mirror.c	2009/05/21 03:04:53	1.88
+++ LVM2/lib/metadata/mirror.c	2009/06/01 14:43:28	1.89
@@ -1058,9 +1058,10 @@
 }
 
 struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
-					 	  struct volume_group *vg,
-				      		  const char *name,
-				      		  uint32_t lv_type)
+						  struct volume_group *vg,
+						  const char *name,
+						  const char *uuid __attribute((unused)),
+						  uint32_t lv_type)
 {
 	struct physical_volume *pv;
 
--- LVM2/test/t-mirror-lvconvert.sh	2009/05/22 14:56:17	1.9
+++ LVM2/test/t-mirror-lvconvert.sh	2009/06/01 14:43:28	1.10
@@ -280,20 +280,19 @@
 check_and_cleanup_lvs_
 
 # "remove from original mirror (the original becomes linear)"
-# FIXME: enable this test later
-#prepare_lvs_ 
-#lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
-#check_mirror_count_ $vg/$lv1 2 
-#check_mirror_log_ $vg/$lv1 
-#lvconvert -m+1 -b $vg/$lv1 $dev4 
-#lvconvert -m-1 $vg/$lv1 $dev2 
-#lvconvert -i1 $vg/$lv1 
-#wait_conversion_ $vg/$lv1 
-#check_no_tmplvs_ $vg/$lv1 
-#check_mirror_count_ $vg/$lv1 2 
-#mimages_are_redundant_ $vg $lv1 
-#mirrorlog_is_on_ $vg/$lv1 $dev3 
-#check_and_cleanup_lvs_
+prepare_lvs_ 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+check_mirror_count_ $vg/$lv1 2 
+check_mirror_log_ $vg/$lv1 
+lvconvert -m+1 -b $vg/$lv1 $dev4 
+lvconvert -m-1 $vg/$lv1 $dev2 
+lvconvert -i1 $vg/$lv1 
+wait_conversion_ $vg/$lv1 
+check_no_tmplvs_ $vg/$lv1 
+check_mirror_count_ $vg/$lv1 2 
+mimages_are_redundant_ $vg $lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 
--- LVM2/tools/lvchange.c	2009/05/27 18:19:21	1.102
+++ LVM2/tools/lvchange.c	2009/06/01 14:43:28	1.103
@@ -106,8 +106,6 @@
 {
 	int activate;
 	const char *pvname;
-	char *lv_full_name;
-	uint32_t len;
 
 	activate = arg_uint_value(cmd, available_ARG, 0);
 
@@ -152,15 +150,9 @@
 		}
 
 		if (lv->status & CONVERTING) {
-			len = strlen(lv->vg->name) + strlen(lv->name) + 2;
-			if (!(lv_full_name = alloca(len)))
-				return_0;
-			if (!dm_snprintf(lv_full_name, len, "%s/%s",
-					 lv->vg->name, lv->name))
-				return_0;
 			log_verbose("Spawning background lvconvert process for %s",
 				    lv->name);
-			lvconvert_poll(cmd, lv_full_name, 1);
+			lvconvert_poll(cmd, lv, 1);
 		}
 	}
 
--- LVM2/tools/lvconvert.c	2009/05/21 03:04:53	1.76
+++ LVM2/tools/lvconvert.c	2009/06/01 14:43:28	1.77
@@ -234,14 +234,16 @@
 	return 1;
 }
 
-
 static struct volume_group *_get_lvconvert_vg(struct cmd_context *cmd,
-					      const char *lv_name)
+					      const char *lv_name, const char *uuid)
 {
 	dev_close_all();
 
+	/*
+	 * uuid is here LV uuid, but vg_read will use only first part.
+	 */
         return vg_lock_and_read(cmd, extract_vgname(cmd, lv_name),
-				NULL, LCK_VG_WRITE,
+				uuid, LCK_VG_WRITE,
  				CLUSTERED | EXPORTED_VG | LVM_WRITE,
 				CORRECT_INCONSISTENT | FAIL_INCONSISTENT);
 }
@@ -249,9 +251,15 @@
 static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attribute((unused)),
 						struct volume_group *vg,
 						const char *name,
+						const char *uuid,
 						uint32_t lv_type __attribute((unused)))
 {
-	return find_lv(vg, name);
+	struct logical_volume *lv = find_lv(vg, name);
+
+	if (!lv || (uuid && strcmp(uuid, (char *)&lv->lvid)))
+		return NULL;
+
+	return lv;
 }
 
 static int _update_lvconvert_mirror(struct cmd_context *cmd __attribute((unused)),
@@ -315,11 +323,24 @@
 	.finish_copy = _finish_lvconvert_mirror,
 };
 
-int lvconvert_poll(struct cmd_context *cmd, const char *lv_name,
+int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 		   unsigned background)
 {
-	return poll_daemon(cmd, lv_name, background, 0, &_lvconvert_mirror_fns,
-			   "Converted");
+	int len = strlen(lv->vg->name) + strlen(lv->name) + 2;
+	char *uuid = alloca(sizeof(lv->lvid));
+	char *lv_full_name = alloca(len);
+
+
+	if (!uuid || !lv_full_name)
+		return_0;
+
+	if (!dm_snprintf(lv_full_name, len, "%s/%s", lv->vg->name, lv->name))
+		return_0;
+
+	memcpy(uuid, &lv->lvid, sizeof(lv->lvid));
+
+	return poll_daemon(cmd, lv_full_name, uuid, background, 0,
+			   &_lvconvert_mirror_fns, "Converted");
 }
 
 static int _insert_lvconvert_layer(struct cmd_context *cmd,
@@ -883,7 +904,7 @@
 			log_print("Conversion starts after activation");
 			goto out;
 		}
-		ret = lvconvert_poll(cmd, lp.lv_name_full,
+		ret = lvconvert_poll(cmd, lvl->lv,
 				     lp.wait_completion ? 0 : 1U);
 	}
 out:
--- LVM2/tools/polldaemon.c	2009/05/21 03:04:53	1.13
+++ LVM2/tools/polldaemon.c	2009/06/01 14:43:28	1.14
@@ -129,7 +129,7 @@
 	return 1;
 }
 
-static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name,
+static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name, const char *uuid,
 				   struct daemon_parms *parms)
 {
 	struct volume_group *vg;
@@ -147,13 +147,13 @@
 		}
 
 		/* Locks the (possibly renamed) VG again */
-		if (!(vg = parms->poll_fns->get_copy_vg(cmd, name))) {
+		if (!(vg = parms->poll_fns->get_copy_vg(cmd, name, uuid))) {
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
 		}
 
-		if (!(lv_mirr = parms->poll_fns->get_copy_lv(cmd, vg, name,
+		if (!(lv_mirr = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid,
 							     parms->lv_type))) {
 			log_error("ABORTING: Can't find mirror LV in %s for %s",
 				  vg->name, name);
@@ -225,7 +225,8 @@
 	}
 }
 
-int poll_daemon(struct cmd_context *cmd, const char *name, unsigned background,
+int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
+		unsigned background,
 		uint32_t lv_type, struct poll_functions *poll_fns,
 		const char *progress_title)
 {
@@ -260,7 +261,7 @@
 	}
 
 	if (name) {
-		if (!_wait_for_single_mirror(cmd, name, &parms))
+		if (!_wait_for_single_mirror(cmd, name, uuid, &parms))
 			return ECMD_FAILED;
 	} else
 		_poll_for_all_vgs(cmd, &parms);
--- LVM2/tools/polldaemon.h	2008/11/03 22:14:30	1.7
+++ LVM2/tools/polldaemon.h	2009/06/01 14:43:28	1.8
@@ -21,10 +21,12 @@
 struct poll_functions {
 	const char *(*get_copy_name_from_lv) (struct logical_volume *lv_mirr);
 	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
-					     const char *name);
+					     const char *name,
+					     const char *uuid);
 	struct logical_volume *(*get_copy_lv) (struct cmd_context *cmd,
 					       struct volume_group *vg,
 					       const char *name,
+					       const char *uuid,
 					       uint32_t lv_type);
 	int (*update_metadata) (struct cmd_context *cmd,
 				struct volume_group *vg,
@@ -47,7 +49,8 @@
 	struct poll_functions *poll_fns;
 };
 
-int poll_daemon(struct cmd_context *cmd, const char *name, unsigned background,
+int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
+		unsigned background,
 		uint32_t lv_type, struct poll_functions *poll_fns,
 		const char *progress_title);
 
--- LVM2/tools/pvmove.c	2009/05/21 03:04:53	1.60
+++ LVM2/tools/pvmove.c	2009/06/01 14:43:28	1.61
@@ -551,7 +551,7 @@
 }
 
 static struct volume_group *_get_move_vg(struct cmd_context *cmd,
-					 const char *name)
+					 const char *name, const char *uuid)
 {
 	struct physical_volume *pv;
 
@@ -576,7 +576,7 @@
 int pvmove_poll(struct cmd_context *cmd, const char *pv_name,
 		unsigned background)
 {
-	return poll_daemon(cmd, pv_name, background, PVMOVE, &_pvmove_fns,
+	return poll_daemon(cmd, pv_name, NULL, background, PVMOVE, &_pvmove_fns,
 			   "Moved");
 }
 
--- LVM2/tools/tools.h	2008/11/04 14:57:06	1.63
+++ LVM2/tools/tools.h	2009/06/01 14:43:28	1.64
@@ -168,6 +168,6 @@
 const char *command_name(struct cmd_context *cmd);
 
 int pvmove_poll(struct cmd_context *cmd, const char *pv, unsigned background);
-int lvconvert_poll(struct cmd_context *cmd, const char *lv_name, unsigned background);
+int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv, unsigned background);
 
 #endif


