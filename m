From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Mar 2010 14:24:05 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c tools/toollib.h
Message-ID: <20100323142405.24624.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-23 14:24:04

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c toollib.h 

Log message:
	Remove const modifier for struct volume_group* from process_each_lv_in_vg().
	Content of this pointer is not const during this function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1472&r2=1.1473
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.188&r2=1.189
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2010/03/20 03:44:04	1.1472
+++ LVM2/WHATS_NEW	2010/03/23 14:24:04	1.1473
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Remove const modifier for struct volume_group* from process_each_lv_in_vg().
   Don't allow resizing of internal logical volumes.
   Fix libdevmapper-event pkgconfig version string to match libdevmapper.
   Avoid scanning all pvs in the system if operating on a device with mdas.
--- LVM2/tools/toollib.c	2010/03/18 17:29:12	1.188
+++ LVM2/tools/toollib.c	2010/03/23 14:24:04	1.189
@@ -83,7 +83,7 @@
  * Metadata iteration functions
  */
 int process_each_lv_in_vg(struct cmd_context *cmd,
-			  const struct volume_group *vg,
+			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
 			  void *handle,
--- LVM2/tools/toollib.h	2009/11/01 20:03:24	1.68
+++ LVM2/tools/toollib.h	2010/03/23 14:24:04	1.69
@@ -76,7 +76,7 @@
 				  void *handle);
 
 int process_each_lv_in_vg(struct cmd_context *cmd,
-			  const struct volume_group *vg,
+			  struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
 			  void *handle,


