From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 09:06:44 -0000
Subject: LVM2/lib activate/activate.h activate/dev_mana ...
Message-ID: <20120125090644.29586.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 09:06:43

Modified files:
	lib/activate   : activate.h dev_manager.c 
	lib/thin       : thin.c 

Log message:
	Thin add messages only for activation tree
	
	Extend lv_activate_opts with bool flag to know for which purpose
	dtree is created - and add message only for activation tree
	(since that's the only place that may send them).
	
	Extend validation check for thin snapshot creation and test whether
	active snapshot origin is suspended before its snapshot is created
	(useful in recover scenarios) -  in this case also detect, whether
	transaction has been already completed and avoid such suspend check
	failure in that case.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.265&r2=1.266
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/lib/activate/activate.h	2012/01/25 08:48:43	1.95
+++ LVM2/lib/activate/activate.h	2012/01/25 09:06:43	1.96
@@ -35,6 +35,7 @@
 	int origin_only;
 	int no_merging;
 	int real_pool;
+	int is_activate;
 	unsigned revert;
 	unsigned read_only;
 };
--- LVM2/lib/activate/dev_manager.c	2012/01/25 08:48:43	1.265
+++ LVM2/lib/activate/dev_manager.c	2012/01/25 09:06:43	1.266
@@ -1974,6 +1974,8 @@
 	char *dlid;
 	int r = 0;
 
+	laopts->is_activate = (action == ACTIVATE);
+
 	if (!(dtree = _create_partial_dtree(dm, lv, laopts->origin_only)))
 		return_0;
 
--- LVM2/lib/thin/thin.c	2012/01/25 08:51:29	1.43
+++ LVM2/lib/thin/thin.c	2012/01/25 09:06:43	1.44
@@ -223,6 +223,8 @@
 	char *metadata_dlid, *pool_dlid;
 	const struct lv_thin_message *lmsg;
 	const struct logical_volume *origin;
+	struct lvinfo info;
+	uint64_t transaction_id = 0;
 
 	if (!laopts->real_pool) {
 		if (!(pool_dlid = build_dm_uuid(mem, seg->lv->lvid.s, "tpool"))) {
@@ -257,10 +259,35 @@
 					       seg->zero_new_blocks ? 0 : 1))
 		return_0;
 
+	/*
+	 * Add messages only for activation tree.
+	 * Otherwise avoid checking for existence of suspended origin.
+	 * Also transation_id is checked only when snapshot origin is active.
+	 * (This might change later)
+	 */
+	if (!laopts->is_activate)
+		return 1;
+
 	dm_list_iterate_items(lmsg, &seg->thin_messages) {
 		switch (lmsg->type) {
 		case DM_THIN_MESSAGE_CREATE_THIN:
 			origin = first_seg(lmsg->u.lv)->origin;
+			/* Check if the origin is suspended */
+			if (origin && lv_info(cmd, origin, 0, &info, 0, 0) &&
+			    info.exists && !info.suspended) {
+				/* Origin is not suspended, but the transaction may have been
+				 * already transfered, so test for transaction_id and
+				 * allow to pass in the message for dmtree processing
+				 * so it will skip all messages later.
+				 */
+				if (!lv_thin_pool_transaction_id(seg->lv, &transaction_id))
+					return_0; /* Thin pool should exist and work */
+				if (transaction_id != seg->transaction_id) {
+					log_error("Can't create snapshot %s as origin %s is not suspended.",
+						  lmsg->u.lv->name, origin->name);
+					return 0;
+				}
+			}
 			log_debug("Thin pool create_%s %s.", (!origin) ? "thin" : "snap", lmsg->u.lv->name);
 			if (!dm_tree_node_add_thin_pool_message(node,
 								(!origin) ? lmsg->type : DM_THIN_MESSAGE_CREATE_SNAP,


