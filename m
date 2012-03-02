From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2012 13:26:18 -0000
Subject: LVM2 ./WHATS_NEW_DM lib/metadata/thin_manip.c ...
Message-ID: <20120302132618.22799.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-02 13:26:12

Modified files:
	.              : WHATS_NEW_DM 
	lib/metadata   : thin_manip.c 
	lib/thin       : thin.c 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Remove support for TRIM message
	
	It's been unsupporte for now - and it's not going to be
	implemented for thin pool kernel driver - so dropping
	appearence of TRIM from libdm and lvm.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.580&r2=1.581
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.185&r2=1.186
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158

--- LVM2/WHATS_NEW_DM	2012/03/01 22:06:18	1.580
+++ LVM2/WHATS_NEW_DM	2012/03/02 13:26:08	1.581
@@ -1,5 +1,6 @@
 Version 1.02.73 - 
 ====================================
+  Drop unsupported TRIM message for thin pool.
   Improve logging for fifo startup in dmeventd.
   Add few pointer validation in dmsetup.
   Support dm_task_get_driver_version() query without version string.
--- LVM2/lib/metadata/thin_manip.c	2012/02/12 21:42:43	1.34
+++ LVM2/lib/metadata/thin_manip.c	2012/03/02 13:26:09	1.35
@@ -70,7 +70,6 @@
 		switch (tmsg->type) {
 		case DM_THIN_MESSAGE_CREATE_SNAP:
 		case DM_THIN_MESSAGE_CREATE_THIN:
-		case DM_THIN_MESSAGE_TRIM:
 			if (tmsg->u.lv == seg->lv) {
 				log_debug("Discarding message for LV %s.",
 					  tmsg->u.lv->name);
@@ -151,7 +150,6 @@
 	switch (type) {
 	case DM_THIN_MESSAGE_CREATE_SNAP:
 	case DM_THIN_MESSAGE_CREATE_THIN:
-	case DM_THIN_MESSAGE_TRIM:
 		tmsg->u.lv = lv;
 		break;
 	case DM_THIN_MESSAGE_DELETE:
@@ -173,7 +171,6 @@
 	log_debug("Added %s message",
 		  (type == DM_THIN_MESSAGE_CREATE_SNAP ||
 		   type == DM_THIN_MESSAGE_CREATE_THIN) ? "create" :
-		  (type == DM_THIN_MESSAGE_TRIM) ? "trim" :
 		  (type == DM_THIN_MESSAGE_DELETE) ? "delete" : "unknown");
 
 	return 1;
@@ -200,7 +197,6 @@
 		switch (tmsg->type) {
 		case DM_THIN_MESSAGE_CREATE_SNAP:
 		case DM_THIN_MESSAGE_CREATE_THIN:
-		case DM_THIN_MESSAGE_TRIM:
 			if (tmsg->u.lv == lv)
 				return 1;
 			break;
--- LVM2/lib/thin/thin.c	2012/02/28 14:23:42	1.47
+++ LVM2/lib/thin/thin.c	2012/03/02 13:26:09	1.48
@@ -62,15 +62,6 @@
 		type = DM_THIN_MESSAGE_CREATE_THIN;
 	}
 
-	if (dm_config_get_str(sn, "trim", &lv_name)) {
-		if (lv)
-			return SEG_LOG_ERROR("Unsupported message format in");
-		if (!(lv = find_lv(seg->lv->vg, lv_name)))
-			return SEG_LOG_ERROR("Unknown LV %s for trim message in",
-					     lv_name);
-		type = DM_THIN_MESSAGE_TRIM;
-	}
-
 	if (!dm_config_get_uint32(sn, "delete", &delete_id)) {
 		if (!lv)
 			return SEG_LOG_ERROR("Unknown message in");
@@ -169,7 +160,6 @@
 		switch (tmsg->type) {
 		case DM_THIN_MESSAGE_CREATE_SNAP:
 		case DM_THIN_MESSAGE_CREATE_THIN:
-		case DM_THIN_MESSAGE_TRIM:
 			if (!lv_is_thin_volume(tmsg->u.lv)) {
 				log_error(INTERNAL_ERROR
 					  "LV %s is not a thin volume.",
@@ -192,9 +182,6 @@
 		case DM_THIN_MESSAGE_CREATE_THIN:
 			outf(f, "create = \"%s\"", tmsg->u.lv->name);
 			break;
-		case DM_THIN_MESSAGE_TRIM:
-			outf(f, "trim = \"%s\"", tmsg->u.lv->name);
-			break;
 		case DM_THIN_MESSAGE_DELETE:
 			outf(f, "delete = %d", tmsg->u.delete_id);
 			break;
@@ -302,10 +289,6 @@
 								lmsg->u.delete_id, 0))
 				return_0;
 			break;
-		case DM_THIN_MESSAGE_TRIM:
-			/* FIXME: to be implemented */
-			log_error("Sorry TRIM is not yet supported.");
-			return 0;
 		default:
 			log_error(INTERNAL_ERROR "Unsupported message.");
 			return 0;
--- LVM2/libdm/libdevmapper.h	2012/03/01 19:54:53	1.185
+++ LVM2/libdm/libdevmapper.h	2012/03/02 13:26:10	1.186
@@ -650,7 +650,6 @@
 	DM_THIN_MESSAGE_CREATE_THIN,		/* device_id */
 	DM_THIN_MESSAGE_DELETE,			/* device_id */
 	DM_THIN_MESSAGE_SET_TRANSACTION_ID,	/* current_id, new_id */
-	DM_THIN_MESSAGE_TRIM			/* device_id, new_size */
 } dm_thin_message_t;
 
 int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
--- LVM2/libdm/libdm-deptree.c	2012/02/13 20:13:40	1.157
+++ LVM2/libdm/libdm-deptree.c	2012/03/02 13:26:10	1.158
@@ -1404,11 +1404,6 @@
 		r = dm_snprintf(buf, sizeof(buf), "delete %u",
 				m->u.m_delete.device_id);
 		break;
-	case DM_THIN_MESSAGE_TRIM:
-		r = dm_snprintf(buf, sizeof(buf), "trim %u %" PRIu64,
-				m->u.m_trim.device_id,
-				m->u.m_trim.new_size);
-		break;
 	case DM_THIN_MESSAGE_SET_TRANSACTION_ID:
 		r = dm_snprintf(buf, sizeof(buf),
 				"set_transaction_id %" PRIu64 " %" PRIu64,
@@ -3051,12 +3046,6 @@
 		tm->message.u.m_delete.device_id = id1;
 		tm->expected_errno = ENODATA;
 		break;
-	case DM_THIN_MESSAGE_TRIM:
-		if (!_thin_validate_device_id(id1))
-			return_0;
-		tm->message.u.m_trim.device_id = id1;
-		tm->message.u.m_trim.new_size = id2;
-		break;
 	case DM_THIN_MESSAGE_SET_TRANSACTION_ID:
 		if ((id1 + 1) != id2) {
 			log_error("New transaction id must be sequential.");


