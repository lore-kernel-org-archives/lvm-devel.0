From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Jun 2007 15:11:19 -0000
Subject: LVM2 tools/vgcfgrestore.c lib/config/config.c ...
Message-ID: <20070613151119.5467.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-13 15:11:19

Modified files:
	tools          : vgcfgrestore.c 
	lib/config     : config.c 
	.              : WHATS_NEW 

Log message:
	Fix a couple benign warnings by adding variable initializations.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.628&r2=1.629

--- LVM2/tools/vgcfgrestore.c	2007/06/08 22:38:48	1.14
+++ LVM2/tools/vgcfgrestore.c	2007/06/13 15:11:19	1.15
@@ -17,7 +17,7 @@
 
 int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 {
-	char *vg_name;
+	char *vg_name = NULL;
 
 	if (argc == 1) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
--- LVM2/lib/config/config.c	2007/04/27 20:41:50	1.58
+++ LVM2/lib/config/config.c	2007/06/13 15:11:19	1.59
@@ -188,7 +188,7 @@
 	int r = 0;
 	int use_mmap = 1;
 	off_t mmap_offset = 0;
-	char *buf;
+	char *buf = NULL;
 
 	if (!(p = dm_pool_alloc(c->mem, sizeof(*p)))) {
 		stack;
--- LVM2/WHATS_NEW	2007/06/12 22:41:27	1.628
+++ LVM2/WHATS_NEW	2007/06/13 15:11:19	1.629
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Fix a couple benign warnings by adding variable initializations.
   Convert find_pv_in_vg_by_uuid and pv_create to use PV handles.
   Add get_pv_* functions to return PV members (external LVM library).
   Add wrappers to some functions in preparation for external LVM library.


