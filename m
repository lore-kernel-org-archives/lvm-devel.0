From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 10:56:21 -0000
Subject: LVM2 ./WHATS_NEW tools/lvresize.c
Message-ID: <20120208105621.24354.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 10:56:18

Modified files:
	.              : WHATS_NEW 
	tools          : lvresize.c 

Log message:
	Set status for error path
	
	Do not leave status unitialized, since in some cases, it's tested,
	when the function returns error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2261&r2=1.2262
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149

--- LVM2/WHATS_NEW	2012/02/08 10:52:45	1.2261
+++ LVM2/WHATS_NEW	2012/02/08 10:56:17	1.2262
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Set status in _fsadm_cmd() for error path.
   Add missing deps for lvm2api for rebuild when lvm-internal is changed.
   Fix resource leaks for failing allocation of formats (lvm1/2,pool).
   Release allocated resources in error path for composite_filter_create().
--- LVM2/tools/lvresize.c	2012/01/19 15:25:39	1.148
+++ LVM2/tools/lvresize.c	2012/02/08 10:56:18	1.149
@@ -159,6 +159,9 @@
 
 	argv[i++] = (fcmd == FSADM_CMD_RESIZE) ? "resize" : "check";
 
+	if (status)
+		*status = -1;
+
 	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir, lp->vg_name,
 			lp->lv_name) < 0) {
 		log_error("Couldn't create LV path for %s", lp->lv_name);


