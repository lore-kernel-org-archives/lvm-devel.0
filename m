From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Nov 2007 15:04:12 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20071129150412.16182.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-29 15:04:12

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	uncomment libdevmapper readahead calls

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129

--- LVM2/lib/activate/dev_manager.c	2007/11/12 20:51:53	1.128
+++ LVM2/lib/activate/dev_manager.c	2007/11/29 15:04:12	1.129
@@ -142,11 +142,10 @@
 	if (!dm_task_get_info(dmt, info))
 		goto_out;
 
-	if (!with_read_ahead) {
-		if (read_ahead)
-			*read_ahead = DM_READ_AHEAD_NONE;
-	} else
-		; // FIXME *read_ahead = dm_task_get_read_ahead(dmt);
+	if (with_read_ahead)
+		*read_ahead = dm_task_get_read_ahead(dmt);
+	else if (read_ahead)
+		*read_ahead = DM_READ_AHEAD_NONE;
 
 	r = 1;
 
@@ -901,7 +900,7 @@
 	char *name, *dlid;
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
-	uint32_t flags = UINT32_C(0);
+	uint32_t read_ahead_flags = UINT32_C(0);
 
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
@@ -955,9 +954,9 @@
 	if (read_ahead == DM_READ_AHEAD_AUTO)
 		read_ahead = max_stripe_size;
 	else
-		flags = DM_READ_AHEAD_MINIMUM_FLAG;
+		read_ahead_flags = DM_READ_AHEAD_MINIMUM_FLAG;
 
-	// FIXME dm_tree_node_set_read_ahead(dnode, read_ahead, flags);
+	dm_tree_node_set_read_ahead(dnode, read_ahead, read_ahead_flags);
 
 	return 1;
 }


