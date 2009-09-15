From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Sep 2009 01:39:02 -0000
Subject: LVM2 ./WHATS_NEW tools/polldaemon.c tools/repo ...
Message-ID: <20090915013902.29147.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-15 01:39:00

Modified files:
	.              : WHATS_NEW 
	tools          : polldaemon.c reporter.c toollib.c vgcfgbackup.c 
	                 vgchange.c vgck.c vgconvert.c vgdisplay.c 
	                 vgexport.c vgimport.c vgremove.c vgscan.c 

Log message:
	Fix process_each_vg / _process_one_vg when vg_read() returns FAILED_LOCKING.
	
	Remove the checks for vg_read_error() in most of the tools callback
	functions and instead make the check in _process_one_vg() more general.
	
	In all but vgcfgbackup, we do not want to proceed if we get any error
	from vg_read().  In vgcfgbackup's case, we may proceed if the backup
	is to proceed with inconsistent VGs.  This is a special case though,
	and we mark it with the READ_ALLOW_INCONSISTENT flag passed to
	process_each_vg (and subsequently to _process_one_vg).
	
	NOTE: More cleanup is needed in the vg_read_error() path cases.
	This patch is a start.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1260&r2=1.1261
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.168&r2=1.169
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgbackup.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgexport.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgimport.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/WHATS_NEW	2009/09/14 22:47:49	1.1260
+++ LVM2/WHATS_NEW	2009/09/15 01:38:59	1.1261
@@ -1,8 +1,10 @@
 Version 2.02.52 -
 =================================
+  Update _process_one_vg to cleanup properly after vg_read_error.
   Add lots of missing stack debug messages to tools.
   Make readonly locking available as locking type 4.
   Fix readonly locking to permit writeable global locks (for vgscan). (2.02.49)
+  Add lvm_vg_is_clustered, lvm_vg_is_exported, and lvm_vg_is_partial.
   Add manpage entry for dmsetup's udevcomplete_all and udevcookies commands.
   Add DM_UDEV_RULES_VSN udev enviroment variable.
   Check that udev is running and set internal state appropriately.
--- LVM2/tools/polldaemon.c	2009/09/14 22:47:49	1.22
+++ LVM2/tools/polldaemon.c	2009/09/15 01:38:59	1.23
@@ -185,11 +185,6 @@
 	const char *name;
 	int finished;
 
