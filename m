From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2012 17:36:25 -0000
Subject: LVM2 ./WHATS_NEW libdm/libdm-deptree.c
Message-ID: <20120304173625.20524.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-04 17:36:24

Modified files:
	.              : WHATS_NEW 
	libdm          : libdm-deptree.c 

Log message:
	Return success for deactivation of thin pool
	
	if the thin_check fail on thin pool - still return successful deactivation,
	since lvremove would currently fail.
	
	TODO: find some way to not run check with lvremove.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2339&r2=1.2340
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.162&r2=1.163

--- LVM2/WHATS_NEW	2012/03/03 18:32:53	1.2339
+++ LVM2/WHATS_NEW	2012/03/04 17:36:23	1.2340
@@ -1,5 +1,6 @@
 Version 2.02.95 -
 ================================
+  Deactivation of failed thin check on thin pool returns success.
   Scan all devices for lvmetad if 'pvscan --cache' used without device list.
   Populate lvmcache from lvmetad before displaying PVs in pvscan. (2.02.94)
   Suppress incorrect -n pvscan warning now always displayed. (2.02.94)
--- LVM2/libdm/libdm-deptree.c	2012/03/04 16:05:42	1.162
+++ LVM2/libdm/libdm-deptree.c	2012/03/04 17:36:24	1.163
@@ -1591,7 +1591,10 @@
 		if (child->callback &&
 		    !child->callback(child, DM_NODE_CALLBACK_DEACTIVATED,
 				     child->callback_data))
-			r = 0; // FIXME: _node_clear_table() without callback ?
+			stack;
+			// FIXME: We need to let lvremove pass,
+			// so for now deactivation ignores check result
+			//r = 0; // FIXME: _node_clear_table() without callback ?
 
 		if (dm_tree_node_num_children(child, 0) &&
 		    !_dm_tree_deactivate_children(child, uuid_prefix, uuid_prefix_len, level + 1))


