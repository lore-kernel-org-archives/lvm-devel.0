From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Mar 2011 22:43:22 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20110308224322.21943.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-08 22:43:20

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Fix reading byte from char params[-1] position
	
	When the ->params string is empty - memory access is made on the byte
	before allocated buffer (catched by valgrind) - in the case it would
	constain 0x20 - it would even overwrite this buffer.
	So fix by checking len > 0 before doing such access.
	Also slightly optimise this loop from repeated strlen call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.453&r2=1.454
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/WHATS_NEW_DM	2011/03/03 13:05:40	1.453
+++ LVM2/WHATS_NEW_DM	2011/03/08 22:43:19	1.454
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Fix memory access of empty params string in _reload_with_suppression_v4().
   Lower severity of selabel_lookup and matchpathcon failure to log_debug.
   Accept multiple mapped device names on many dmsetup command lines.
   Fix dm_udev_wait calls in dmsetup to occur before readahead display not after.
--- LVM2/libdm/ioctl/libdm-iface.c	2011/03/05 21:17:19	1.98
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/03/08 22:43:20	1.99
@@ -1836,6 +1836,7 @@
 {
 	struct dm_task *task;
 	struct target *t1, *t2;
+	size_t len;
 	int r;
 
 	/* New task to get existing table information */
@@ -1878,8 +1879,9 @@
 	t2 = task->head;
 
 	while (t1 && t2) {
-		while (t2->params[strlen(t2->params) - 1] == ' ')
-			t2->params[strlen(t2->params) - 1] = '\0';
+		len = strlen(t2->params);
+		while (len-- > 0 && t2->params[len] == ' ')
+			t2->params[len] = '\0';
 		if ((t1->start != t2->start) ||
 		    (t1->length != t2->length) ||
 		    (strcmp(t1->type, t2->type)) ||


