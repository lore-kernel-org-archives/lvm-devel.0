From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2011 20:19:07 -0000
Subject: LVM2 lib/device/dev-io.c lib/metadata/lv_manip ...
Message-ID: <20110329201907.10155.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-29 20:19:05

Modified files:
	lib/device     : dev-io.c 
	lib/metadata   : lv_manip.c pv_manip.c 
	libdm          : libdm-deptree.c 
	tools          : pvmove.c vgreduce.c 

Log message:
	Remove double braces
	
	Clang gives notice about possible confusion as commonly double bracces are
	used when some assignment is done inside them.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.253&r2=1.254
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/lib/device/dev-io.c	2011/02/18 23:09:55	1.74
+++ LVM2/lib/device/dev-io.c	2011/03/29 20:19:03	1.75
@@ -126,7 +126,7 @@
 {
 	const char *name = dev_name(dev);
 
-	if ((dev->block_size == -1)) {
+	if (dev->block_size == -1) {
 		if (ioctl(dev_fd(dev), BLKBSZGET, &dev->block_size) < 0) {
 			log_sys_error("ioctl BLKBSZGET", name);
 			return 0;
--- LVM2/lib/metadata/lv_manip.c	2011/03/29 12:51:57	1.253
+++ LVM2/lib/metadata/lv_manip.c	2011/03/29 20:19:04	1.254
@@ -736,11 +736,11 @@
 
 	/* Are there any preceding segments we must follow on from? */
 	if (alloc_parms->prev_lvseg) {
-		if ((alloc_parms->alloc == ALLOC_CONTIGUOUS))
+		if (alloc_parms->alloc == ALLOC_CONTIGUOUS)
 			alloc_parms->flags |= A_CONTIGUOUS;
-		else if ((alloc_parms->alloc == ALLOC_CLING))
+		else if (alloc_parms->alloc == ALLOC_CLING)
 			alloc_parms->flags |= A_CLING;
-		else if ((alloc_parms->alloc == ALLOC_CLING_BY_TAGS)) {
+		else if (alloc_parms->alloc == ALLOC_CLING_BY_TAGS) {
 			alloc_parms->flags |= A_CLING;
 			alloc_parms->flags |= A_CLING_BY_TAGS;
 		}
--- LVM2/lib/metadata/pv_manip.c	2011/02/21 13:09:27	1.27
+++ LVM2/lib/metadata/pv_manip.c	2011/03/29 20:19:04	1.28
@@ -468,7 +468,7 @@
 			return 0;
 		}
 
-		if ((new_pe_count == old_pe_count)) {
+		if (new_pe_count == old_pe_count) {
 			pv->pe_count = old_pe_count;
 			log_verbose("No change to size of physical volume %s.",
 				    pv_dev_name(pv));
--- LVM2/libdm/libdm-deptree.c	2011/03/02 00:29:57	1.91
+++ LVM2/libdm/libdm-deptree.c	2011/03/29 20:19:04	1.92
@@ -329,13 +329,13 @@
 static int _link_tree_nodes(struct dm_tree_node *parent, struct dm_tree_node *child)
 {
 	/* Don't link to root node if child already has a parent */
-	if ((parent == &parent->dtree->root)) {
+	if (parent == &parent->dtree->root) {
 		if (dm_tree_node_num_children(child, 1))
 			return 1;
 	} else
 		_remove_from_toplevel(child);
 
-	if ((child == &child->dtree->root)) {
+	if (child == &child->dtree->root) {
 		if (dm_tree_node_num_children(parent, 0))
 			return 1;
 	} else
--- LVM2/tools/pvmove.c	2011/03/11 14:56:56	1.82
+++ LVM2/tools/pvmove.c	2011/03/29 20:19:04	1.83
@@ -121,7 +121,7 @@
 		}
 
 		/* Remove PV if full */
-		if ((pvl->pv->pe_count == pvl->pv->pe_alloc_count))
+		if (pvl->pv->pe_count == pvl->pv->pe_alloc_count)
 			dm_list_del(&pvl->list);
 	}
 
@@ -202,7 +202,7 @@
 	/* Find segments to be moved and set up mirrors */
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
-		if ((lv == lv_mirr))
+		if (lv == lv_mirr)
 			continue;
 		if (lv_name) {
 			if (strcmp(lv->name, lv_name))
--- LVM2/tools/vgreduce.c	2011/03/11 14:56:56	1.109
+++ LVM2/tools/vgreduce.c	2011/03/29 20:19:04	1.110
@@ -287,8 +287,8 @@
 			if (mirrored_seg->log_lv) {
 				dm_list_iterate_items(seg, &mirrored_seg->log_lv->segments) {
 					/* FIXME: The second test shouldn't be required */
-					if ((seg->segtype ==
-					     get_segtype_from_string(vg->cmd, "error"))) {
+					if (seg->segtype ==
+					    get_segtype_from_string(vg->cmd, "error")) {
 						log_print("The log device for %s/%s has failed.",
 							  vg->name, mirrored_seg->lv->name);
 						remove_log = 1;


