From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:03:33 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20111011090333.31962.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:03:33

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Use shorter way for if()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.242&r2=1.243

--- LVM2/lib/activate/dev_manager.c	2011/10/11 09:02:20	1.242
+++ LVM2/lib/activate/dev_manager.c	2011/10/11 09:03:33	1.243
@@ -1224,8 +1224,7 @@
 		 * we don't have the struct definition available.
 		 */
 		struct dm_tree **tree = (struct dm_tree **) node;
-		dlid = _add_error_device(dm, *tree, seg, s);
-		if (!dlid)
+		if (!(dlid = _add_error_device(dm, *tree, seg, s)))
 			return_0;
 		if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_le(seg, s)))
 			return_0;


