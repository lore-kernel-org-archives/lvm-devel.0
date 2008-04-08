From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Apr 2008 14:22:14 -0000
Subject: LVM2 ./WHATS_NEW man/vgcreate.8 tools/vgcreate.c
Message-ID: <20080408142214.13148.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-08 14:22:13

Modified files:
	.              : WHATS_NEW 
	man            : vgcreate.8 
	tools          : vgcreate.c 

Log message:
	Indicate whether or not VG is clustered in vgcreate log message.
	Mention default --clustered setting in vgcreate man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.831&r2=1.832
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2008/04/08 13:03:13	1.831
+++ LVM2/WHATS_NEW	2008/04/08 14:22:12	1.832
@@ -1,6 +1,8 @@
 Version 2.02.34 -
 ===================================
-  Addd config file overrides to clvmd when it reads the active LVs list
+  Indicate whether or not VG is clustered in vgcreate log message.
+  Mention default --clustered setting in vgcreate man page.
+  Add config file overrides to clvmd when it reads the active LVs list.
   Fix vgreduce to use vg_split_mdas to check sufficient mdas remain.
   Add (empty) orphan VGs to lvmcache during initialisation.
   Fix orphan VG name used for format_pool.
--- LVM2/man/vgcreate.8	2007/01/23 13:08:34	1.7
+++ LVM2/man/vgcreate.8	2008/04/08 14:22:13	1.8
@@ -35,12 +35,13 @@
 See \fBlvm\fP for common options.
 .TP
 .BR \-c ", " \-\-clustered " " { y | n }
-If clustered locking is enabled, this indicates whether this
-Volume Group is shared with other nodes in the cluster or whether
-it contains only local disks that are not visible on the other nodes.
+If clustered locking is enabled, this defaults to \fBy\fP indicating that 
+this Volume Group is shared with other nodes in the cluster.
+
+If the new Volume Group contains only local disks that are not visible 
+on the other nodes, you must specify \fB\-\-clustered\ n\fP.
 If the cluster infrastructure is unavailable on a particular node at a
-particular time, you may still be able to use Volume Groups that
-are not marked as clustered.
+particular time, you may still be able to use such Volume Groups.
 .TP
 .BR \-l ", " \-\-maxlogicalvolumes " " \fIMaxLogicalVolumes\fR
 Sets the maximum number of logical volumes allowed in this
--- LVM2/tools/vgcreate.c	2008/01/17 15:31:18	1.56
+++ LVM2/tools/vgcreate.c	2008/04/08 14:22:13	1.57
@@ -21,6 +21,7 @@
 	struct vgcreate_params vp_def;
 	struct volume_group *vg;
 	const char *tag;
+	const char *clustered_message = "";
 
 	if (!argc) {
 		log_error("Please provide volume group name and "
@@ -78,10 +79,14 @@
 	}
 
 	/* FIXME: move this inside vg_create? */
-	if (vp_new.clustered)
+	if (vp_new.clustered) {
 		vg->status |= CLUSTERED;
-	else
+		clustered_message = "Clustered ";
+	} else {
 		vg->status &= ~CLUSTERED;
+		if (locking_is_clustered())
+			clustered_message = "Non-clustered ";
+	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
@@ -112,7 +117,8 @@
 
 	backup(vg);
 
-	log_print("Volume group \"%s\" successfully created", vg->name);
+	log_print("%s%colume group \"%s\" successfully created",
+		  clustered_message, *clustered_message ? 'v' : 'V', vg->name);
 
 	return ECMD_PROCESSED;
 }


