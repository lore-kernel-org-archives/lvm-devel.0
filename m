From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Aug 2011 16:26:04 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20110819162604.11816.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-19 16:26:03

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	restrict dm_tree_node_add_null_area

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.492&r2=1.493
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.143&r2=1.144
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/WHATS_NEW_DM	2011/08/12 02:34:08	1.492
+++ LVM2/WHATS_NEW_DM	2011/08/19 16:26:02	1.493
@@ -1,5 +1,6 @@
 Version 1.02.67 - 
 ==================================
+  Add dm_tree_node_add_null_area for temporarily-missing raid devs tracked.
 
 Version 1.02.66 - 12th August 2011
 ==================================
--- LVM2/libdm/libdevmapper.h	2011/08/18 19:41:22	1.143
+++ LVM2/libdm/libdevmapper.h	2011/08/19 16:26:03	1.144
@@ -516,6 +516,10 @@
 				    const char *dev_name,
 				    const char *dlid,
 				    uint64_t offset);
+
+/*
+ * Only for temporarily-missing raid devices where changes are tracked.
+ */
 int dm_tree_node_add_null_area(struct dm_tree_node *node, uint64_t offset);
 
 /*
--- LVM2/libdm/libdm-deptree.c	2011/08/18 19:41:22	1.106
+++ LVM2/libdm/libdm-deptree.c	2011/08/19 16:26:03	1.107
@@ -2629,6 +2629,22 @@
 
 	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
 
+	switch (seg->type) {
+	case SEG_RAID1:
+	case SEG_RAID4:
+	case SEG_RAID5_LA:
+	case SEG_RAID5_RA:
+	case SEG_RAID5_LS:
+	case SEG_RAID5_RS:
+	case SEG_RAID6_ZR:
+	case SEG_RAID6_NR:
+	case SEG_RAID6_NC:
+		break;
+	default:
+		log_error("dm_tree_node_add_null_area() called on an unsupported segment type");
+		return 0;
+	}
+
 	if (!_add_area(node, seg, NULL, offset))
 		return_0;
 


