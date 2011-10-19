From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Oct 2011 16:42:15 -0000
Subject: LVM2 lib/metadata/thin_manip.c libdm/libdm-dep ...
Message-ID: <20111019164215.636.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-19 16:42:14

Modified files:
	lib/metadata   : thin_manip.c 
	libdm          : libdm-deptree.c 

Log message:
	Update error message
	
	Drop INTERNAL_ERROR from public API functions.
	Improve some messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/lib/metadata/thin_manip.c	2011/10/19 16:39:09	1.11
+++ LVM2/lib/metadata/thin_manip.c	2011/10/19 16:42:14	1.12
@@ -126,7 +126,7 @@
 		tmsg->u.delete_id = delete_id;
 		break;
 	default:
-		log_error(INTERNAL_ERROR "Unsupported message type %d", type);
+		log_error(INTERNAL_ERROR "Unsupported message type %u.", type);
 		return 0;
 	}
 
--- LVM2/libdm/libdm-deptree.c	2011/10/19 16:40:59	1.131
+++ LVM2/libdm/libdm-deptree.c	2011/10/19 16:42:14	1.132
@@ -2880,13 +2880,13 @@
 	struct thin_message *tm;
 
 	if (node->props.segment_count != 1) {
-		log_error(INTERNAL_ERROR "Attempt to use non thin pool segment.");
+		log_error("Thin pool node must have only one segment.");
 		return 0;
 	}
 
 	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
 	if (seg->type != SEG_THIN_POOL) {
-		log_error(INTERNAL_ERROR "Attempt to use non thin pool segment %s.",
+		log_error("Thin pool node has segment type %s.",
 			  dm_segtypes[seg->type].target);
 		return 0;
 	}
@@ -2898,9 +2898,9 @@
 
 	switch (message->type) {
 	case DM_THIN_MESSAGE_CREATE_SNAP:
-		/* Origin MUST be suspend! */
+		/* If the thin origin is active, it must be suspend first! */
 		if (message->u.m_create_snap.device_id == message->u.m_create_snap.origin_id) {
-			log_error("Same origin used for thin snapshot.");
+			log_error("Cannot use same device id for origin and its snapshot.");
 			return 0;
 		}
 		if (!_thin_validate_device_id(message->u.m_create_snap.device_id) ||


