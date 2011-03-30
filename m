From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 12:14:38 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c
Message-ID: <20110330121438.20186.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 12:14:37

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c 

Log message:
	Fix 2 signess warnings reported by gcc
	
	Replace int with unsigned counter.
	Replace snprintf with dm_snprintf.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.459&r2=1.460
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/WHATS_NEW_DM	2011/03/29 21:49:18	1.459
+++ LVM2/WHATS_NEW_DM	2011/03/30 12:14:36	1.460
@@ -1,5 +1,7 @@
 Version 1.02.64 - 
 ===================================
+  Use dm_snprintf() to fix signess warning in dm_set_dev_dir().
+  Use unsigned loop counter to fix signess warning in _other_node_ops().
   Fix const cast in dmsetup calls of dm_report_field_string().
   Streamline /dev/mapper/control node code for common cases.
   Use hard-coded dm control node device number for 2.6.36 kernels and above.
--- LVM2/libdm/libdm-common.c	2011/03/29 21:53:47	1.115
+++ LVM2/libdm/libdm-common.c	2011/03/30 12:14:36	1.116
@@ -794,7 +794,7 @@
 /* Check if there is other the type of node operation stacked */
 static int _other_node_ops(node_op_t type)
 {
-	int i;
+	unsigned i;
 
 	for (i = 0; i < NUM_NODES; i++)
 		if (type != i && _count_node_ops[i])
@@ -958,8 +958,7 @@
 	len = strlen(dev_dir);
 	slash = dev_dir[len-1] == '/' ? "" : "/";
 
-	if (snprintf(_dm_dir, sizeof _dm_dir, "%s%s%s", dev_dir, slash, DM_DIR)
-	    >= sizeof _dm_dir) {
+	if (dm_snprintf(_dm_dir, sizeof _dm_dir, "%s%s%s", dev_dir, slash, DM_DIR) < 0) {
 		log_debug("Invalid dev_dir value, %s: name too long.", dev_dir);
 		return 0;
 	}


