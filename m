From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Dec 2009 09:59:55 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20091203095955.9819.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-12-03 09:59:54

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	skip cast from (void*)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.164&r2=1.165

--- LVM2/lib/activate/dev_manager.c	2009/12/03 09:58:30	1.164
+++ LVM2/lib/activate/dev_manager.c	2009/12/03 09:59:54	1.165
@@ -1095,7 +1095,7 @@
 	int r = 1;
 
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
-		if (!(lvlayer = (struct lv_layer *) dm_tree_node_get_context(child)))
+		if (!(lvlayer = dm_tree_node_get_context(child)))
 			continue;
 
 		/* Detect rename */


