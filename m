From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 22 Feb 2012 17:18:50 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20120222171850.22309.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-02-22 17:18:49

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Allow 'lvconvert --repair' to operate on RAID 4/5/6.
	
	The higher level RAIDs should be allowed for repair along with 'mirror' and
	'raid1' segment types.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2298&r2=1.2299
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.184&r2=1.185

--- LVM2/WHATS_NEW	2012/02/22 17:14:38	1.2298
+++ LVM2/WHATS_NEW	2012/02/22 17:18:49	1.2299
@@ -1,5 +1,6 @@
 Version 2.02.93 - 
 ====================================
+  Allow 'lvconvert --repair' to operate on RAID 4/5/6
   Fix 'build_parallel_areas_from_lv' to work properly with RAID 4/5/6
 
 Version 2.02.92 - 20th February 2012
--- LVM2/tools/lvconvert.c	2012/02/22 16:03:55	1.184
+++ LVM2/tools/lvconvert.c	2012/02/22 17:18:49	1.185
@@ -1736,7 +1736,8 @@
 		return ECMD_FAILED;
 	}
 
-	if (arg_count(cmd, repair_ARG) && !(lv->status & MIRRORED)) {
+	if (arg_count(cmd, repair_ARG) &&
+	    !(lv->status & MIRRORED) && !(lv->status & RAID)) {
 		if (arg_count(cmd, use_policies_ARG))
 			return ECMD_PROCESSED; /* nothing to be done here */
 		log_error("Can't repair non-mirrored LV \"%s\".", lv->name);


