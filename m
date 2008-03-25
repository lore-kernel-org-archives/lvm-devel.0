From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Mar 2008 15:25:03 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c tools/toollib.h
Message-ID: <20080325152503.12645.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-25 15:25:00

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c toollib.h 

Log message:
	Add 'is_reserved_lvname()' helper function.
	
	Very similar to apply_lvname_restrictions but without the error messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.806&r2=1.807
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2008/03/25 12:37:47	1.806
+++ LVM2/WHATS_NEW	2008/03/25 15:24:57	1.807
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Add 'is_reserved_lvname()' helper function.
   Correct command name in lvmdiskscan man page.
   clvmd no longer crashes if it sees nodeids over 50.
   Fix potential deadlock in clvmd thread handling.
--- LVM2/tools/toollib.c	2008/02/06 16:09:51	1.131
+++ LVM2/tools/toollib.c	2008/03/25 15:24:59	1.132
@@ -1234,6 +1234,19 @@
 	return 1;
 }
 
+int is_reserved_lvname(const char *name)
+{
+	int rc, old_suppress;
+
+	old_suppress = log_suppress(2);
+	rc = !apply_lvname_restrictions(name);
+	log_suppress(old_suppress);
+
+	return rc;
+}
+
+
+
 /*
  * Set members of struct vgcreate_params from cmdline.
  * Do preliminary validation with arg_*() interface.
--- LVM2/tools/toollib.h	2008/01/15 22:56:30	1.56
+++ LVM2/tools/toollib.h	2008/03/25 15:24:59	1.57
@@ -95,6 +95,7 @@
 struct list *clone_pv_list(struct dm_pool *mem, struct list *pvs);
 
 int apply_lvname_restrictions(const char *name);
+int is_reserved_lvname(const char *name);
 
 int fill_vg_create_params(struct cmd_context *cmd,
 			  char *vg_name, struct vgcreate_params *vp_new,


