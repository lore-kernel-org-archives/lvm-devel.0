From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Nov 2011 10:59:08 -0000
Subject: LVM2/lib/metadata thin_manip.c
Message-ID: <20111107105908.9245.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-07 10:59:08

Modified files:
	lib/metadata   : thin_manip.c 

Log message:
	Thin reindent code
	
	Drop indention level
	Add extra internal error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/lib/metadata/thin_manip.c	2011/11/03 15:58:20	1.22
+++ LVM2/lib/metadata/thin_manip.c	2011/11/07 10:59:07	1.23
@@ -88,27 +88,29 @@
 	struct lv_thin_message *tmsg;
 
 	dm_list_iterate_items(tmsg, &seg->thin_messages) {
-		if (tmsg->type == type) {
-			switch (tmsg->type) {
-			case DM_THIN_MESSAGE_CREATE_SNAP:
-			case DM_THIN_MESSAGE_CREATE_THIN:
-			case DM_THIN_MESSAGE_TRIM:
-				if (tmsg->u.lv == lv) {
-					log_error("Message referring LV %s already queued for %s.",
-						  tmsg->u.lv->name, seg->lv->name);
-					return 0;
-				}
-				break;
-			case DM_THIN_MESSAGE_DELETE:
-				if (tmsg->u.delete_id == delete_id) {
-					log_error("Delete of device %u already queued for %s.",
-						  tmsg->u.delete_id, seg->lv->name);
-					return 0;
-				}
-				break;
-			default:
-				break;
+		if (tmsg->type != type)
+			continue;
+
+		switch (tmsg->type) {
+		case DM_THIN_MESSAGE_CREATE_SNAP:
+		case DM_THIN_MESSAGE_CREATE_THIN:
+		case DM_THIN_MESSAGE_TRIM:
+			if (tmsg->u.lv == lv) {
+				log_error("Message referring LV %s already queued for %s.",
+					  tmsg->u.lv->name, seg->lv->name);
+				return 0;
+			}
+			break;
+		case DM_THIN_MESSAGE_DELETE:
+			if (tmsg->u.delete_id == delete_id) {
+				log_error("Delete of device %u already queued for %s.",
+					  tmsg->u.delete_id, seg->lv->name);
+				return 0;
 			}
+			break;
+		default:
+			log_error(INTERNAL_ERROR "Unsupported message type %u.", tmsg->type);
+			return 0;
 		}
 	}
 


