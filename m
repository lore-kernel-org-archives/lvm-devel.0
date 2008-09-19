From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 07:05:03 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20080919070503.25474.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 07:05:03

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141

--- LVM2/lib/activate/dev_manager.c	2008/09/19 06:41:57	1.140
+++ LVM2/lib/activate/dev_manager.c	2008/09/19 07:05:03	1.141
@@ -743,11 +743,11 @@
 			return_0;
 		dm_tree_node_add_target_area(node, NULL, dlid,
 					     extent_size * seg_le(seg, s));
-	} else {
+	} else
 		dm_tree_node_add_target_area(node,
 					     dm->cmd->stripe_filler,
 					     NULL, UINT64_C(0));
-	}
+
 	return 1;
 }
 


