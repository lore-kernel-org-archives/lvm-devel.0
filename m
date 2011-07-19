From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 19 Jul 2011 16:23:53 -0000
Subject: LVM2/lib/metadata snapshot_manip.c
Message-ID: <20110719162353.18391.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-07-19 16:23:52

Modified files:
	lib/metadata   : snapshot_manip.c 

Log message:
	Fix potential null ptr deref in 'origin_from_cow'
	
	return NULL rather than segfaulting if lv->snapshot is not set

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/lib/metadata/snapshot_manip.c	2011/07/08 12:48:41	1.50
+++ LVM2/lib/metadata/snapshot_manip.c	2011/07/19 16:23:52	1.51
@@ -81,7 +81,9 @@
 /* Given a cow LV, return its origin */
 struct logical_volume *origin_from_cow(const struct logical_volume *lv)
 {
-	return lv->snapshot->origin;
+	if (lv->snapshot)
+		return lv->snapshot->origin;
+	return NULL;
 }
 
 void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,


