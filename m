From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 6 Feb 2010 07:44:17 -0000
Subject: LVM2 tools/lvconvert.c ./WHATS_NEW
Message-ID: <20100206074417.4294.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-02-06 07:44:16

Modified files:
	tools          : lvconvert.c 
	.              : WHATS_NEW 

Log message:
	Make lvconvert --repair --use-policies exit with success when no action is needed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1422&r2=1.1423

--- LVM2/tools/lvconvert.c	2010/02/05 22:47:22	1.119
+++ LVM2/tools/lvconvert.c	2010/02/06 07:44:16	1.120
@@ -1247,6 +1247,8 @@
 	}
 
 	if (arg_count(cmd, repair_ARG) && !(lv->status & MIRRORED)) {
+		if (arg_count(cmd, use_policies_ARG))
+			return ECMD_PROCESSED; /* nothing to be done here */
 		log_error("Can't repair non-mirrored LV \"%s\".", lv->name);
 		return ECMD_FAILED;
 	}
--- LVM2/WHATS_NEW	2010/02/05 22:50:56	1.1422
+++ LVM2/WHATS_NEW	2010/02/06 07:44:16	1.1423
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Make lvconvert --repair --use-policies exit with success when no action is needed.
   Add multiple snapshot lv 'lvconvert --merge @tag' support via process_each_lv().
   Fix inappropriate second resync when adding mimage to core-logged mirror.
   Exclude internal VG names and uuids in lists returned via liblvm interface.