-	if (vg_read_error(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv_mirr = lvl->lv;
 		if (!(lv_mirr->status & parms->lv_type))
--- LVM2/tools/reporter.c	2009/09/14 22:47:49	1.55
+++ LVM2/tools/reporter.c	2009/09/15 01:38:59	1.56
@@ -20,11 +20,6 @@
 		       const char *vg_name, struct volume_group *vg,
 		       void *handle)
 {
-	if (vg_read_error(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
 	if (!report_object(handle, vg, NULL, NULL, NULL, NULL)) {
 		stack;
 		return ECMD_FAILED;
--- LVM2/tools/toollib.c	2009/09/14 22:47:49	1.168
+++ LVM2/tools/toollib.c	2009/09/15 01:38:59	1.169
@@ -433,10 +433,11 @@
 
 	vg = vg_read(cmd, vg_name, vgid, flags);
 	/* Allow FAILED_INCONSISTENT through only for vgcfgrestore */
-	if (vg_read_error(vg) && (vg_read_error(vg) != FAILED_INCONSISTENT)) {
-		vg_release(vg);
+	if (vg_read_error(vg) &&
+	    !((vg_read_error(vg) == FAILED_INCONSISTENT)&&(flags & READ_ALLOW_INCONSISTENT))) {
+		ret_max = ECMD_FAILED;
 		stack;
-		return ECMD_FAILED;
+		goto out;
 	}
 
 	if (!dm_list_empty(tags)) {
@@ -451,7 +452,11 @@
 		ret_max = ret;
 
 out:
-	unlock_and_release_vg(cmd, vg, vg_name);
+	if ((vg_read_error(vg) == FAILED_ALLOCATION)||
+	    (vg_read_error(vg) == FAILED_LOCKING))
+		vg_release(vg);
+	else
+		unlock_and_release_vg(cmd, vg, vg_name);
 	return ret_max;
 }
 
--- LVM2/tools/vgcfgbackup.c	2009/09/14 22:47:49	1.30
+++ LVM2/tools/vgcfgbackup.c	2009/09/15 01:38:59	1.31
@@ -92,7 +92,7 @@
 
 	init_pvmove(1);
 
-	ret = process_each_vg(cmd, argc, argv, 0,
+	ret = process_each_vg(cmd, argc, argv, READ_ALLOW_INCONSISTENT,
 			      &last_filename, &vg_backup_single);
 
 	dm_free(last_filename);
--- LVM2/tools/vgchange.c	2009/09/14 22:47:50	1.84
+++ LVM2/tools/vgchange.c	2009/09/15 01:38:59	1.85
@@ -496,11 +496,6 @@
 {
 	int r = ECMD_FAILED;
 
-	if (vg_read_error(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
 	if (vg_is_exported(vg)) {
 		log_error("Volume group \"%s\" is exported", vg_name);
 		return ECMD_FAILED;
--- LVM2/tools/vgck.c	2009/09/14 22:47:50	1.24
+++ LVM2/tools/vgck.c	2009/09/15 01:38:59	1.25
@@ -21,11 +21,6 @@
 		       struct volume_group *vg,
 		       void *handle __attribute((unused)))
 {
-	if (vg_read_error(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
 	if (!vg_check_status(vg, EXPORTED_VG)) {
 		stack;
 		return ECMD_FAILED;
--- LVM2/tools/vgconvert.c	2009/09/14 22:47:50	1.39
+++ LVM2/tools/vgconvert.c	2009/09/15 01:38:59	1.40
@@ -32,11 +32,6 @@
 	struct lvinfo info;
 	int active = 0;
 
-	if (vg_read_error(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
 	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG)) {
 		stack;
 		return ECMD_FAILED;
--- LVM2/tools/vgdisplay.c	2009/09/14 22:47:50	1.25
+++ LVM2/tools/vgdisplay.c	2009/09/15 01:38:59	1.26
@@ -20,11 +20,6 @@
 			    void *handle __attribute((unused)))
 {
 	/* FIXME Do the active check here if activevolumegroups_ARG ? */
-	if (vg_read_error(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
 	vg_check_status(vg, EXPORTED_VG);
 
 	if (arg_count(cmd, colon_ARG)) {
--- LVM2/tools/vgexport.c	2009/09/14 22:47:50	1.22
+++ LVM2/tools/vgexport.c	2009/09/15 01:38:59	1.23
@@ -23,9 +23,6 @@
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 
-	if (vg_read_error(vg))
-		goto_bad;
-
 	if (lvs_in_vg_activated(vg)) {
 		log_error("Volume group \"%s\" has active logical volumes",
 			  vg_name);
--- LVM2/tools/vgimport.c	2009/09/14 22:47:50	1.22
+++ LVM2/tools/vgimport.c	2009/09/15 01:38:59	1.23
@@ -23,9 +23,6 @@
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 
-	if (vg_read_error(vg))
-		goto_bad;
-
 	if (!vg_is_exported(vg)) {
 		log_error("Volume group \"%s\" is not exported", vg_name);
 		goto bad;
--- LVM2/tools/vgremove.c	2009/09/14 22:47:50	1.56
+++ LVM2/tools/vgremove.c	2009/09/15 01:38:59	1.57
@@ -22,11 +22,6 @@
 	unsigned lv_count;
 	force_t force;
 
-	if (vg_read_error(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
 	if (!vg_check_status(vg, EXPORTED_VG)) {
 		stack;
 		return ECMD_FAILED;
--- LVM2/tools/vgscan.c	2009/09/14 22:47:50	1.36
+++ LVM2/tools/vgscan.c	2009/09/15 01:38:59	1.37
@@ -19,11 +19,6 @@
 			 struct volume_group *vg,
 			 void *handle __attribute((unused)))
 {
-	if (vg_read_error(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
 	log_print("Found %svolume group \"%s\" using metadata type %s",
 		  vg_is_exported(vg) ? "exported " : "", vg_name,
 		  vg->fid->fmt->name);


