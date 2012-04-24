From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 24 Apr 2012 08:24:37 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20120424082437.30937.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-04-24 08:24:37

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Also rename DevNos header to DevNosUsed in dmsetup info -c output.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.598&r2=1.599
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.188&r2=1.189

--- LVM2/WHATS_NEW_DM	2012/04/24 08:00:55	1.598
+++ LVM2/WHATS_NEW_DM	2012/04/24 08:24:36	1.599
@@ -1,6 +1,6 @@
 Version 1.02.75 - 
 ================================
-  Rename (Blk)DevNames header to (Blk)DevNamesUsed in dmsetup info -c output.
+  Rename (Blk)DevNames/DevNos dmsetup header to (Blk)DevNamesUsed/DevNosUsed.
   Add configure --with-veritysetup for independent veritysetup tool.
   Properly support passed in dmevent path in dm_event_register_handler().
   Remove dmeventd fifos on exit if they are not managed by systemd.
--- LVM2/tools/dmsetup.c	2012/04/24 08:00:56	1.188
+++ LVM2/tools/dmsetup.c	2012/04/24 08:24:36	1.189
@@ -2760,7 +2760,7 @@
 
 FIELD_O(DEPS, dm_deps, NUM, "#Devs", count, 5, int32, "device_count", "Number of devices used by this one.")
 FIELD_F(TREE, STR, "DevNamesUsed", 16, dm_deps_names, "devs_used", "List of names of mapped devices used by this one.")
-FIELD_F(DEPS, STR, "DevNos", 6, dm_deps, "devnos_used", "List of device numbers of devices used by this one.")
+FIELD_F(DEPS, STR, "DevNosUsed", 16, dm_deps, "devnos_used", "List of device numbers of devices used by this one.")
 FIELD_F(DEPS, STR, "BlkDevNamesUsed", 16, dm_deps_blk_names, "blkdevs_used", "List of names of block devices used by this one.")
 
 FIELD_F(TREE, NUM, "#Refs", 5, dm_tree_parents_count, "device_ref_count", "Number of mapped devices referencing this one.")


