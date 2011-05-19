From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 May 2011 13:59:25 -0000
Subject: LVM2 tools/toollib.c ./WHATS_NEW
Message-ID: <20110519135925.25029.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-05-19 13:59:23

Modified files:
	tools          : toollib.c 
	.              : WHATS_NEW 

Log message:
	Do not log a superfluous stack message when the lv is properly processed

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.225&r2=1.226
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1989&r2=1.1990

--- LVM2/tools/toollib.c	2011/03/11 14:56:56	1.225
+++ LVM2/tools/toollib.c	2011/05/19 13:59:22	1.226
@@ -351,12 +351,14 @@
 			ret = process_each_lv_in_vg(cmd, cvl_vg->vg, &lvnames,
 						    tags_arg, &failed_lvnames,
 						    handle, process_single_lv);
-			if (ret != ECMD_PROCESSED ||
-			    dm_list_empty(&failed_lvnames)) {
+			if (ret != ECMD_PROCESSED) {
 				stack;
 				break;
 			}
 
+			if (dm_list_empty(&failed_lvnames))
+				break;
+
 			/* Try again with failed LVs in this VG */
 			dm_list_init(&lvnames);
 			dm_list_splice(&lvnames, &failed_lvnames);
--- LVM2/WHATS_NEW	2011/05/12 12:42:47	1.1989
+++ LVM2/WHATS_NEW	2011/05/19 13:59:23	1.1990
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Do not log a superfluous stack message when the lv is properly processed.
   Do not issue an error message when unable to remove .cache on read-only fs.
   Avoid memlock size mismatch by preallocating stdio line buffers.
   Reorganize lvconvert --repair code to allow reuse.


