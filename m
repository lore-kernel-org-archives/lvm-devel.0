From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 24 Apr 2012 08:00:57 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20120424080057.21408.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-04-24 08:00:56

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Rename (Blk)DevNames header to (Blk)DevNamesUsed in dmsetup info -c output.
	
	Just to make it clearer since there is the "dmsetup info -c -o blkdevname"
	as well that shows the "block device name for this mapping", having a
	"BlkDevName" header on output.
	
	It's a bit confusing then if the "dmsetup info -c -o devs_used,blkdevs_used"
	is named with a plural "DevNames"/"BlkDevNames" but at the same time having
	a totally different meaning than the singular form "BlkDevName".
	
	DevNames --> DevNamesUsed
	BlkDevNames --> BlkDevNamesUsed
	
	...makes it much more comprehensible.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.597&r2=1.598
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.187&r2=1.188

--- LVM2/WHATS_NEW_DM	2012/03/24 01:59:59	1.597
+++ LVM2/WHATS_NEW_DM	2012/04/24 08:00:55	1.598
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Rename (Blk)DevNames header to (Blk)DevNamesUsed in dmsetup info -c output.
   Add configure --with-veritysetup for independent veritysetup tool.
   Properly support passed in dmevent path in dm_event_register_handler().
   Remove dmeventd fifos on exit if they are not managed by systemd.
--- LVM2/tools/dmsetup.c	2012/03/06 02:42:31	1.187
+++ LVM2/tools/dmsetup.c	2012/04/24 08:00:56	1.188
@@ -2759,9 +2759,9 @@
 FIELD_O(INFO, dm_info, NUM, "Event", event_nr, 6, uint32, "events", "Number of most recent event.")
 
 FIELD_O(DEPS, dm_deps, NUM, "#Devs", count, 5, int32, "device_count", "Number of devices used by this one.")
-FIELD_F(TREE, STR, "DevNames", 8, dm_deps_names, "devs_used", "List of names of mapped devices used by this one.")
+FIELD_F(TREE, STR, "DevNamesUsed", 16, dm_deps_names, "devs_used", "List of names of mapped devices used by this one.")
 FIELD_F(DEPS, STR, "DevNos", 6, dm_deps, "devnos_used", "List of device numbers of devices used by this one.")
-FIELD_F(DEPS, STR, "BlkDevNames", 16, dm_deps_blk_names, "blkdevs_used", "List of names of block devices used by this one.")
+FIELD_F(DEPS, STR, "BlkDevNamesUsed", 16, dm_deps_blk_names, "blkdevs_used", "List of names of block devices used by this one.")
 
 FIELD_F(TREE, NUM, "#Refs", 5, dm_tree_parents_count, "device_ref_count", "Number of mapped devices referencing this one.")
 FIELD_F(TREE, STR, "RefNames", 8, dm_tree_parents_names, "names_using_dev", "List of names of mapped devices using this one.")


