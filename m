From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Feb 2012 20:13:41 -0000
Subject: LVM2 ./WHATS_NEW lib/raid/raid.c libdm/libdevm ...
Message-ID: <20120213201341.28684.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-02-13 20:13:40

Modified files:
	.              : WHATS_NEW 
	lib/raid       : raid.c 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Make conversion from a synced 'mirror' to 'raid1' not cause a full resync.
	
	It was not possible to pass down the DM_[FORCE|NO]SYNC flags to
	'dm_tree_node_add_raid_target'.  This meant that converting to 'raid1' from
	'mirror' would cause a full resync.  (It also meant that '--nosync' was
	ineffective when creating a 'raid1' LV.)
	
	I've taken the 'reserved' parameter in 'dm_tree_node_add_raid_target' and
	used it for the "flags" parameter.  Now it is possible to pass the sync
	flags and any other flags that may come up.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2292&r2=1.2293
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.177&r2=1.178
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157

--- LVM2/WHATS_NEW	2012/02/13 14:23:40	1.2292
+++ LVM2/WHATS_NEW	2012/02/13 20:13:39	1.2293
@@ -1,5 +1,6 @@
 Version 2.02.92 - 
 ====================================
+  Make conversion from a synced 'mirror' to 'raid1' not cause a full resync.
   Properly test buffer for unit check in units_to_bytes().
   Add configure --with-systemdsystemunitdir.
   Add check for allocation failure in _build_matcher().
--- LVM2/lib/raid/raid.c	2012/01/25 21:54:00	1.14
+++ LVM2/lib/raid/raid.c	2012/02/13 20:13:40	1.15
@@ -159,6 +159,7 @@
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	uint32_t s;
+	uint64_t flags = 0;
 	uint64_t rebuilds = 0;
 
 	if (!seg->area_count) {
@@ -186,9 +187,12 @@
 		if (seg_lv(seg, s)->status & LV_REBUILD)
 			rebuilds |= 1 << s;
 
+	if (mirror_in_sync())
+		flags = DM_NOSYNC;
+
 	if (!dm_tree_node_add_raid_target(node, len, _raid_name(seg),
 					  seg->region_size, seg->stripe_size,
-					  rebuilds, 0))
+					  rebuilds, flags))
 		return_0;
 
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
--- LVM2/libdm/libdevmapper.h	2012/01/23 17:46:31	1.177
+++ LVM2/libdm/libdevmapper.h	2012/02/13 20:13:40	1.178
@@ -548,7 +548,7 @@
 				 uint32_t region_size,
 				 uint32_t stripe_size,
 				 uint64_t rebuilds,
-				 uint64_t reserved2);
+				 uint64_t flags);
 
 /*
  * Replicator operation mode
--- LVM2/libdm/libdm-deptree.c	2012/02/10 14:48:28	1.156
+++ LVM2/libdm/libdm-deptree.c	2012/02/13 20:13:40	1.157
@@ -2751,7 +2751,7 @@
 				 uint32_t region_size,
 				 uint32_t stripe_size,
 				 uint64_t rebuilds,
-				 uint64_t reserved2)
+				 uint64_t flags)
 {
 	int i;
 	struct load_segment *seg = NULL;
@@ -2769,6 +2769,7 @@
 	seg->stripe_size = stripe_size;
 	seg->area_count = 0;
 	seg->rebuilds = rebuilds;
+	seg->flags = flags;
 
 	return 1;
 }


