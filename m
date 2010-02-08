From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 8 Feb 2010 23:28:07 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20100208232807.5477.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-02-08 23:28:06

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Remove false "failed to find tree node for <lv>" error from _cached_info().
	
	When activating a merging origin it is valid, and expected, to not have
	a node in the deptree for both the origin and its merging snapshot.  The
	_cached_info() caller is only concerned with whether a device is open.
	If there isn't a node in the tree the associated device is definitely
	not open.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1423&r2=1.1424
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.178&r2=1.179

--- LVM2/WHATS_NEW	2010/02/06 07:44:16	1.1423
+++ LVM2/WHATS_NEW	2010/02/08 23:28:06	1.1424
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Remove false "failed to find tree node for" error when activating merging origin.
   Make lvconvert --repair --use-policies exit with success when no action is needed.
   Add multiple snapshot lv 'lvconvert --merge @tag' support via process_each_lv().
   Fix inappropriate second resync when adding mimage to core-logged mirror.
--- LVM2/lib/activate/dev_manager.c	2010/01/26 07:58:23	1.178
+++ LVM2/lib/activate/dev_manager.c	2010/02/08 23:28:06	1.179
@@ -264,10 +264,9 @@
 		return NULL;
 	}
 
-	if (!(dnode = dm_tree_find_node_by_uuid(dtree, dlid))) {
-		log_error("failed to find tree node for %s", lv->name);
+	/* An activating merging origin won't have a node in the tree yet */
+	if (!(dnode = dm_tree_find_node_by_uuid(dtree, dlid)))
 		return NULL;
-	}
 
 	if (!(dinfo = dm_tree_node_get_info(dnode))) {
 		log_error("failed to get info from tree node for %s", lv->name);


