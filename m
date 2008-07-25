From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Jul 2008 14:45:26 -0000
Subject: LVM2/tools pvcreate.c
Message-ID: <20080725144526.31663.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-25 14:45:25

Modified files:
	tools          : pvcreate.c 

Log message:
	Refactor pvcreate - --yes argument

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/tools/pvcreate.c	2008/07/25 14:36:55	1.71
+++ LVM2/tools/pvcreate.c	2008/07/25 14:45:24	1.72
@@ -29,6 +29,7 @@
 	uint32_t extent_size;
 	const char *restorefile; /* 0 if no --restorefile option */
 	force_t force;
+	unsigned yes;
 };
 
 const char _really_init[] =
@@ -72,7 +73,7 @@
 	}
 
 	/* prompt */
-	if (pv && !is_orphan(pv) && !arg_count(cmd, yes_ARG) &&
+	if (pv && !is_orphan(pv) && !pp->yes &&
 	    yes_no_prompt(_really_init, name, pv_vg_name(pv)) == 'n') {
 		log_print("%s: physical volume not initialized", name);
 		return 0;
@@ -114,9 +115,7 @@
 
 	/* Wipe superblock? */
 	if (dev_is_md(dev, &md_superblock) &&
-	    ((!pp->idp &&
-	      !pp->restorefile) ||
-	     arg_count(cmd, yes_ARG) ||
+	    ((!pp->idp && !pp->restorefile) || pp->yes ||
 	     (yes_no_prompt("Software RAID md superblock "
 			    "detected on %s. Wipe it? [y/n] ", name) == 'y'))) {
 		log_print("Wiping software RAID md superblock on %s", name);
@@ -292,6 +291,7 @@
 		return 0;
 	}
 
+	pp->yes = arg_count(cmd, yes_ARG);
 	pp->force = arg_count(cmd, force_ARG);
 
 	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {


