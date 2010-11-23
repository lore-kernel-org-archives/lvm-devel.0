From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2010 20:39:15 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20101123203915.11523.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-23 20:39:14

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Move arg_vgnames from local scope
	
	As gcc puts probably all vars on stack this bug was not noticed in runtime.
	Patch fixes referencing local scope list variable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1804&r2=1.1805
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.213&r2=1.214

--- LVM2/WHATS_NEW	2010/11/23 18:29:06	1.1804
+++ LVM2/WHATS_NEW	2010/11/23 20:39:13	1.1805
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Fix out-of-scope variable usage in process_each_lv().
   Fix dm_task_destroy(NULL) call in _node_clear_table() error path.
   Fix resource leak in _rm_blks().
   Suppress 'No PV label' message when removing several PVs without mdas.
--- LVM2/tools/toollib.c	2010/11/23 01:56:02	1.213
+++ LVM2/tools/toollib.c	2010/11/23 20:39:14	1.214
@@ -198,6 +198,7 @@
 	struct dm_list failed_lvnames;
 	struct dm_list tags, lvnames;
 	struct dm_list arg_lvnames;	/* Cmdline vgname or vgname/lvname */
+	struct dm_list arg_vgnames;
 	char *vglv;
 	size_t vglv_sz;
 
@@ -208,8 +209,6 @@
 	dm_list_init(&failed_lvnames);
 
 	if (argc) {
-		struct dm_list arg_vgnames;
-
 		log_verbose("Using logical volume(s) on command line");
 		dm_list_init(&arg_vgnames);
 


