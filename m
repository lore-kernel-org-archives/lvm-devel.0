From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 21:50:51 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
Message-ID: <20120125215051.32329.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 21:50:51

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	Ensure whole info is initialised
	
	Since _create_dm_tree_node is copying whole structure,
	make sure all members are initialized.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.532&r2=1.533
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153

--- LVM2/WHATS_NEW_DM	2012/01/18 18:52:02	1.532
+++ LVM2/WHATS_NEW_DM	2012/01/25 21:50:50	1.533
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Reset all members of info struct in dm_tree_add_new_dev_with_udev_flags.
   Add dmsetup wipe_table to replace table with one that uses error target.
   Add 'blkdevname' and 'blkdevs_used' field to dmsetup info -c -o.
   Add 'blkdevname' option to dmsetup ls --tree to see block device names.
--- LVM2/libdm/libdm-deptree.c	2012/01/25 08:46:21	1.152
+++ LVM2/libdm/libdm-deptree.c	2012/01/25 21:50:51	1.153
@@ -1101,12 +1101,7 @@
 			return NULL;
 		}
 
-		info.major = 0;
-		info.minor = 0;
-		info.exists = 0;
-		info.live_table = 0;
-		info.inactive_table = 0;
-		info.read_only = 0;
+		memset(&info, 0, sizeof(info));
 
 		if (!(dnode = _create_dm_tree_node(dtree, name2, uuid2, &info,
 						   context, 0)))


