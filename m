From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Nov 2011 11:04:46 -0000
Subject: LVM2/lib/metadata thin_manip.c
Message-ID: <20111107110446.13739.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-07 11:04:46

Modified files:
	lib/metadata   : thin_manip.c 

Log message:
	Thin add error message for double delete
	
	Add few more internal error messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/lib/metadata/thin_manip.c	2011/11/07 11:03:47	1.24
+++ LVM2/lib/metadata/thin_manip.c	2011/11/07 11:04:45	1.25
@@ -74,7 +74,16 @@
 					  tmsg->u.lv->name);
 				dm_list_del(&tmsg->list);
 			}
+			break;
+		case DM_THIN_MESSAGE_DELETE:
+			if (tmsg->u.delete_id == seg->device_id) {
+				log_error(INTERNAL_ERROR "Trying to delete %u again.",
+					  tmsg->u.delete_id);
+				return 0;
+			}
+			break;
 		default:
+			log_error(INTERNAL_ERROR "Unsupported message type %u.", tmsg->type);
 			break;
 		}
 	}


