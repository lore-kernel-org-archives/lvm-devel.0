From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jan 2008 12:35:32 -0000
Subject: LVM2/lib format_text/import_vsn1.c label/label.c
Message-ID: <20080131123532.10573.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-31 12:35:32

Modified files:
	lib/format_text: import_vsn1.c 
	lib/label      : label.c 

Log message:
	a couple more compiler warnings

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/lib/format_text/import_vsn1.c	2008/01/30 13:59:59	1.49
+++ LVM2/lib/format_text/import_vsn1.c	2008/01/31 12:35:31	1.50
@@ -524,7 +524,7 @@
 		case 0:
 			lv->read_ahead = DM_READ_AHEAD_AUTO;
 			break;
-		case -1:
+		case (uint32_t) -1:
 			lv->read_ahead = DM_READ_AHEAD_NONE;
 			break;
 		default:
--- LVM2/lib/label/label.c	2008/01/30 13:19:45	1.40
+++ LVM2/lib/label/label.c	2008/01/31 12:35:31	1.41
@@ -143,7 +143,7 @@
 				continue;
 			}
 			if (calc_crc(INITIAL_CRC, &lh->offset_xl, LABEL_SIZE -
-				     ((void *) &lh->offset_xl - (void *) lh)) !=
+				     ((uintptr_t) &lh->offset_xl - (uintptr_t) lh)) !=
 			    xlate32(lh->crc_xl)) {
 				log_info("Label checksum incorrect on %s - "
 					 "ignoring", dev_name(dev));
@@ -322,7 +322,7 @@
 		return_0;
 
 	lh->crc_xl = xlate32(calc_crc(INITIAL_CRC, &lh->offset_xl, LABEL_SIZE -
-				      ((void *) &lh->offset_xl - (void *) lh)));
+				      ((uintptr_t) &lh->offset_xl - (uintptr_t) lh)));
 
 	if (!dev_open(dev))
 		return_0;


