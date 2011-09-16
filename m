From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Sep 2011 12:12:54 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20110916121254.25068.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-16 12:12:54

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Remove thin volumes before thin pools
	
	When user wants to remove thin pool - check if there are no thin volumes using it.
	If so - query before removal (or -ff for no question) and remove them first.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.287&r2=1.288

--- LVM2/lib/metadata/lv_manip.c	2011/09/16 11:59:22	1.287
+++ LVM2/lib/metadata/lv_manip.c	2011/09/16 12:12:51	1.288
@@ -3178,6 +3178,22 @@
 		}
 	}
 
+	if (lv_is_thin_pool(lv) && dm_list_size(&lv->segs_using_this_lv)) {
+		/* remove thin LVs first */
+		if ((force == PROMPT) &&
+		    yes_no_prompt("Do you really want to remove all thin volumes when removing "
+				  "pool logical volume %s? [y/n]: ", lv->name) == 'n') {
+			log_error("Logical volume %s not removed", lv->name);
+			return 0;
+		}
+		dm_list_iterate_safe(snh, snht, &lv->segs_using_this_lv) {
+			if (!lv_remove_with_dependencies(cmd,
+							 dm_list_item(snh, struct seg_list)->seg->lv,
+							 force, level + 1))
+				return 0;
+		}
+	}
+
 	return lv_remove_single(cmd, lv, force);
 }
 


