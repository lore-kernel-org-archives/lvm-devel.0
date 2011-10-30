From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Oct 2011 22:52:09 -0000
Subject: LVM2 lib/metadata/thin_manip.c libdm/libdm-dep ...
Message-ID: <20111030225209.13607.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-30 22:52:08

Modified files:
	lib/metadata   : thin_manip.c 
	libdm          : libdm-deptree.c 

Log message:
	Thin fix compile warns
	
	Test for dm_snprintf < 0.
	Add header for moved backup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142

--- LVM2/lib/metadata/thin_manip.c	2011/10/30 22:01:39	1.16
+++ LVM2/lib/metadata/thin_manip.c	2011/10/30 22:52:08	1.17
@@ -18,6 +18,7 @@
 #include "metadata.h"
 #include "segtype.h"
 #include "lv_alloc.h"
+#include "archiver.h"
 
 int attach_pool_metadata_lv(struct lv_segment *seg, struct logical_volume *pool_metadata_lv)
 {
--- LVM2/libdm/libdm-deptree.c	2011/10/30 22:04:57	1.141
+++ LVM2/libdm/libdm-deptree.c	2011/10/30 22:52:08	1.142
@@ -1294,9 +1294,11 @@
 				m->u.m_set_transaction_id.current_id,
 				m->u.m_set_transaction_id.new_id);
 		break;
+	default:
+		r = -1;
 	}
 
-	if (!r) {
+	if (r < 0) {
 		log_error("Failed to prepare message.");
 		return 0;
 	}


