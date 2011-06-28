From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jun 2011 09:24:14 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20110628092414.16758.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-28 09:24:14

Modified files:
	libdm          : libdm-common.c 

Log message:
	more fixes to readahead etc.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/libdm/libdm-common.c	2011/06/27 22:38:53	1.120
+++ LVM2/libdm/libdm-common.c	2011/06/28 09:24:13	1.121
@@ -864,13 +864,6 @@
 	char *pos;
 
 	/*
-	 * Clear warn_if_udev_failed if rely_on_udev is set.  It doesn't get
-	 * checked in this case - this just removes the flag from log messages.
-	 */
-	if (rely_on_udev)
-		warn_if_udev_failed = 0;
-
-	/*
 	 * Note: warn_if_udev_failed must have valid content
 	 */
 	if ((type == NODE_DEL) && _other_node_ops(type))
@@ -911,10 +904,16 @@
 		 */
 		dm_list_iterate_safe(noph, nopht, &_node_ops) {
 			nop = dm_list_item(noph, struct node_op_parms);
-			if (!strcmp(old_name, nop->dev_name))
+			if (!strcmp(old_name, nop->dev_name)) {
 				_log_node_op("Unstacking", nop);
 				_del_node_op(nop);
+			}
 		}
+	else if (type == NODE_READ_AHEAD) {
+		/* udev doesn't process readahead */
+		rely_on_udev = 0;
+		warn_if_udev_failed = 0;
+	}
 
 	if (!(nop = dm_malloc(sizeof(*nop) + len))) {
 		log_error("Insufficient memory to stack mknod operation");
@@ -930,9 +929,14 @@
 	nop->mode = mode;
 	nop->read_ahead = read_ahead;
 	nop->read_ahead_flags = read_ahead_flags;
-	nop->warn_if_udev_failed = warn_if_udev_failed;
 	nop->rely_on_udev = rely_on_udev;
 
+	/*
+	 * Clear warn_if_udev_failed if rely_on_udev is set.  It doesn't get
+	 * checked in this case - this just removes the flag from log messages.
+	 */
+	nop->warn_if_udev_failed = rely_on_udev ? 0 : warn_if_udev_failed;
+
 	_store_str(&pos, &nop->dev_name, dev_name);
 	_store_str(&pos, &nop->old_name, old_name);
 


