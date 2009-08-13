From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Aug 2009 14:27:33 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c
Message-ID: <20090813142733.24308.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-08-13 14:27:33

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c 

Log message:
	Make lvchange --refresh only take a read lock on volume group.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1238&r2=1.1239
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109

--- LVM2/WHATS_NEW	2009/08/13 13:23:51	1.1238
+++ LVM2/WHATS_NEW	2009/08/13 14:27:32	1.1239
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Make lvchange --refresh only take a read lock on volume group.
   Fix bug where non-blocking file locks could be granted in error.
   Make lvm2app pv_t, lv_t, vg_t handle definitions consistent with lvm_t.
   Fix vgextend error path - if ORPHAN lock fails, unlock / release vg (2.02.49).
--- LVM2/tools/lvchange.c	2009/07/15 05:49:48	1.108
+++ LVM2/tools/lvchange.c	2009/08/13 14:27:33	1.109
@@ -690,12 +690,11 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	int avail_only =
+	int avail_only = /* i.e. only one of -a or --refresh is given */
 	    !(arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 	     arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
-	     arg_count(cmd, refresh_ARG) || arg_count(cmd, alloc_ARG) ||
-	     arg_count(cmd, resync_ARG));
+	     arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG));
 
 	if (arg_count(cmd, ignorelockingfailure_ARG) && !avail_only) {
 		log_error("Only -a permitted with --ignorelockingfailure");


