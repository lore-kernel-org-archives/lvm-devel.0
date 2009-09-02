From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:27:23 -0000
Subject: LVM2 man/vgsplit.8.in tools/vgsplit.c
Message-ID: <20090902212723.12762.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:27:22

Modified files:
	man            : vgsplit.8.in 
	tools          : vgsplit.c 

Log message:
	Refactor vgsplit - reorder _vgsplit_from and _vgsplit_to based on flag.
	
	Slight functional change.  If we open the destination first, we cannot
	know the 'fmt'.  In this case we use the default metadata type unless
	the user has specified -M on the cmdline.  If not, in most cases this
	is fine since we use the LVM2 default metadata type.  However, if the
	user is specifying a non-default metadata type (e.g. lvm1) and the order
	of the names is such that we have to open the destination (vg_to) first,
	we have a problem.  So in this case, we require the use of -M and vgsplit
	will fail with an error if not.  I've updated the man page to recommend
	the usage of -M in this case.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgsplit.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/man/vgsplit.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgsplit.8.in	2009/09/02 21:27:22	1.2
@@ -39,7 +39,9 @@
 and \fB\-\-maxphysicalvolumes\fR (see \fBvgcreate(8)\fR for a description
 of these options).  If any of these options are not given, default
 attribute(s) are taken from
-.I SourceVolumeGroupName\fP.
+.I SourceVolumeGroupName\fP.  If a non-LVM2 metadata type (e.g. lvm1) is
+being used, you should use the -M option to specify the metadata type
+directly.
 
 If
 .I DestinationVolumeGroupName
--- LVM2/tools/vgsplit.c	2009/09/02 21:27:05	1.91
+++ LVM2/tools/vgsplit.c	2009/09/02 21:27:22	1.92
@@ -314,26 +314,40 @@
 		return ECMD_FAILED;
 	}
 
-	vg_from = _vgsplit_from(cmd, vg_name_from);
-	if (!vg_from) {
-		if (!lock_vg_from_first)
-			unlock_and_release_vg(cmd, vg_to, vg_name_to);
-		return ECMD_FAILED;
-	}
-
-	/*
-	 * Set metadata format of original VG.
-	 * NOTE: We must set the format before calling vg_create()
-	 * since vg_create() calls the per-format constructor.
-	 */
-	cmd->fmt = vg_from->fid->fmt;
+	if (lock_vg_from_first) {
+		vg_from = _vgsplit_from(cmd, vg_name_from);
+		if (!vg_from)
+			return ECMD_FAILED;
+		/*
+		 * Set metadata format of original VG.
+		 * NOTE: We must set the format before calling vg_create()
+		 * since vg_create() calls the per-format constructor.
+		 */
+		cmd->fmt = vg_from->fid->fmt;
 
-	vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
-	if (!vg_to) {
-		if (lock_vg_from_first)
+		vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
+		if (!vg_to) {
 			unlock_and_release_vg(cmd, vg_from, vg_name_from);
-		return ECMD_FAILED;
+			return ECMD_FAILED;
+		}
+	} else {
+		vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
+		if (!vg_to)
+			return ECMD_FAILED;
+		vg_from = _vgsplit_from(cmd, vg_name_from);
+		if (!vg_from) {
+			unlock_and_release_vg(cmd, vg_to, vg_name_to);
+			return ECMD_FAILED;
+		}
+
+		if (cmd->fmt != vg_from->fid->fmt) {
+			/* In this case we don't know the vg_from->fid->fmt */
+			log_error("Unable to set new VG metadata type based on "
+				  "source VG format - use -M option.");
+			goto bad;
+		}
 	}
+
 	if (existing_vg) {
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "


