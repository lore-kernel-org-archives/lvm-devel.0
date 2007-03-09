From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Mar 2007 21:25:34 -0000
Subject: LVM2 ./WHATS_NEW tools/vgextend.c tools/vgredu ...
Message-ID: <20070309212534.1579.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-03-09 21:25:33

Modified files:
	.              : WHATS_NEW 
	tools          : vgextend.c vgreduce.c vgsplit.c 

Log message:
	Add a few missing pieces of vgname command line validation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.583&r2=1.584
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2007/03/09 20:47:41	1.583
+++ LVM2/WHATS_NEW	2007/03/09 21:25:33	1.584
@@ -1,5 +1,6 @@
 Version 2.02.24 -
 ====================================
+  Add a few missing pieces of vgname command line validation.
   Support the /dev/mapper prefix on most command lines.
 
 Version 2.02.23 - 8th March 2007
--- LVM2/tools/vgextend.c	2007/03/09 20:47:41	1.28
+++ LVM2/tools/vgextend.c	2007/03/09 21:25:33	1.29
@@ -41,6 +41,12 @@
 		return ECMD_FAILED;
 	}
 
+	if (!validate_name(vg_name)) {
+		log_error("Volume group name \"%s\" is invalid",
+			  vg_name);
+		return ECMD_FAILED;
+	}
+
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
 		unlock_vg(cmd, ORPHAN);
--- LVM2/tools/vgreduce.c	2007/03/09 20:47:41	1.57
+++ LVM2/tools/vgreduce.c	2007/03/09 21:25:33	1.58
@@ -465,6 +465,12 @@
 	argv++;
 	argc--;
 
+	if (!validate_name(vg_name)) {
+		log_error("Volume group name \"%s\" is invalid",
+			  vg_name);
+		return ECMD_FAILED;
+	}
+
 	log_verbose("Finding volume group \"%s\"", vg_name);
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 		log_error("Can't get lock for %s", vg_name);
--- LVM2/tools/vgsplit.c	2007/01/29 23:01:18	1.22
+++ LVM2/tools/vgsplit.c	2007/03/09 21:25:33	1.23
@@ -219,11 +219,17 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	vg_name_from = argv[0];
-	vg_name_to = argv[1];
+	vg_name_from = skip_dev_dir(cmd, argv[0], NULL);
+	vg_name_to = skip_dev_dir(cmd, argv[1], NULL);
 	argc -= 2;
 	argv += 2;
 
+	if (!validate_name(vg_name_from)) {
+		log_error("Volume group name \"%s\" is invalid",
+			  vg_name_from);
+		return ECMD_FAILED;
+	}
+
 	if (!strcmp(vg_name_to, vg_name_from)) {
 		log_error("Duplicate volume group name \"%s\"", vg_name_from);
 		return ECMD_FAILED;


