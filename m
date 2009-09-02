From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:39:30 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090902213930.18460.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:39:29

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	liblvm         : lvm_vg.c 
	tools          : vgremove.c 

Log message:
	Split vg_remove_single into 2 functions - the second part commits to disk.
	
	Split vg_remove_single into vg_remove_check (mandatory checks before
	vgremove) and vg_remove (do actual remove by committing to disk).
	
	In liblvm, we'd like to provide an consistent API that allows multiple
	changes in memory, then let lvm_vg_write() control the commit to disk.  In
	some cases (for example, lvresize calls fsadm) this may not be possible.
	However, since we are using an object model and dividing things into small
	operations, the most logical model seems to be the lvm_vg_write model, and
	handling the special cases as they arrive.  So as best as possible
	we move towards this end.
	
	A possible optimization would be to consolidate vg_remove (committing)
	code with vgreduce code.  A second possible optimization is making vgreduce
	of the last device equivalent to vgremove.  Today, lvm_vg_reduce fails if
	vgreduce is called with the last device, but from an object model perspective
	we could view this as equivalent to vgremove and allow it.  My gut feel is
	we do not want to do this though.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.280&r2=1.281
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/lib/metadata/metadata-exported.h	2009/09/02 21:39:07	1.108
+++ LVM2/lib/metadata/metadata-exported.h	2009/09/02 21:39:29	1.109
@@ -442,7 +442,8 @@
 
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove_mdas(struct volume_group *vg);
-int vg_remove_single(struct volume_group *vg);
+int vg_remove_check(struct volume_group *vg);
+int vg_remove(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
--- LVM2/lib/metadata/metadata.c	2009/09/02 21:39:07	1.280
+++ LVM2/lib/metadata/metadata.c	2009/09/02 21:39:29	1.281
@@ -468,12 +468,9 @@
 	return 1;
 }
 
-int vg_remove_single(struct volume_group *vg)
+int vg_remove_check(struct volume_group *vg)
 {
-	struct physical_volume *pv;
-	struct pv_list *pvl;
 	unsigned lv_count;
-	int ret = 1;
 
 	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
@@ -497,6 +494,15 @@
 	if (!archive(vg))
 		return 0;
 
+	return 1;
+}
+
+int vg_remove(struct volume_group *vg)
+{
+	struct physical_volume *pv;
+	struct pv_list *pvl;
+	int ret = 1;
+
 	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return 0;
--- LVM2/liblvm/lvm_vg.c	2009/08/13 12:16:45	1.26
+++ LVM2/liblvm/lvm_vg.c	2009/09/02 21:39:29	1.27
@@ -153,7 +153,10 @@
 	if (!vg_check_write_mode(vg))
 		return -1;
 
-	if (!vg_remove_single(vg))
+	if (!vg_remove_check(vg))
+		return -1;
+
+	if (!vg_remove(vg))
 		return -1;
 	return 0;
 }
--- LVM2/tools/vgremove.c	2009/07/14 19:37:18	1.54
+++ LVM2/tools/vgremove.c	2009/09/02 21:39:29	1.55
@@ -44,7 +44,10 @@
 			return ECMD_FAILED;
 	}
 
-	if (!vg_remove_single(vg))
+	if (!vg_remove_check(vg))
+		return ECMD_FAILED;
+
+	if (!vg_remove(vg))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;


