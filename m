From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2012 21:53:18 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20120302215318.25431.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-02 21:53:17

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Support 16GB for thin pool metadata
	
	Add some hack math to allow 16GB devices to be passed as thinpool metadata.
	Since kernel has put in limit to not allow which are just bigger then
	some predefined constant in kernel but not matching 16GB so any device bigger
	is rejected.
	
	FIXME: Current code still might need more tweaks to be more generic.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.160&r2=1.161

--- LVM2/libdm/libdm-deptree.c	2012/03/02 21:43:27	1.160
+++ LVM2/libdm/libdm-deptree.c	2012/03/02 21:53:17	1.161
@@ -2968,7 +2968,15 @@
 				      uint64_t low_water_mark,
 				      unsigned skip_block_zeroing)
 {
-	struct load_segment *seg;
+	struct load_segment *seg, *mseg;
+	uint64_t devsize = 0;
+	/*
+	 * Max supported size for thin pool  metadata device
+	 * Limitation is hardcoded into kernel and bigger
+	 * device size is not accepted. (16978542592)
+	 */
+	const uint64_t max_metadata_size =
+		255ULL * (1 << 14) * (4096 / (1 << 9)) - 256 * 1024;
 
 	if (data_block_size < DM_THIN_MIN_DATA_BLOCK_SIZE) {
 		log_error("Data block size %u is lower then %u sectors.",
@@ -2993,6 +3001,18 @@
 	if (!_link_tree_nodes(node, seg->metadata))
 		return_0;
 
+	/* FIXME: more complex target may need more tweaks */
+	dm_list_iterate_items(mseg, &seg->metadata->props.segs) {
+		devsize += mseg->size;
+		if (devsize > max_metadata_size) {
+			log_debug("Ignoring %" PRIu64 " of device.",
+				  devsize - max_metadata_size);
+			mseg->size -= (devsize - max_metadata_size);
+			devsize = max_metadata_size;
+			/* FIXME: drop remaining segs */
+		}
+	}
+
 	if (!(seg->pool = dm_tree_find_node_by_uuid(node->dtree, pool_uuid))) {
 		log_error("Missing pool uuid %s.", pool_uuid);
 		return 0;


