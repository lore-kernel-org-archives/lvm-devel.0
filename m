From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Oct 2011 18:43:39 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111003184339.29263.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-03 18:43:39

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Add code to activate thin target
	
	Code to zero pool metadata lv when pool is created.
	Add code to create thin target via message sending.
	
	(Revert is missing)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.292&r2=1.293

--- LVM2/lib/metadata/lv_manip.c	2011/09/29 08:56:38	1.292
+++ LVM2/lib/metadata/lv_manip.c	2011/10/03 18:43:39	1.293
@@ -3889,6 +3889,7 @@
 	uint32_t size_rest;
 	uint64_t status = UINT64_C(0);
 	struct logical_volume *lv, *org = NULL;
+	struct logical_volume *pool_lv;
 	int origin_active = 0;
 	struct lvinfo info;
 
@@ -4113,6 +4114,27 @@
 
 	if (seg_is_thin_pool(lp) && lp->zero)
 		first_seg(lv)->zero_new_blocks = 1;
+	else if (seg_is_thin_volume(lp)) {
+		pool_lv = first_seg(lv)->pool_lv;
+
+		if (!(first_seg(lv)->device_id =
+		      get_free_pool_device_id(first_seg(pool_lv))))
+			return_NULL;
+
+		if (!activate_lv(pool_lv->vg->cmd, pool_lv)) {
+			log_error("Failed to activate %s/%s to send message.",
+				  pool_lv->vg->name, pool_lv->name);
+			return NULL;
+		}
+
+		if (!lv_send_message(pool_lv, "create_thin %u", first_seg(lv)->device_id))
+			return_NULL;
+
+		/*
+		 * FIXME: Skipping deactivate_lv(pool_lv) as it is going to be needed anyway
+		 * but revert_new_lv should revert to deactivated state.
+		 */
+	}
 
 	if (seg_is_thin_pool(lp)) {
 		/* FIXME: add lvcreate params - maybe -c/--chunksize?,
@@ -4166,6 +4188,10 @@
 			  lp->snapshot ? "snapshot exception store" :
 					 "start of new LV");
 		goto deactivate_and_revert_new_lv;
+	} else if (seg_is_thin_pool(lp)) {
+		if (!set_lv(cmd, first_seg(lv)->pool_metadata_lv, UINT64_C(0), 0))
+			log_error("Aborting. Failed to wipe pool metadata %s.",
+				  lv->name);
 	}
 
 	if (lp->snapshot) {


