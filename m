From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Oct 2011 16:45:03 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20111019164503.2863.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-19 16:45:03

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Use structure copy
	
	Since the code evolved a bit with current structures we could use C to
	copy struct members.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/libdm/libdm-deptree.c	2011/10/19 16:42:14	1.132
+++ LVM2/libdm/libdm-deptree.c	2011/10/19 16:45:02	1.133
@@ -2906,26 +2906,24 @@
 		if (!_thin_validate_device_id(message->u.m_create_snap.device_id) ||
 		    !_thin_validate_device_id(message->u.m_create_snap.origin_id))
 			return_0;
-		tm->message.u.m_create_snap.device_id = message->u.m_create_snap.device_id;
-		tm->message.u.m_create_snap.origin_id = message->u.m_create_snap.origin_id;
+		tm->message.u.m_create_snap = message->u.m_create_snap;
 		break;
 	case DM_THIN_MESSAGE_CREATE_THIN:
 		if (!_thin_validate_device_id(message->u.m_create_thin.device_id))
 			return_0;
-		tm->message.u.m_create_thin.device_id = message->u.m_create_thin.device_id;
+		tm->message.u.m_create_thin = message->u.m_create_thin;
 		tm->expected_errno = EEXIST;
 		break;
 	case DM_THIN_MESSAGE_DELETE:
 		if (!_thin_validate_device_id(message->u.m_delete.device_id))
 			return_0;
-		tm->message.u.m_delete.device_id = message->u.m_delete.device_id;
+		tm->message.u.m_delete = message->u.m_delete;
 		tm->expected_errno = ENODATA;
 		break;
 	case DM_THIN_MESSAGE_TRIM:
 		if (!_thin_validate_device_id(message->u.m_trim.device_id))
 			return_0;
-		tm->message.u.m_trim.device_id = message->u.m_trim.device_id;
-		tm->message.u.m_trim.new_size = message->u.m_trim.new_size;
+		tm->message.u.m_trim = message->u.m_trim;
 		break;
 	case DM_THIN_MESSAGE_SET_TRANSACTION_ID:
 		if (message->u.m_set_transaction_id.current_id !=
@@ -2933,10 +2931,7 @@
 			log_error("New transaction_id must be sequential.");
 			return 0; /* FIXME: Maybe too strict here? */
 		}
-		tm->message.u.m_set_transaction_id.current_id =
-			message->u.m_set_transaction_id.current_id;
-		tm->message.u.m_set_transaction_id.new_id =
-			message->u.m_set_transaction_id.new_id;
+		tm->message.u.m_set_transaction_id = message->u.m_set_transaction_id;
 		break;
 	default:
 		log_error("Unsupported message type %d.", (int) message->type);


