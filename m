From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2008 19:46:34 -0000
Subject: LVM2 ./WHATS_NEW lib/device/device.h tools/pvc ...
Message-ID: <20080723194634.12755.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-23 19:46:33

Modified files:
	.              : WHATS_NEW 
	lib/device     : device.h 
	tools          : pvcreate.c pvremove.c 

Log message:
	Remove dead code, is_lvm_partition() - no functional change.
	
	This code does nothing.  The function is #defined to 1 which ensures the only
	two if statements referencing it will never be true.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.933&r2=1.934
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2008/07/21 19:26:33	1.933
+++ LVM2/WHATS_NEW	2008/07/23 19:46:33	1.934
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Remove dead code, is_lvm_partition() - no functional change.
   Refactor pvcreate to divide parameter parsing & validation from create logic.
   Check for label_write() failure in _text_pv_write().
   Add pvcreate tests and update vgsplit tests to handle lvm1 and lvm2 metadata.
--- LVM2/lib/device/device.h	2007/08/20 20:55:25	1.34
+++ LVM2/lib/device/device.h	2008/07/23 19:46:33	1.35
@@ -94,11 +94,6 @@
 /* Does device contain md superblock?  If so, where? */
 int dev_is_md(struct device *dev, uint64_t *sb);
 
-/* FIXME Check partition type if appropriate */
-
-#define is_lvm_partition(a) 1
-/* int is_lvm_partition(const char *name); */
-
 int is_partitioned_dev(struct device *dev);
 
 #endif
--- LVM2/tools/pvcreate.c	2008/07/23 19:29:58	1.66
+++ LVM2/tools/pvcreate.c	2008/07/23 19:46:33	1.67
@@ -37,13 +37,6 @@
 	struct device *dev;
 	uint64_t md_superblock;
 
-	/* is the partition type set correctly ? */
-	if ((arg_count(cmd, force_ARG) < 1) && !is_lvm_partition(name)) {
-		log_error("%s: Not LVM partition type: use -f to override",
-			  name);
-		return 0;
-	}
-
 	/* Is there a pv here already? */
 	/* FIXME Use partial mode here? */
 	pv = pv_read(cmd, name, NULL, NULL, 0);
--- LVM2/tools/pvremove.c	2007/11/22 01:25:06	1.21
+++ LVM2/tools/pvremove.c	2008/07/23 19:46:33	1.22
@@ -26,13 +26,6 @@
 {
 	struct physical_volume *pv;
 
-	/* is the partition type set correctly ? */
-	if ((arg_count(cmd, force_ARG) < 1) && !is_lvm_partition(name)) {
-		log_error("%s: Not LVM partition type: use -f to override",
-			  name);
-		return 0;
-	}
-
 	/* Is there a pv here already? */
 	/* If not, this is an error unless you used -f. */
 	if (!(pv = pv_read(cmd, name, NULL, NULL, 1))) {


