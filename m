From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 08:57:25 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120125085725.27505.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 08:57:25

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin prevent removal of its data and metadata LVs
	
	LVs cannot be removed while there are linked to thin pool.
	(Gives better error message, than validation).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.348&r2=1.349

--- LVM2/lib/metadata/lv_manip.c	2012/01/24 14:53:59	1.348
+++ LVM2/lib/metadata/lv_manip.c	2012/01/25 08:57:25	1.349
@@ -3172,6 +3172,12 @@
 		return 0;
 	}
 
+	if (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv)) {
+		log_error("Can't remove logical volume %s used by a thin pool.",
+			  lv->name);
+		return 0;
+	}
+
 	if (lv->status & LOCKED) {
 		log_error("Can't remove locked LV %s", lv->name);
 		return 0;


