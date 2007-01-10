From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2007 19:56:39 -0000
Subject: LVM2 ./WHATS_NEW man/lvconvert.8 tools/lvchange.c
Message-ID: <20070110195639.20093.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-10 19:56:39

Modified files:
	.              : WHATS_NEW 
	man            : lvconvert.8 
	tools          : lvchange.c 

Log message:
	Prevent permission changes on active mirrors.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.533&r2=1.534
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/WHATS_NEW	2007/01/10 14:13:46	1.533
+++ LVM2/WHATS_NEW	2007/01/10 19:56:38	1.534
@@ -1,7 +1,8 @@
 Version 2.02.18 -
 ====================================
-  Print warning instead of error message if cannot zero volume
-  Update lvconvert man page (snapshot option)
+  Prevent permission changes on active mirrors.
+  Print warning instead of error message if lvconvert cannot zero volume.
+  Add snapshot options to lvconvert man page.
   dumpconfig accepts a list of configuration variables to display.
   Change dumpconfig to use --file to redirect output to a file.
   Avoid vgreduce error when mirror code removes the log LV.
--- LVM2/man/lvconvert.8	2007/01/10 14:13:46	1.4
+++ LVM2/man/lvconvert.8	2007/01/10 19:56:38	1.5
@@ -58,7 +58,7 @@
 .TP
 .I \-Z, \-\-zero y/n
 Controls zeroing of the first KB of data in the snapshot.
-If the volume is read only snapshot will not be zeroed.
+If the volume is read-only the snapshot will not be zeroed.
 .br
 .SH Examples
 "lvconvert -m1 vg00/lvol1"
--- LVM2/tools/lvchange.c	2006/11/03 21:07:15	1.74
+++ LVM2/tools/lvchange.c	2007/01/10 19:56:39	1.75
@@ -19,6 +19,7 @@
 			       struct logical_volume *lv)
 {
 	uint32_t lv_access;
+	struct lvinfo info;
 
 	lv_access = arg_uint_value(cmd, permission_ARG, 0);
 
@@ -34,6 +35,13 @@
 		return 0;
 	}
 
+	if ((lv->status & MIRRORED) && (lv->vg->status & CLUSTERED) &&
+	    lv_info(cmd, lv, &info, 0) && info.exists) {
+		log_error("Cannot change permissions of mirror \"%s\" "
+			  "while active.", lv->name);
+		return 0;
+	}
+
 	if (lv_access & LVM_WRITE) {
 		lv->status |= LVM_WRITE;
 		log_verbose("Setting logical volume \"%s\" read/write",


