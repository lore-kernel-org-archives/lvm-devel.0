From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 11:23:16 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20120227112316.32615.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 11:23:15

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 

Log message:
	Check for vg_name existance
	
	Since vg_read() mda ops could be called with NULL vg_name,
	check it before derefence also for pool and format1.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2315&r2=1.2316
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2012/02/27 11:13:48	1.2315
+++ LVM2/WHATS_NEW	2012/02/27 11:23:15	1.2316
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Check for existance of vg_name in _format1/_pool_vg_read().
   Fix missing break in _format_pvsegs (2.02.92).
   Test seg pointer for non-null it in raid_target_percent error path.
   Check for errors in _init_tags() during config loading.
--- LVM2/lib/format1/format1.c	2012/02/23 13:11:09	1.148
+++ LVM2/lib/format1/format1.c	2012/02/27 11:23:15	1.149
@@ -186,7 +186,8 @@
 	DM_LIST_INIT(pvs);
 
 	/* Strip dev_dir if present */
-	vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
+	if (vg_name)
+		vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
 
 	if (!(vg = alloc_vg("format1_vg_read", fid->fmt->cmd, NULL)))
 		return_NULL;
--- LVM2/lib/format_pool/format_pool.c	2012/02/23 13:11:09	1.53
+++ LVM2/lib/format_pool/format_pool.c	2012/02/27 11:23:15	1.54
@@ -110,7 +110,8 @@
 	/* We can safely ignore the mda passed in */
 
 	/* Strip dev_dir if present */
-	vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
+	if (vg_name)
+		vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
 
 	/* Set vg_name through read_pool_pds() */
 	if (!(vg = alloc_vg("pool_vg_read", fid->fmt->cmd, NULL)))


